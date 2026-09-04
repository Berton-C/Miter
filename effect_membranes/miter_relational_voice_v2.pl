% G33 R4 generalized relational-voice mechanics. Native MeTTa still forms the
% intention and audits meaning. This membrane confines one localhost rendering
% to an explicitly granted runtime root with a complete source manifest.
:- ensure_loaded('miter_store.pl').
:- ensure_loaded('miter_llm.pl').
:- use_module(library(time)).
:- dynamic rv2_worker/2, rv2_result/2.

rv2_repo('/Users/claritymiter/miter/').
rv2_required('CONSTITUTION.md').
rv2_required('MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md').
rv2_required('constitution/soul_compass_v02.metta').
rv2_required('src/participation.metta').
rv2_required('src/participation_support.metta').
rv2_required('src/grounded_language.metta').
rv2_required('src/bootstrap_grounded_language.metta').
rv2_required('src/relational_voice.metta').
rv2_required('src/bootstrap_relational_voice.metta').
rv2_required('effect_membranes/miter_language.pl').
rv2_required('effect_membranes/miter_relational_voice_v2.pl').
rv2_required('effect_membranes/miter_store.pl').
rv2_required('effect_membranes/miter_llm.pl').
rv2_required('config/relational-voice-runtime-grant-v1.json').
rv2_required('config/local/g03-model-profiles.json').

rv2_no_links(Path) :-
    \+ read_link(Path, _, _),
    file_directory_name(Path, Parent),
    ( Parent == Path -> true ; rv2_no_links(Parent) ).

rv2_root(Root0, Root) :-
    miter_store_nonempty_atom(Root0, Root),
    sub_atom(Root, 0, 1, _, '/'),
    \+ sub_atom(Root, _, _, _, '..'),
    exists_directory(Root),
    rv2_no_links(Root),
    absolute_file_name(Root, Canonical,
        [file_type(directory), access(write), file_errors(fail)]),
    Canonical == Root.

rv2_path(Root0, File0, Path) :-
    rv2_root(Root0, Root),
    miter_store_nonempty_atom(File0, File),
    re_match('^[A-Za-z0-9][A-Za-z0-9_.-]{0,95}$', File),
    \+ sub_atom(File, _, _, _, '..'),
    directory_file_path(Root, File, Path),
    \+ read_link(Path, _, _).

rv2_json(Path, Dict) :- catch(miter_store_read_json(Path, Dict), _, fail).
rv2_native(X, Y) :-
    ( string(X) -> atom_string(Y, X)
    ; is_list(X) -> maplist(rv2_native, X, Y)
    ; Y = X
    ).

rv2_write(Root, File, Dict) :-
    rv2_path(Root, File, Path),
    \+ exists_file(Path),
    miter_store_write_json_atomic(Path, Dict).

rv2_grant(Root, Id, Scope, Grant) :-
    rv2_path(Root, 'runtime-grant.json', GrantPath),
    exists_file(GrantPath),
    rv2_json(GrantPath, Grant),
    is_dict(Grant),
    dict_pairs(Grant, _, Pairs),
    pairs_keys(Pairs, [endpoint,expires_at_epoch,external_human_emission,
        issued_at_epoch,max_calls,model_alias,purpose,request_id,root,schema,scope]),
    miter_store_nonempty_atom(Grant.schema, 'miter-relational-voice-runtime-grant-v1'),
    miter_store_nonempty_atom(Grant.root, Root),
    miter_store_nonempty_atom(Grant.request_id, Id),
    rv2_native(Grant.scope, Scope),
    miter_store_nonempty_atom(Grant.purpose, 'bounded-relational-expression-rendering'),
    miter_store_nonempty_atom(Grant.model_alias, 'qwen-local'),
    miter_store_nonempty_atom(Grant.endpoint,
        'http://127.0.0.1:1234/v1/chat/completions'),
    Grant.max_calls =:= 1,
    Grant.external_human_emission == false,
    number(Grant.issued_at_epoch), number(Grant.expires_at_epoch),
    Grant.expires_at_epoch > Grant.issued_at_epoch,
    Grant.expires_at_epoch - Grant.issued_at_epoch =< 1800,
    get_time(Now),
    Grant.issued_at_epoch =< Now + 5,
    Grant.expires_at_epoch > Now.

rv2_manifest_entry(Files, Logical) :-
    findall(Entry,
        ( member(Entry, Files), is_dict(Entry),
          miter_store_nonempty_atom(Entry.logical_path, Logical)
        ), Matches),
    Matches = [Only],
    rv2_repo(Repo), atom_concat(Repo, Logical, Expected),
    miter_store_nonempty_atom(Only.path, Expected),
    exists_file(Expected), \+ read_link(Expected, _, _),
    crypto_file_hash(Expected, Hash, [algorithm(sha256), encoding(octet)]),
    atom_string(Hash, Only.sha256).

rv2_manifest(Root) :-
    rv2_path(Root, 'manifest.json', ManifestPath),
    exists_file(ManifestPath),
    rv2_json(ManifestPath, Manifest),
    is_dict(Manifest),
    miter_store_nonempty_atom(Manifest.schema,
        'miter-relational-voice-integrity-manifest-v2'),
    rv2_repo(Repo), miter_store_nonempty_atom(Manifest.source_root, Repo),
    is_list(Manifest.files),
    forall(rv2_required(Logical), rv2_manifest_entry(Manifest.files, Logical)).

rv2_verified(Root0, Id, Scope, Grant) :-
    rv2_root(Root0, Root),
    rv2_grant(Root, Id, Scope, Grant),
    rv2_manifest(Root).

rv2_authority_status(Root0, Id, Scope, Status) :-
    ( rv2_root(Root0, Root)
    -> ( rv2_grant(Root, Id, Scope, _)
       -> ( rv2_manifest(Root)
          -> Status = 'runtime-authority-verified'
          ;  Status = 'runtime-integrity-manifest-invalid'
          )
       ;  Status = 'runtime-grant-invalid'
       )
    ;  Status = 'runtime-root-invalid'
    ).

rv_save_intention(Root, Intention, Result) :-
    ( Intention = ['voice-intention',Id,Scope,_,_,_,_]
    -> rv2_authority_status(Root, Id, Scope, Standing),
       ( Standing == 'runtime-authority-verified'
       -> catch((get_time(T),
                 rv2_write(Root, 'intention.json',
                   _{native:Intention,request_id:Id,scope:Scope,stored_at:T})
                -> Result = 'intention-stored'
                ;  Result = 'intention-storage-failed'), Error,
                (term_string(Error,Text),Result=['intention-storage-error',Text]))
       ;  Result = Standing
       )
    ;  Result = 'intention-invalid'
    ), !.

rv_start(Root, Request, Result) :-
    catch((rv2_start_checked(Root, Request)
          -> Result = 'worker-started'
          ;  Result = 'request-preparation-failed'), Error,
          (term_string(Error, Text), Result = ['request-preparation-error',Text])), !.

rv2_start_checked(Root, Request) :-
    Request = ['render-request',Id,Scope,Alias,Tokens,Deadline,Instructions,
               Claims,Names,Standing],
    rv2_verified(Root, Id, Scope, Grant),
    Alias == 'qwen-local', integer(Tokens), Tokens > 0, Tokens =< 1024,
    Deadline > 0, Deadline =< 120,
    \+ rv2_worker(Root, _),
    rv2_path(Root, 'worker-started.json', StartedPath), \+ exists_file(StartedPath),
    rv2_path(Root, 'intention.json', IntentionPath), rv2_json(IntentionPath, Stored),
    rv2_native(Stored.native, Native), Native = ['voice-intention',Id,Scope|_],
    Grant.max_calls =:= 1,
    rv2_write(Root, 'native-request.json', _{native:Request}),
    atom_string(Id, IdString),
    Schema = _{type:"object",properties:_{
        request_id:_{type:"string",const:IdString},
        clauses:_{type:"array",minItems:1,maxItems:8,
          items:_{type:"string",minLength:1,maxLength:512}}},
        required:["request_id","clauses"],additionalProperties:false},
    with_output_to(string(User), json_write_dict(current_output,
        _{request_id:IdString,intended_relations:Claims,names:Names,standing:Standing},
        [width(0)])),
    Template = _{schema:"miter-schema-request-v1",request_id:IdString,
        endpoint:"http://127.0.0.1:1234/v1/chat/completions",
        body:_{messages:[_{role:"system",content:Instructions},
                         _{role:"user",content:User}],
        response_format:_{type:"json_schema",json_schema:_{
          name:"miter_relational_expression",strict:true,schema:Schema}},
        temperature:0,top_p:1,reasoning_effort:"none",max_tokens:Tokens,
        seed:5050,stream:false,ttl:300}},
    rv2_write(Root, 'template.json', Template),
    rv2_path(Root, 'template.json', TemplatePath),
    rv2_path(Root, 'request.json', RequestPath),
    miter_lm_prepare_request(
      '/Users/claritymiter/miter/config/local/g03-model-profiles.json',
      Alias, TemplatePath, RequestPath, 'model-request-prepared'),
    thread_create(rv2_worker_body(Root,Id,Scope,RequestPath,Deadline), Thread, []),
    assertz(rv2_worker(Root,Thread)),
    get_time(T),
    rv2_write(Root, 'worker-started.json',
      _{request_id:Id,started_at:T,deadline_seconds:Deadline}).

rv2_worker_body(Root, Id, Scope, RequestPath, Deadline) :-
    catch(call_with_time_limit(Deadline,
          rv2_fetch(Root,Id,Scope,RequestPath,Outcome)), Error,
          rv2_error(Error,Outcome)),
    retractall(rv2_result(Root,_)), assertz(rv2_result(Root,Outcome)),
    get_time(T),
    catch(rv2_write(Root,'transport-result.json',
      _{result:Outcome,finished_at:T}),_,true).

rv2_error(time_limit_exceeded, 'model-timeout') :- !.
rv2_error(cancelled, cancelled) :- !.
rv2_error(error(socket_error(_,_),_), 'provider-unavailable') :- !.
rv2_error(error(timeout_error(_,_),_), 'model-timeout') :- !.
rv2_error(Error, ['transport-error',Text]) :- term_string(Error,Text).

rv2_fetch(Root, Id, Scope, RequestPath, Outcome) :-
    rv2_path(Root,'raw.json',Raw), rv2_path(Root,'timing.json',Timing),
    miter_lm_execute_request_checked(RequestPath,Raw,Timing,Status),
    ( Status == 'raw-model-response-stored'
    -> rv2_parse(Root,Id,Scope,Raw,Outcome)
    ;  Outcome = ['provider-incomplete',Status]
    ).

rv2_parse(Root,Id,Scope,Raw,Outcome) :-
    ( catch(rv2_json(Raw,Dict),_,fail)
    -> rv2_parse_document(Root,Id,Scope,Raw,Dict,Outcome)
    ;  Outcome = 'malformed-provider-envelope'
    ).

rv2_parse_document(_,_,_,_,Dict,'model-truncated') :-
    get_dict(choices,Dict,[Choice|_]),
    get_dict(finish_reason,Choice,"length"), !.
rv2_parse_document(_,_,_,_,Dict,'model-refusal') :-
    get_dict(choices,Dict,[Choice|_]), get_dict(message,Choice,Message),
    get_dict(refusal,Message,Refusal), string(Refusal),
    string_length(Refusal,Length), Length > 0, !.
rv2_parse_document(Root,Id,Scope,Raw,Dict,Outcome) :-
    ( catch((miter_lm_provider_product(Dict,Product),
             dict_pairs(Product,_,Pairs), pairs_keys(Pairs,[clauses,request_id]),
             atom_string(Id,Product.request_id), is_list(Product.clauses),
             length(Product.clauses,N), N > 0, N =< 8,
             forall(member(Clause,Product.clauses),
               (string(Clause),string_length(Clause,L),L > 0,L =< 512))),_,fail)
    -> Outcome = [rendered,Id,Scope,Product.clauses,Raw],
       rv2_write(Root,'candidate.json',_{request_id:Id,scope:Scope,
         clauses:Product.clauses,raw_ref:Raw,origin:"model-rendering"})
    ;  Outcome = 'malformed-model-output'
    ).

rv_control(Root, Event) :-
    ( rv2_path(Root,'control.json',Path), exists_file(Path),
      catch(rv2_json(Path,Dict),_,fail), rv2_native(Dict.event,Observed)
    -> Event = Observed ; Event = none ).
rv_poll(Root, Result) :- (rv2_result(Root,Found)->Result=Found;Result=pending).
rv_pace(Seconds, waited) :- number(Seconds),Seconds>=0,Seconds=<0.1,sleep(Seconds).
rv_cancel(Root, Result) :-
    get_time(T), rv2_write(Root,'stop-observed.json',_{observed_at:T}),
    ( retract(rv2_worker(Root,Thread))
    -> catch(thread_signal(Thread,throw(cancelled)),_,true),
       catch(thread_detach(Thread),_,true), Result='worker-cancel-requested'
    ;  Result='no-active-worker'
    ).
rv_save_result(Root, Native, Result) :-
    catch((get_time(T),
           rv2_write(Root,'native-result.json',_{native:Native,stored_at:T})
          -> Result='native-result-stored';Result='result-storage-failed'),_,
          Result='result-storage-failed'), !.
