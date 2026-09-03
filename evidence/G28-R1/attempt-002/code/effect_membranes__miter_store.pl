% Locked, append-only trajectory storage for Miter.
% Event meaning remains MeTTa-owned.  This membrane performs only schema
% validation, hashing, filesystem locking, atomic object writes, and fsync.

:- use_module(library(http/json)).
:- use_module(library(readutil)).
:- use_module(library(filesex)).
:- use_module(library(crypto)).
:- use_module(library(shlib)).
:- use_module(library(lists)).

% Four scalar inputs followed by one scalar result.
miter_store_append_event(StoreRoot0, ExtensionPath0, IntentPath0, Result) :-
    (   miter_store_nonempty_atom(StoreRoot0, StoreRoot),
        miter_store_nonempty_atom(ExtensionPath0, ExtensionPath),
        miter_store_nonempty_atom(IntentPath0, IntentPath)
    ->  catch(
            miter_store_append_event_checked(
                StoreRoot, ExtensionPath, IntentPath, Result0
            ),
            Error,
            miter_store_exception_result(Error, Result0)
        ),
        Result = Result0
    ;   Result = 'invalid-event-append-argument'
    ),
    !.

% Two scalar inputs followed by one scalar result.
miter_store_verify_ledger(StoreRoot0, ReportPath0, Result) :-
    (   miter_store_nonempty_atom(StoreRoot0, StoreRoot),
        miter_store_nonempty_atom(ReportPath0, ReportPath)
    ->  catch(
            miter_store_verify_ledger_checked(
                StoreRoot, ReportPath, Result0
            ),
            Error,
            miter_store_exception_result(Error, Result0)
        ),
        Result = Result0
    ;   Result = 'invalid-trajectory-verification-argument'
    ),
    !.

% Two scalar inputs followed by one scalar result.
miter_store_readback(StoreRoot0, OutputPath0, Result) :-
    (   miter_store_nonempty_atom(StoreRoot0, StoreRoot),
        miter_store_nonempty_atom(OutputPath0, OutputPath)
    ->  catch(
            miter_store_readback_checked(StoreRoot, OutputPath, Result0),
            Error,
            miter_store_exception_result(Error, Result0)
        ),
        Result = Result0
    ;   Result = 'invalid-trajectory-readback-argument'
    ),
    !.

miter_store_append_event_checked(StoreRoot, ExtensionPath, IntentPath,
                                 Result) :-
    (   exists_file(IntentPath)
    ->  miter_store_ensure_extension(ExtensionPath),
        miter_store_read_json(IntentPath, Intent),
        miter_store_intent(Intent),
        miter_store_with_lock(
            StoreRoot,
            miter_store_append_locked(StoreRoot, Intent, Result)
        )
    ;   Result = 'event-intent-unavailable'
    ).

miter_store_append_locked(StoreRoot, Intent, Result) :-
    miter_store_load_ledger(StoreRoot, Lines),
    miter_store_analyze(StoreRoot, Lines, Analysis, Events),
    get_dict(status, Analysis, Status),
    (   Status == valid
    ->  miter_store_append_to_valid_ledger(
            StoreRoot, Intent, Analysis, Events, Result
        )
    ;   Result = 'trajectory-integrity-failed'
    ).

miter_store_append_to_valid_ledger(StoreRoot, Intent, Analysis, Events,
                                   Result) :-
    get_dict(event_id, Intent, EventId0),
    miter_store_nonempty_atom(EventId0, EventId),
    (   member(Event, Events),
        get_dict(event_id, Event, ExistingId0),
        miter_store_nonempty_atom(ExistingId0, ExistingId),
        ExistingId == EventId
    ->  Result = 'duplicate-event-id'
    ;   get_dict(parent_event_ids, Intent, ParentIds0),
        maplist(miter_store_nonempty_atom, ParentIds0, ParentIds),
        miter_store_event_ids(Events, ExistingIds),
        (   miter_store_all_members(ParentIds, ExistingIds)
        ->  get_dict(event_count, Analysis, Count),
            Sequence is Count + 1,
            get_dict(tip_event_hash, Analysis, PreviousHash),
            miter_store_build_event(
                Intent, Sequence, PreviousHash, EventWithoutHash,
                PayloadHash, PayloadText
            ),
            miter_store_canonical_json(EventWithoutHash, EventHashText),
            crypto_data_hash(
                EventHashText, EventHash,
                [algorithm(sha256), encoding(utf8)]
            ),
            put_dict(event_hash, EventWithoutHash, EventHash, Event),
            miter_store_canonical_json(Event, EventText),
            miter_store_write_payload(
                StoreRoot, PayloadHash, PayloadText, PayloadResult
            ),
            miter_store_finish_append(
                PayloadResult, StoreRoot, EventText, Result
            )
        ;   Result = 'event-parent-unavailable'
        )
    ).

miter_store_finish_append('payload-durable', StoreRoot, EventText,
                          'event-appended') :-
    miter_store_ledger_path(StoreRoot, LedgerPath),
    setup_call_cleanup(
        open(LedgerPath, append, Stream,
             [encoding(utf8), type(text)]),
        ( chmod(LedgerPath, 0o600),
          format(Stream, '~s~n', [EventText]),
          flush_output(Stream),
          miter_store_fsync_stream(Stream)
        ),
        close(Stream)
    ),
    !.
miter_store_finish_append(Result, _, _, Result).

miter_store_verify_ledger_checked(_, ReportPath,
                                  'trajectory-report-output-exists') :-
    exists_file(ReportPath),
    !.
miter_store_verify_ledger_checked(StoreRoot, ReportPath, Result) :-
    miter_store_with_lock(
        StoreRoot,
        miter_store_verify_locked(StoreRoot, ReportPath, Result)
    ).

miter_store_verify_locked(StoreRoot, ReportPath, Result) :-
    miter_store_load_ledger(StoreRoot, Lines),
    miter_store_analyze(StoreRoot, Lines, Analysis, _),
    miter_store_write_json_atomic(ReportPath, Analysis),
    get_dict(status, Analysis, Status),
    ( Status == valid -> Result = 'trajectory-valid'
    ; Result = 'trajectory-integrity-failed'
    ).

miter_store_readback_checked(_, OutputPath,
                             'trajectory-readback-output-exists') :-
    exists_file(OutputPath),
    !.
miter_store_readback_checked(StoreRoot, OutputPath, Result) :-
    miter_store_with_lock(
        StoreRoot,
        miter_store_readback_locked(StoreRoot, OutputPath, Result)
    ).

miter_store_readback_locked(StoreRoot, OutputPath, Result) :-
    miter_store_load_ledger(StoreRoot, Lines),
    miter_store_analyze(StoreRoot, Lines, Analysis, Events),
    get_dict(status, Analysis, Status),
    (   Status == valid
    ->  maplist(miter_store_event_projection, Events, Projections),
        Readback = _{
            schema:'miter-trajectory-readback-v1',
            event_count:Analysis.event_count,
            tip_event_hash:Analysis.tip_event_hash,
            events:Projections
        },
        miter_store_write_json_atomic(OutputPath, Readback),
        Result = 'trajectory-readback-stored'
    ;   Result = 'trajectory-integrity-failed'
    ).

miter_store_build_event(Intent, Sequence, PreviousHash, Event, PayloadHash,
                        PayloadText) :-
    get_dict(payload, Intent, Payload),
    miter_store_canonical_json(Payload, PayloadText),
    crypto_data_hash(PayloadText, PayloadHash,
                     [algorithm(sha256), encoding(utf8)]),
    atom_concat('sha256:', PayloadHash, PayloadRef),
    del_dict(payload, Intent, _, IntentWithoutPayload),
    del_dict(schema, IntentWithoutPayload, _, EventFields),
    EventBase = _{
        schema_version:'miter-event-envelope-v1',
        local_sequence:Sequence,
        previous_event_hash:PreviousHash,
        payload_ref:PayloadRef,
        payload_hash:PayloadHash
    },
    put_dict(EventFields, EventBase, Event).

miter_store_intent(Intent) :-
    is_dict(Intent),
    get_dict(schema, Intent, Schema0),
    miter_store_nonempty_atom(Schema0, Schema),
    Schema == 'miter-event-intent-v1',
    maplist(miter_store_required_nonempty(Intent),
            [event_id, event_kind, occurred_at, recorded_at,
             source_surface, source_principal, audience_scope,
             project_scope, provenance_kind, correlation_id]),
    get_dict(parent_event_ids, Intent, Parents),
    is_list(Parents),
    maplist(miter_store_nonempty_atom, Parents, _),
    get_dict(payload, Intent, Payload),
    is_dict(Payload),
    !.
miter_store_intent(_) :-
    throw(error(miter_invalid_event_intent, _)).

miter_store_required_nonempty(Dict, Key) :-
    get_dict(Key, Dict, Value),
    miter_store_nonempty_atom(Value, _).

miter_store_write_payload(StoreRoot, PayloadHash, PayloadText, Result) :-
    miter_store_payload_path(StoreRoot, PayloadHash, PayloadPath),
    (   exists_file(PayloadPath)
    ->  read_file_to_string(PayloadPath, ExistingText, []),
        ( ExistingText == PayloadText -> Result = 'payload-durable'
        ; Result = 'payload-hash-collision'
        )
    ;   file_directory_name(PayloadPath, PayloadDirectory),
        make_directory_path(PayloadDirectory),
        atom_concat(PayloadPath, '.tmp', TemporaryPath),
        setup_call_cleanup(
            true,
            ( setup_call_cleanup(
              open(TemporaryPath, write, Stream,
                       [encoding(utf8), type(text)]),
                  ( chmod(TemporaryPath, 0o600),
                    format(Stream, '~s', [PayloadText]),
                    flush_output(Stream),
                    miter_store_fsync_stream(Stream)
                  ),
                  close(Stream)
              ),
              rename_file(TemporaryPath, PayloadPath)
            ),
            ( exists_file(TemporaryPath) -> delete_file(TemporaryPath)
            ; true
            )
        ),
        Result = 'payload-durable'
    ).

miter_store_analyze(StoreRoot, Lines, Analysis, Events) :-
    length(Lines, TotalLines),
    miter_store_validate_lines(
        StoreRoot, Lines, 1, 'GENESIS', [], [], Outcome, Events
    ),
    miter_store_analysis(Outcome, TotalLines, Analysis).

miter_store_validate_lines(_, [], _, PreviousHash, _, EventsAccumulator,
                           valid(PreviousHash), Events) :-
    reverse(EventsAccumulator, Events).
miter_store_validate_lines(StoreRoot, [Line|Rest], ExpectedSequence,
                           ExpectedPreviousHash, SeenIds, EventsAccumulator,
                           Outcome, Events) :-
    (   miter_store_parse_event(Line, Event)
    ->  miter_store_validate_event(
            StoreRoot, Event, ExpectedSequence, ExpectedPreviousHash,
            SeenIds, Validation
        ),
        (   Validation == valid
        ->  get_dict(event_id, Event, EventId0),
            miter_store_nonempty_atom(EventId0, EventId),
            get_dict(event_hash, Event, EventHash0),
            miter_store_nonempty_atom(EventHash0, EventHash),
            NextSequence is ExpectedSequence + 1,
            miter_store_validate_lines(
                StoreRoot, Rest, NextSequence, EventHash,
                [EventId|SeenIds], [Event|EventsAccumulator], Outcome, Events
            )
        ;   Validation = invalid(Code, EventId),
            length(EventsAccumulator, ValidatedPrefix),
            Outcome = broken(Code, ExpectedSequence, EventId,
                             ValidatedPrefix),
            reverse(EventsAccumulator, Events)
        )
    ;   length(EventsAccumulator, ValidatedPrefix),
        Outcome = broken('malformed-json', ExpectedSequence, unknown,
                         ValidatedPrefix),
        reverse(EventsAccumulator, Events)
    ).

miter_store_validate_event(StoreRoot, Event, ExpectedSequence,
                           ExpectedPreviousHash, SeenIds, Result) :-
    (   miter_store_event_shape(Event, EventId, Sequence, PreviousHash,
                                ParentIds, PayloadHash, PayloadRef,
                                StoredEventHash)
    ->  (   Sequence =\= ExpectedSequence
        ->  Result = invalid('sequence-mismatch', EventId)
        ;   PreviousHash \== ExpectedPreviousHash
        ->  Result = invalid('lineage-link-mismatch', EventId)
        ;   \+ miter_store_all_members(ParentIds, SeenIds)
        ->  Result = invalid('parent-lineage-missing', EventId)
        ;   \+ miter_store_payload_valid(
                StoreRoot, PayloadHash, PayloadRef
            )
        ->  Result = invalid('payload-hash-mismatch', EventId)
        ;   del_dict(event_hash, Event, _, EventWithoutHash),
            miter_store_canonical_json(EventWithoutHash, EventHashText),
            crypto_data_hash(
                EventHashText, ComputedEventHash,
                [algorithm(sha256), encoding(utf8)]
            ),
            ( StoredEventHash == ComputedEventHash
            -> Result = valid
            ; Result = invalid('event-hash-mismatch', EventId)
            )
        )
    ;   Result = invalid('event-schema-invalid', unknown)
    ).

miter_store_event_shape(Event, EventId, Sequence, PreviousHash, ParentIds,
                        PayloadHash, PayloadRef, EventHash) :-
    is_dict(Event),
    get_dict(schema_version, Event, Schema0),
    miter_store_nonempty_atom(Schema0, Schema),
    Schema == 'miter-event-envelope-v1',
    get_dict(local_sequence, Event, Sequence),
    integer(Sequence),
    Sequence > 0,
    get_dict(event_id, Event, EventId0),
    miter_store_nonempty_atom(EventId0, EventId),
    maplist(miter_store_required_nonempty(Event),
            [event_kind, occurred_at, recorded_at, source_surface,
             source_principal, audience_scope, project_scope,
             provenance_kind, correlation_id]),
    get_dict(previous_event_hash, Event, PreviousHash0),
    miter_store_nonempty_atom(PreviousHash0, PreviousHash),
    get_dict(parent_event_ids, Event, ParentIds0),
    is_list(ParentIds0),
    maplist(miter_store_nonempty_atom, ParentIds0, ParentIds),
    get_dict(payload_hash, Event, PayloadHash0),
    miter_store_sha256(PayloadHash0, PayloadHash),
    get_dict(payload_ref, Event, PayloadRef0),
    miter_store_nonempty_atom(PayloadRef0, PayloadRef),
    get_dict(event_hash, Event, EventHash0),
    miter_store_sha256(EventHash0, EventHash).

miter_store_payload_valid(StoreRoot, PayloadHash, PayloadRef) :-
    atom_concat('sha256:', PayloadHash, PayloadRef),
    miter_store_payload_path(StoreRoot, PayloadHash, PayloadPath),
    exists_file(PayloadPath),
    read_file_to_string(PayloadPath, PayloadText, []),
    crypto_data_hash(PayloadText, ObservedHash,
                     [algorithm(sha256), encoding(utf8)]),
    ObservedHash == PayloadHash.

miter_store_analysis(valid(TipHash), TotalLines, Analysis) :-
    Analysis = _{
        schema:'miter-trajectory-integrity-report-v1',
        status:valid,
        event_count:TotalLines,
        validated_prefix:TotalLines,
        tip_event_hash:TipHash,
        first_broken_sequence:null,
        first_broken_event_id:null,
        failure_code:null,
        later_lines_preserved:0
    }.
miter_store_analysis(broken(Code, Sequence, EventId, ValidatedPrefix),
                     TotalLines, Analysis) :-
    LaterLines is TotalLines - Sequence,
    Analysis = _{
        schema:'miter-trajectory-integrity-report-v1',
        status:invalid,
        event_count:TotalLines,
        validated_prefix:ValidatedPrefix,
        tip_event_hash:null,
        first_broken_sequence:Sequence,
        first_broken_event_id:EventId,
        failure_code:Code,
        later_lines_preserved:LaterLines
    }.

miter_store_parse_event(Line, Event) :-
    string(Line),
    string_length(Line, Length),
    Length > 0,
    atom_string(Atom, Line),
    catch(atom_json_dict(Atom, Event, []), _, fail),
    is_dict(Event).

miter_store_event_projection(Event, Projection) :-
    Projection = _{
        local_sequence:Event.local_sequence,
        event_id:Event.event_id,
        event_kind:Event.event_kind,
        event_hash:Event.event_hash,
        payload_hash:Event.payload_hash,
        parent_event_ids:Event.parent_event_ids
    }.

miter_store_event_ids(Events, Ids) :-
    maplist(miter_store_event_id, Events, Ids).

miter_store_event_id(Event, EventId) :-
    get_dict(event_id, Event, EventId0),
    miter_store_nonempty_atom(EventId0, EventId).

miter_store_all_members([], _).
miter_store_all_members([Item|Rest], Set) :-
    memberchk(Item, Set),
    miter_store_all_members(Rest, Set).

miter_store_load_ledger(StoreRoot, Lines) :-
    miter_store_ledger_path(StoreRoot, LedgerPath),
    (   exists_file(LedgerPath)
    ->  setup_call_cleanup(
            open(LedgerPath, read, Stream, [encoding(utf8), type(text)]),
            miter_store_read_lines(Stream, Lines),
            close(Stream)
        )
    ;   Lines = []
    ).

miter_store_read_lines(Stream, Lines) :-
    read_line_to_string(Stream, Line),
    (   Line == end_of_file
    ->  Lines = []
    ;   Lines = [Line|Rest],
        miter_store_read_lines(Stream, Rest)
    ).

miter_store_with_lock(StoreRoot, Goal) :-
    make_directory_path(StoreRoot),
    directory_file_path(StoreRoot, 'trajectory.lock', LockPath),
    setup_call_cleanup(
        open(LockPath, append, LockStream,
             [encoding(utf8), lock(write), wait(true)]),
        call(Goal),
        close(LockStream)
    ).

miter_store_ensure_extension(ExtensionPath) :-
    (   current_predicate(miter_posix_fsync_stream/1)
    ->  true
    ;   exists_file(ExtensionPath),
        load_foreign_library(ExtensionPath),
        current_predicate(miter_posix_fsync_stream/1)
    ),
    !.
miter_store_ensure_extension(_) :-
    throw(error(miter_store_extension_unavailable, _)).

miter_store_fsync_stream(Stream) :-
    (   miter_posix_fsync_stream(Stream)
    ->  true
    ;   throw(error(miter_store_fsync_failed, _))
    ).

miter_store_ledger_path(StoreRoot, LedgerPath) :-
    directory_file_path(StoreRoot, 'trajectory.jsonl', LedgerPath).

miter_store_payload_path(StoreRoot, Hash, PayloadPath) :-
    directory_file_path(StoreRoot, objects, ObjectsDirectory),
    directory_file_path(ObjectsDirectory, sha256, HashDirectory),
    atom_concat(Hash, '.json', FileName),
    directory_file_path(HashDirectory, FileName, PayloadPath).

miter_store_canonical_json(Dict, Text) :-
    with_output_to(
        string(Text),
        json_write_dict(current_output, Dict, [width(0)])
    ).

miter_store_read_json(Path, Dict) :-
    setup_call_cleanup(
        open(Path, read, Stream, [encoding(utf8)]),
        json_read_dict(Stream, Dict),
        close(Stream)
    ).

miter_store_write_json_atomic(Path, Dict) :-
    file_directory_name(Path, Directory),
    make_directory_path(Directory),
    atom_concat(Path, '.tmp', TemporaryPath),
    setup_call_cleanup(
        true,
        ( setup_call_cleanup(
              open(TemporaryPath, write, Stream, [encoding(utf8)]),
              ( chmod(TemporaryPath, 0o600),
                json_write_dict(Stream, Dict, [width(100)]),
                nl(Stream)
              ),
              close(Stream)
          ),
          rename_file(TemporaryPath, Path)
        ),
        ( exists_file(TemporaryPath) -> delete_file(TemporaryPath) ; true )
    ).

miter_store_sha256(Value, Hash) :-
    miter_store_nonempty_atom(Value, Hash),
    atom_length(Hash, 64),
    atom_codes(Hash, Codes),
    maplist(miter_store_hex_code, Codes).

miter_store_hex_code(Code) :-
    ( between(0'0, 0'9, Code)
    ; between(0'a, 0'f, Code)
    ).

miter_store_nonempty_atom(Value, Atom) :-
    (   atom(Value)
    ->  Atom = Value
    ;   string(Value)
    ->  atom_string(Atom, Value)
    ),
    atom_length(Atom, Length),
    Length > 0.

miter_store_exception_result(error(miter_invalid_event_intent, _),
                              'invalid-event-intent') :- !.
miter_store_exception_result(error(miter_store_extension_unavailable, _),
                              'store-runtime-extension-unavailable') :- !.
miter_store_exception_result(error(miter_store_fsync_failed, _),
                              'trajectory-fsync-error') :- !.
miter_store_exception_result(error(permission_error(lock, _, _), _),
                              'trajectory-lock-unavailable') :- !.
miter_store_exception_result(error(permission_error(_, _, _), _),
                              'trajectory-permission-error') :- !.
miter_store_exception_result(error(existence_error(_, _), _),
                              'trajectory-input-unavailable') :- !.
miter_store_exception_result(_, 'trajectory-store-error').
