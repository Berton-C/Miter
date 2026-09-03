% Protocol-agnostic surface descriptor transport laboratory.
% Destination-specific mappings live in the candidate and fixed fixture.
% This module performs loopback I/O, opaque journaling, hashing, restart,
% panic/rollback mechanics, and typed observation only.

:- module(miter_surface_transport_lab_v1, [
    p4_trial/8,
    p4_resume_worker/4
]).

:- ensure_loaded('miter_store.pl').
:- use_module(library(crypto)).
:- use_module(library(http/http_open)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(process)).
:- use_module(library(readutil)).

:- dynamic p4_server_config/3.
:- dynamic p4_server_receipt/3.
:- dynamic p4_server_attempts/1.

p4_trial(Root0, Candidate0, CandidateHash0, Transport0, TransportHash0,
         Fixture0, Mode0, Result) :-
    catch((p4_trial_checked(Root0, Candidate0, CandidateHash0, Transport0,
                            TransportHash0, Fixture0, Mode0, Result0)
          -> true
          ; Result0 = ['p4-trial-failure', 'contract-failed']),
          Error, p4_error(Error, Result0)),
    Result = Result0,
    !.

p4_trial_checked(Root0, Candidate0, CandidateHash0, Transport0,
                 TransportHash0, Fixture0, Mode0, Result) :-
    maplist(p4_atom,
            [Root0,Candidate0,CandidateHash0,Transport0,TransportHash0,
             Fixture0,Mode0],
            [Root,Candidate,CandidateHash,Transport,TransportHash,
             Fixture,Mode]),
    p4_root(Root),
    memberchk(Mode,[canonical,'wrong-principal','no-journal']),
    p4_file_hash(Candidate,CandidateHash),
    p4_file_hash(Transport,TransportHash),
    exists_file(Fixture),
    load_files(Candidate,[silent(true)]),
    p4_candidate_module(Candidate,Module),
    p4_read_json(Fixture,FixtureJson),
    p4_native(FixtureJson,Data),
    ( Mode == canonical
    -> p4_canonical(Root,CandidateHash,Transport,TransportHash,Module,Data,Result)
    ; p4_severed(Root,Mode,Module,Data,Result)
    ).

p4_canonical(Root,CandidateHash,Transport,TransportHash,Module,Data,Result) :-
    Config=Data.candidate_config,
    Frame=Data.authorized_frame,
    Unauthorized=Data.unauthorized_frame,
    Effect=Data.effect,
    Capability=Data.capability,
    p4_initial_state(State0),
    call(Module:surface_ingest(Config,State0,Frame,State1,Inbound)),
    get_dict(status,Inbound,accepted),
    call(Module:surface_ingest(
        Config,State1,Unauthorized,State1,UnauthorizedOutcome)),
    p4_status_reason(UnauthorizedOutcome,rejected,unauthorized),
    call(Module:surface_effect(
        Config,State1,Effect,State2,EffectOutcome)),
    get_dict(status,EffectOutcome,accepted),
    get_dict(descriptor,EffectOutcome,Descriptor),
    p4_descriptor_identity(Descriptor,Capability,Identity),
    p4_journal_path(Root,'effect-pending.json',PendingPath),
    p4_durable_json(PendingPath,_{schema:'surface-effect-journal-v1',
        status:pending,identity:Identity,descriptor:Descriptor,
        candidate_hash:CandidateHash,transport_hash:TransportHash}),
    p4_journal_path(Root,'cursor.json',CursorPath),
    p4_encode_ground_state(State2,StateTerm),
    get_dict(cursor,State2,StateCursor),
    integer(StateCursor),
    p4_durable_json(CursorPath,_{schema:'surface-cursor-journal-v1',
        cursor:StateCursor,state_term:StateTerm,candidate_hash:CandidateHash,
        transport_hash:TransportHash}),
    p4_journal_path(Root,'version-before.json',BeforePath),
    p4_durable_json(BeforePath,_{active:inactive,candidate_hash:CandidateHash}),
    p4_journal_path(Root,'version-lab.json',LabPath),
    p4_durable_json(LabPath,_{active:CandidateHash,previous:inactive,
        scope:'offline-laboratory'}),
    setup_call_cleanup(
        p4_start_server(Capability,Port),
        p4_canonical_requests(Root,Port,Capability,Descriptor,
                              Receipt1,Receipt2,Attempts,Creates),
        p4_stop_server(Port)),
    Receipt1 == Receipt2,
    Attempts =:= 2,
    Creates =:= 1,
    p4_journal_path(Root,'loopback-summary.json',LoopbackPath),
    p4_durable_json(LoopbackPath,_{schema:'surface-loopback-summary-v1',
        method:Descriptor.method,path:Descriptor.path,body:Descriptor.body,
        attempts:Attempts,creates:Creates,first_receipt:Receipt1,
        second_receipt:Receipt2}),
    p4_journal_path(Root,'effect-confirmed.json',ConfirmedPath),
    p4_durable_json(ConfirmedPath,_{schema:'surface-effect-journal-v1',
        status:confirmed,identity:Identity,receipt:Receipt1,
        candidate_hash:CandidateHash,transport_hash:TransportHash}),
    p4_spawn_resume(Transport,Root,CandidateHash,TransportHash,RestartStatus),
    RestartStatus == exit(0),
    p4_journal_path(Root,'restart.json',RestartPath),
    p4_read_json(RestartPath,Restart),
    Restart.verified == true,
    call(Module:surface_panic(State2,PanicState)),
    call(Module:surface_effect(
        Config,PanicState,Effect,PanicState,PanicOutcome)),
    p4_status_reason(PanicOutcome,rejected,panic_active),
    p4_journal_path(Root,'version-rollback.json',RollbackPath),
    p4_durable_json(RollbackPath,_{active:inactive,
        rolled_back_from:CandidateHash,history_preserved:true}),
    crypto_file_hash(Transport,ObservedTransportHash,
                     [algorithm(sha256),encoding(octet)]),
    ObservedTransportHash == TransportHash,
    Result=['p4-transport-observation',CandidateHash,TransportHash,
            1,0,true,true,true,Attempts,Creates,true,true,true,true,true,
            true,false,true,true].

p4_canonical_requests(Root,Port,Capability,Descriptor,
                      Receipt1,Receipt2,Attempts,Creates) :-
    p4_send(Root,Port,Capability,Capability.principal,Descriptor,Receipt1),
    p4_send(Root,Port,Capability,Capability.principal,Descriptor,Receipt2),
    p4_server_attempts(Attempts),
    findall(Receipt,p4_server_receipt(_,_,Receipt),Receipts),
    length(Receipts,Creates).

p4_severed(Root,'wrong-principal',Module,Data,Result) :-
    Config=Data.candidate_config,Effect=Data.effect,Capability=Data.capability,
    p4_initial_state(State0),
    call(Module:surface_effect(
        Config,State0,Effect,_State1,EffectOutcome)),
    get_dict(descriptor,EffectOutcome,Descriptor),
    p4_journal_path(Root,'effect-pending.json',PendingPath),
    p4_descriptor_identity(Descriptor,Capability,Identity),
    p4_durable_json(PendingPath,_{status:pending,identity:Identity}),
    setup_call_cleanup(p4_start_server(Capability,Port),
      (p4_send(Root,Port,Capability,'foreign-principal',Descriptor,Outcome),
       p4_server_attempts(Attempts)),p4_stop_server(Port)),
    Outcome == 'principal-not-authorized',Attempts =:= 0,
    Result=['p4-severed-observation','wrong-principal',0,
            'held-before-request'].
p4_severed(Root,'no-journal',Module,Data,Result) :-
    Config=Data.candidate_config,Effect=Data.effect,Capability=Data.capability,
    p4_initial_state(State0),
    call(Module:surface_effect(
        Config,State0,Effect,_State1,EffectOutcome)),
    get_dict(descriptor,EffectOutcome,Descriptor),
    setup_call_cleanup(p4_start_server(Capability,Port),
      (p4_send(Root,Port,Capability,Capability.principal,Descriptor,Outcome),
       p4_server_attempts(Attempts)),p4_stop_server(Port)),
    Outcome == 'journal-required',Attempts =:= 0,
    Result=['p4-severed-observation','no-journal',0,
            'held-before-request'].

p4_send(Root,Port,Capability,Principal,Descriptor,Outcome) :-
    ( Principal \== Capability.principal
    -> Outcome='principal-not-authorized'
    ; p4_journal_path(Root,'effect-pending.json',PendingPath),
      ( \+ exists_file(PendingPath)
      -> Outcome='journal-required'
      ; get_dict(method,Descriptor,Method),
        get_dict(path,Descriptor,Path),
        get_dict(body,Descriptor,Body),
        Method == Capability.method,
        Path == Capability.allowed_path,
        p4_descriptor_identity(Descriptor,Capability,Identity),
        p4_read_json(PendingPath,Pending),
        p4_value_atom(Pending.identity,PendingIdentity),
        PendingIdentity == Identity,
        format(string(URL),'http://127.0.0.1:~d~w',[Port,Path]),
        setup_call_cleanup(
          http_open(URL,In,[method(post),post(json(Body)),status_code(Status),
            timeout(10),redirect(false)]),
          json_read_dict(In,Reply),close(In)),
        memberchk(Status,[200,201]),
        p4_value_atom(Reply.receipt,Outcome)
      )
    ).

p4_start_server(Capability,Port) :-
    retractall(p4_server_config(_,_,_)),
    retractall(p4_server_receipt(_,_,_)),
    retractall(p4_server_attempts(_)),
    assertz(p4_server_attempts(0)),
    assertz(p4_server_config(Capability.allowed_path,Capability.principal,
                             Capability.identity_field)),
    http_server(p4_http_handler,[port(Port),workers(1)]).

p4_stop_server(Port) :- http_stop_server(Port,[]).

p4_http_handler(Request) :-
    with_mutex(p4_loopback,p4_increment_attempt),
    memberchk(method(post),Request),
    memberchk(path(Path0),Request),
    p4_value_atom(Path0,Path),
    p4_server_config(ExpectedPath,_Principal,IdentityField),
    Path == ExpectedPath,
    http_read_json_dict(Request,Body),
    get_dict(IdentityField,Body,Identity0),
    p4_value_atom(Identity0,Identity),
    with_mutex(p4_loopback,p4_receipt(Identity,Receipt,Status)),
    reply_json_dict(_{receipt:Receipt},[status(Status)]).

p4_increment_attempt :-
    retract(p4_server_attempts(Current)),Next is Current+1,
    assertz(p4_server_attempts(Next)).

p4_receipt(Identity,Receipt,200) :-
    p4_server_receipt(Identity,_Created,Receipt),!.
p4_receipt(Identity,Receipt,201) :-
    get_time(Created),term_hash(Identity,Hash),
    format(atom(Receipt),'loopback-receipt-~d',[Hash]),
    assertz(p4_server_receipt(Identity,Created,Receipt)).

p4_resume_worker(Root0,CandidateHash0,TransportHash0,Result) :-
    catch((maplist(p4_atom,[Root0,CandidateHash0,TransportHash0],
                              [Root,CandidateHash,TransportHash]),
           p4_root(Root),
           p4_journal_path(Root,'cursor.json',CursorPath),
           p4_journal_path(Root,'effect-confirmed.json',EffectPath),
           p4_journal_path(Root,'version-lab.json',VersionPath),
           maplist(p4_read_json,[CursorPath,EffectPath,VersionPath],
                                [Cursor,Effect,Version]),
           p4_value_atom(Cursor.schema,'surface-cursor-journal-v1'),
           p4_value_atom(Cursor.candidate_hash,CandidateHash),
           p4_value_atom(Cursor.transport_hash,TransportHash),
           p4_decode_ground_state(Cursor.state_term,ReconstructedState),
           get_dict(cursor,ReconstructedState,StateCursor),
           integer(Cursor.cursor),
           StateCursor =:= Cursor.cursor,
           p4_value_atom(Effect.candidate_hash,CandidateHash),
           p4_value_atom(Effect.transport_hash,TransportHash),
           p4_value_atom(Effect.status,confirmed),
           p4_value_atom(Version.active,CandidateHash),
           p4_journal_path(Root,'restart.json',RestartPath),
           p4_durable_json(RestartPath,_{verified:true,cursor:Cursor,
               effect:Effect,version:Version}),
           Result=verified),_,Result=failed),!.

p4_spawn_resume(Transport,Root,CandidateHash,TransportHash,Status) :-
    format(atom(Goal),
      'miter_surface_transport_lab_v1:p4_resume_worker(~q,~q,~q,R),R==verified,halt',
      [Root,CandidateHash,TransportHash]),
    process_create('/opt/homebrew/bin/swipl',
      ['-q','-f','none','-s',Transport,'-g',Goal],
      [stdin(null),stdout(null),stderr(null),process(Pid)]),
    process_wait(Pid,Status).

p4_descriptor_identity(Descriptor,Capability,Identity) :-
    get_dict(body,Descriptor,Body),
    get_dict(Capability.identity_field,Body,Identity),
    get_dict(idempotency_key,Descriptor,Identity).

p4_candidate_module(Candidate,Module) :-
    module_property(Module,file(Candidate)),
    current_predicate(Module:surface_ingest/5),
    current_predicate(Module:surface_effect/5),
    current_predicate(Module:surface_reconnect/4),
    current_predicate(Module:surface_panic/2),
    !.

p4_initial_state(_{cursor:0,seen:[],effects:[],panic:false}).
p4_status_reason(Dict,Status,Reason) :-
    get_dict(status,Dict,Status),get_dict(reason,Dict,Reason).

p4_root(Root) :-
    re_match('^/Users/claritymiter/miter/evidence/G31/p4-[0-9]{3}/[a-z-]+$',Root),
    exists_directory(Root),\+ read_link(Root,_,_).
p4_journal_path(Root,Name,Path) :-
    atom_concat(Root,'/',Prefix),atom_concat(Prefix,Name,Path).
p4_file_hash(Path,Expected) :-
    exists_file(Path),crypto_file_hash(Path,Expected,
      [algorithm(sha256),encoding(octet)]).

p4_durable_json(Path,Dict) :-
    miter_store_ensure_extension(
      '/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
    atom_concat(Path,'.tmp',Temporary),\+ exists_file(Temporary),
    setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
      (chmod(Temporary,0o600),json_write_dict(Stream,Dict,[width(0)]),nl(Stream),
       flush_output(Stream),miter_store_fsync_stream(Stream)),close(Stream)),
    rename_file(Temporary,Path).

p4_read_json(Path,Dict) :-
    setup_call_cleanup(open(Path,read,Stream,[encoding(utf8)]),
                       json_read_dict(Stream,Dict),close(Stream)).

p4_native(Dict,Native) :- is_dict(Dict),!,dict_pairs(Dict,Tag,Pairs),
    maplist(p4_native_pair,Pairs,NativePairs),dict_pairs(Native,Tag,NativePairs).
p4_native(List,Native) :- is_list(List),!,maplist(p4_native,List,Native).
p4_native(String,Atom) :- string(String),!,atom_string(Atom,String).
p4_native(Value,Value).
p4_native_pair(Key-Value,Key-Native) :- p4_native(Value,Native).

p4_value_atom(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)).
p4_atom(Value,Atom) :- p4_value_atom(Value,Atom),atom_length(Atom,Length),Length>0.

p4_encode_ground_state(State,StateTerm) :-
    p4_closed_state(State),
    copy_term(State,NumberedState),
    numbervars(NumberedState,0,_),
    term_string(NumberedState,StateTerm,
      [quoted(true),ignore_ops(true),numbervars(true)]).

p4_decode_ground_state(StateTerm0,State) :-
    p4_value_atom(StateTerm0,StateTermAtom),
    read_term_from_atom(StateTermAtom,State,[syntax_errors(error)]),
    p4_closed_state(State),
    p4_encode_ground_state(State,Reencoded),
    atom_string(StateTermAtom,Original),
    Reencoded == Original,
    read_term_from_atom(Reencoded,RoundTrip,[syntax_errors(error)]),
    State =@= RoundTrip.

% Anonymous SWI dictionaries have variable tags even when their values are
% closed. Admit that representation detail, but no variable in state data.
p4_closed_state(Value) :- var(Value),!,fail.
p4_closed_state(Value) :- atomic(Value),!.
p4_closed_state(Dict) :- is_dict(Dict,Tag),!,
    (var(Tag);atom(Tag)),
    dict_pairs(Dict,_,Pairs),
    maplist(p4_closed_pair,Pairs).
p4_closed_state(Compound) :- compound(Compound),
    Compound=..[_|Arguments],maplist(p4_closed_state,Arguments).
p4_closed_pair(_-Value) :- p4_closed_state(Value).

p4_error(Error,['p4-trial-failure',Text]) :-
    term_string(Error,Text,[quoted(true)]).
