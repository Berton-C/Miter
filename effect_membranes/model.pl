% Bounded model transport for the continuously cycling assistant.
%
% This membrane may carry one exact, Soul-formed semantic question to an
% explicitly granted resource and translate a strict JSON reply into typed
% candidate carriers.  It cannot form the question, classify R/A/P, select a
% candidate, certify a movement, read memory, or produce an external effect.

:- ensure_loaded('assistant_service.pl').
:- use_module(library(http/http_open)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(time)).
:- use_module(library(ordsets)).

as_model(Root0, Question, Observation) :-
    catch((as_model_checked(Root0, Question, Observation0) -> true
          ; throw(error(model_boundary_hold,_))), Error,
      as_model_unavailable(Question, Error, Observation0)),
    Observation=Observation0, !.

as_model_checked(Root0, Question, Observation) :-
    as_root(Root0, Root),
    ground(Question),
    as_model_question_carrier(Question, QuestionRef, Scope, Instructions,
      ResourceId, MaxTokens, Deadline),
    as_model_question_sha256(Question, QuestionHash),
    as_model_observation_path(Root, QuestionHash, ObservationPath),
    ( exists_file(ObservationPath) ->
        as_model_read_observation(ObservationPath, Observation)
    ; as_model_claim_path(Root, QuestionHash, ClaimPath),
      ( exists_directory(ClaimPath) ->
          as_model_unavailable(Question, uncertain_prior_transmission,
            Observation)
      ; as_model_profile(Root, ResourceId, Profile),
        as_model_grant(Root, QuestionHash, Scope, ResourceId, MaxTokens,
          Deadline, Grant),
        as_model_claim(Root, QuestionHash, QuestionRef, Scope, ResourceId,
          Grant, ClaimPath),
        as_model_request(Profile, Question, Instructions, MaxTokens, Body),
        as_model_write_request(Root, QuestionHash, QuestionRef, Scope,
          ResourceId, Profile, Body),
        as_model_keychain(Profile, Key),
        as_model_execute(Root, QuestionHash, QuestionRef, Scope, Question,
          ResourceId, Profile, Body, Key, Deadline, Observation0),
        as_model_write_observation(ObservationPath, Observation0),
        Observation=Observation0
      )
    ).

as_model_question_carrier(
    ['c3-semantic-question-v1', QuestionRef, Scope, _, _,
     ['partial-openings', Openings],
     ['fact9-participation', FactSurfaces,
       'finite-partial-non-reconstructive'],
     ['flourishing-participation', FlourishingSurfaces,
       'interconnected-non-compensatory'],
     ['uncertainty',
       'relations-that-could-disclose-fuller-alignment-without-overwriting-what-is-aligned',
       ['returned-contact-material',ReturnedMaterial]],
     ['request-contract', Instructions, 'public-safe-only',
       'candidate-possibilities-not-verdict',
       'no-contact-no-authority-no-choice'],
     ['resource-request', ResourceId,
       'human-preferred-default-not-cognitive-authority',
       'semantic-reading', MaxTokens, Deadline]],
    QuestionRef, Scope, Instructions, ResourceId, MaxTokens, Deadline) :-
    QuestionRef=['question-reference', ConsequenceId, 'partial-rap-alignment'],
    as_symbol(ConsequenceId,_),
    as_local_scope(Scope),
    is_list(Openings), Openings=[_|_],
    as_model_openings_valid(Openings),
    as_model_fact_surfaces_valid(FactSurfaces,Openings),
    as_model_flourishing_surfaces_valid(FlourishingSurfaces,Openings),
    as_model_returned_material_valid(ReturnedMaterial),
    string(Instructions), string_length(Instructions, InstructionLength),
    InstructionLength>=100, InstructionLength=<4096,
    ResourceId='openrouter-glm53', MaxTokens=2048, Deadline=120.

as_model_returned_material_valid(Material) :-
    is_list(Material), Material=['c3-returned-material-v1'|_],
    length(Material,9), ground(Material),
    term_string(Material,Text,[quoted(true),ignore_ops(true)]),
    string_length(Text,Length), Length=<65536.

as_model_openings_valid(Openings) :-
    maplist(as_model_opening_valid, Openings),
    maplist(as_model_opening_identity, Openings, Identities),
    sort(Identities, Unique), same_length(Identities, Unique).

as_model_opening_identity(
    ['c3-partial-alignment-opening-v2', MovementRef, RapRef, SourceCut,
     _, _, _, _, 'unresolved-is-generative-opening-not-deficit'],
    [MovementRef,RapRef,SourceCut]).

as_model_opening_movement(
    ['c3-partial-alignment-opening-v2',MovementRef|_],MovementRef).

as_model_fact_surfaces_valid(Surfaces,Openings) :-
    is_list(Surfaces), Surfaces=[_|_],
    maplist(as_model_fact_surface_valid_for(Openings),Surfaces),
    maplist(as_model_surface_movement,Surfaces,MovementRefs0),
    maplist(as_model_opening_movement,Openings,OpeningRefs0),
    sort(MovementRefs0,MovementRefs), sort(OpeningRefs0,OpeningRefs),
    same_length(MovementRefs0,MovementRefs), MovementRefs==OpeningRefs.

as_model_fact_surface_valid_for(Openings,
    ['fact9-inquiry-surface',MovementRef,['fact9-material',Entries]]) :-
    MovementRef=['movement-reference',_,_],
    member(Opening,Openings),
    as_model_opening_movement(Opening,MovementRef),
    as_model_opening_material(Opening,RequiredRelations,_),
    is_list(Entries), Entries=[_|_], maplist(as_model_fact_entry,Entries),
    forall((member(Entry,Entries),Entry=[_,_,_,['material-relations',Relations]],
            member(Relation,Relations)),memberchk(Relation,RequiredRelations)).

as_model_fact_entry(
    ['fact9-inquiry-entry',Id,['roles',Roles],
      ['material-relations',Relations]]) :-
    as_symbol(Id,_), is_list(Roles), Roles=[_|_],
    maplist(as_model_fact9_role,Roles), sort(Roles,Roles),
    is_list(Relations), Relations=[_|_], maplist(as_symbol,Relations,_),
    sort(Relations,Relations).

as_model_fact9_role(Role) :-
    memberchk(Role,['Balance','Connection','Effortlessness','Gravity','Love',
      'Precision','Sacred','Transformation']).

as_model_flourishing_surfaces_valid(Surfaces,Openings) :-
    is_list(Surfaces), Surfaces=[_|_],
    maplist(as_model_flourishing_surface_valid_for(Openings),Surfaces),
    maplist(as_model_surface_movement,Surfaces,MovementRefs0),
    maplist(as_model_opening_movement,Openings,OpeningRefs0),
    sort(MovementRefs0,MovementRefs), sort(OpeningRefs0,OpeningRefs),
    same_length(MovementRefs0,MovementRefs), MovementRefs==OpeningRefs.

as_model_flourishing_surface_valid_for(Openings,
    ['flourishing-inquiry-surface',MovementRef,
      ['flourishing-material',Entries]]) :-
    MovementRef=['movement-reference',_,_],
    member(Opening,Openings),
    as_model_opening_movement(Opening,MovementRef),
    as_model_opening_material(Opening,_,RequiredFlourishings),
    is_list(Entries), Entries=[_|_],
    maplist(as_model_flourishing_entry,Entries),
    maplist(as_model_flourishing_entry_value,Entries,Values),
    sort(Values,Unique), same_length(Values,Unique),
    sort(RequiredFlourishings,RequiredUnique),
    same_length(RequiredFlourishings,RequiredUnique),
    Unique==RequiredUnique.

as_model_flourishing_entry(
    ['flourishing-inquiry-entry',Value,
      ['current-relational-standings',Standings]]) :-
    as_flourishing(Value), is_list(Standings), Standings=[_|_],
    maplist(as_model_flourishing_standing,Standings).

as_model_flourishing_standing(
    ['flourishing-standing',Relation,Standing,Evidence]) :-
    as_symbol(Relation,_), as_symbol(Standing,_), as_symbol(Evidence,_).

as_model_flourishing_entry_value(
    ['flourishing-inquiry-entry',Value,_],Value).

as_model_surface_movement([_,MovementRef,_],MovementRef).

as_model_opening_valid(
    ['c3-partial-alignment-opening-v2', _, _, _, ['preserve', Preserve],
     ['explore', Explore], Constitutive, Provenance,
     'unresolved-is-generative-opening-not-deficit']) :-
    Constitutive=['constitutive-participation-reference',
      'movement-primary-at-contact',
      ['rap-perspective-contract','one-contact-movement-surface',
        'simultaneous-relatedness-appropriateness-precision'],_],
    Provenance=['provenance-reference',_,_],
    as_model_opening_material(
      ['c3-partial-alignment-opening-v2', _, _, _, ['preserve', Preserve],
       ['explore', Explore], Constitutive, Provenance,
       'unresolved-is-generative-opening-not-deficit'],_,_),
    as_model_perspective_set(Preserve), as_model_perspective_set(Explore),
    Preserve=[_|_], Explore=[_|_],
    ord_intersection(Preserve, Explore, []),
    append(Preserve,Explore,Combined), sort(Combined,All),
    All==['Appropriateness','Precision','Relatedness'].

as_model_opening_material(
    ['c3-partial-alignment-opening-v2',_,_,_,_,_,
      ['constitutive-participation-reference',_,_,
        ['source-constitutive-material-v1',
          ['required-relations',Relations],
          ['required-flourishings',Flourishings]]],_,_],
    Relations,Flourishings) :-
    is_list(Relations), Relations=[_|_], maplist(as_symbol,Relations,_),
    sort(Relations,UniqueRelations), same_length(Relations,UniqueRelations),
    is_list(Flourishings), Flourishings=[_|_],
    maplist(as_flourishing,Flourishings),
    sort(Flourishings,UniqueFlourishings),
    same_length(Flourishings,UniqueFlourishings).

as_model_perspective_set(Values) :-
    is_list(Values), maplist(as_model_perspective, Values),
    sort(Values, Unique), same_length(Values, Unique).
as_model_perspective(Value) :-
    memberchk(Value,['Appropriateness','Precision','Relatedness']).

as_model_question_sha256(Question, Hash) :-
    term_string(Question, Text, [quoted(true),ignore_ops(true)]),
    crypto_data_hash(Text, Hash, [algorithm(sha256),encoding(utf8)]).

as_model_profile(Root, ResourceId, Profile) :-
    as_path(Root,'model-resources.json',Path),
    miter_store_read_json(Path,Registry),
    is_dict(Registry),
    as_dict_atom(Registry,schema,'miter-model-resource-registry-v1'),
    get_dict(human_editable,Registry,true),
    as_model_secret_free(Registry),
    get_dict(resources,Registry,Resources), is_list(Resources),
    findall(P,(member(P,Resources),is_dict(P),
      as_dict_atom(P,id,ResourceId)),[Profile]),
    as_model_profile_exact(Profile).

as_model_profile_exact(Profile) :-
    as_dict_atom(Profile,id,'openrouter-glm53'),
    as_dict_atom(Profile,kind,remote), get_dict(enabled,Profile,true),
    as_dict_atom(Profile,adapter,'openrouter-chat-completions'),
    get_dict(model,Profile,"z-ai/glm-5.3"),
    get_dict(endpoint,Profile,"https://openrouter.ai/api/v1/chat/completions"),
    get_dict(roles,Profile,["semantic-reading"]),
    get_dict(reasoning_effort,Profile,"high"),
    get_dict(limits,Profile,Limits), is_dict(Limits),
    get_dict(max_output_tokens,Limits,2048),
    get_dict(deadline_seconds,Limits,120),
    get_dict(capture_bytes,Limits,262144),
    get_dict(provider,Profile,Provider), is_dict(Provider),
    get_dict(zdr,Provider,true), get_dict(data_collection,Provider,"deny"),
    get_dict(require_parameters,Provider,true),
    get_dict(allow_fallbacks,Provider,true),
    get_dict(credential_reference,Profile,Credential), is_dict(Credential),
    get_dict(source,Credential,"macos-keychain"),
    get_dict(account,Credential,"bcb"),
    get_dict(service,Credential,"ai.bgi.miter.openrouter").

as_model_secret_free(Dict) :-
    is_dict(Dict), !, dict_pairs(Dict,_,Pairs),
    forall(member(Key-Value,Pairs),
      ( \+ memberchk(Key,[api_key,token,secret,password,authorization]),
        as_model_secret_free(Value) )).
as_model_secret_free(List) :-
    is_list(List), !, maplist(as_model_secret_free,List).
as_model_secret_free(String) :-
    string(String), !, \+ sub_string(String,_,_,_,"sk-or-v1-").
as_model_secret_free(_).

as_model_grant(Root, QuestionHash, Scope, ResourceId, MaxTokens, Deadline,
    Grant) :-
    as_path(Root,'model-grants.json',Path),
    miter_store_read_json(Path,Document), is_dict(Document),
    as_dict_atom(Document,schema,'miter-model-grants-v1'),
    as_dict_atom(Document,standing,'active-explicit-grants'),
    as_model_secret_free(Document),
    get_dict(grants,Document,Grants), is_list(Grants),
    findall(G,(member(G,Grants),is_dict(G),
      as_model_grant_exact(G,QuestionHash,Scope,ResourceId,MaxTokens,Deadline)),
      [Grant]).

as_model_grant_exact(Grant,QuestionHash,[scope,Principal,Audience,Project],
    ResourceId,MaxTokens,Deadline) :-
    as_dict_atom(Grant,id,_), as_dict_atom(Grant,standing,active),
    as_dict_atom(Grant,resource_id,ResourceId),
    as_dict_atom(Grant,purpose,'semantic-reading'),
    get_dict(question_sha256,Grant,Hash0), as_sha256(Hash0,QuestionHash),
    get_dict(scope,Grant,Scope), is_dict(Scope),
    as_dict_atom(Scope,principal,Principal),
    as_dict_atom(Scope,audience,Audience),
    as_dict_atom(Scope,project,Project),
    get_dict(max_calls,Grant,1),
    get_dict(max_output_tokens,Grant,MaxTokens),
    get_dict(deadline_seconds,Grant,Deadline),
    get_dict(public_safe_only,Grant,true),
    get_dict(expires_at_epoch,Grant,Expiry), number(Expiry),
    get_time(Now), Now=<Expiry.

as_model_claim_path(Root, Hash, Path) :-
    atomic_list_concat(['model/claims/',Hash,'.claim'],Relative),
    as_path(Root,Relative,Path).
as_model_observation_path(Root, Hash, Path) :-
    atomic_list_concat(['model/observations/',Hash,'.term'],Relative),
    as_path(Root,Relative,Path).
as_model_named_json(Root, Directory, Hash, Path) :-
    atomic_list_concat(['model/',Directory,'/',Hash,'.json'],Relative),
    as_path(Root,Relative,Path).
as_model_named_text(Root, Directory, Hash, Path) :-
    atomic_list_concat(['model/',Directory,'/',Hash,'.txt'],Relative),
    as_path(Root,Relative,Path).

as_model_claim(_Root, Hash, QuestionRef, Scope, ResourceId, Grant, ClaimPath) :-
    \+ exists_directory(ClaimPath), make_directory(ClaimPath),
    directory_file_path(ClaimPath,'owner.json',Owner),
    as_dict_atom(Grant,id,GrantId), get_time(Now),
    term_string(QuestionRef,QuestionRefText,[quoted(true),ignore_ops(true)]),
    term_string(Scope,ScopeText,[quoted(true),ignore_ops(true)]),
    as_write_json_durable(Owner,_{schema:"miter-model-spend-claim-v1",
      question_sha256:Hash,question_reference:QuestionRefText,
      scope:ScopeText,resource_id:ResourceId,grant_id:GrantId,
      standing:"claimed-before-transmission",claimed_at_epoch:Now}).

as_model_request(Profile, Question, Instructions, MaxTokens, Body) :-
    term_string(Question,QuestionText,[quoted(true),ignore_ops(true)]),
    with_output_to(string(User), json_write_dict(current_output,
      _{native_question:QuestionText,
        interpretation_boundary:"Derived readings only. Miter retains contact, authority, comparison, movement, and consequence interpretation."},
      [width(0)])),
    get_dict(model,Profile,Model),
    get_dict(reasoning_effort,Profile,Reasoning),
    get_dict(provider,Profile,Provider),
    Body=_{model:Model,messages:[_{role:"system",content:Instructions},
      _{role:"user",content:User}],temperature:0,top_p:1,
      max_tokens:MaxTokens,reasoning_effort:Reasoning,stream:false,
      provider:Provider},
    as_model_request_valid(Body).

as_model_request_valid(Body) :-
    is_dict(Body), dict_pairs(Body,_,Pairs), pairs_keys(Pairs,Keys),
    Keys==[max_tokens,messages,model,provider,reasoning_effort,stream,
      temperature,top_p],
    Body.model=="z-ai/glm-5.3", Body.max_tokens=:=2048,
    Body.reasoning_effort=="high", Body.stream==false,
    Body.temperature=:=0, Body.top_p=:=1,
    Body.messages=[System,User], System.role=="system", User.role=="user",
    string(System.content), string(User.content),
    is_dict(Body.provider), Body.provider.zdr==true,
    Body.provider.data_collection=="deny",
    Body.provider.require_parameters==true,
    Body.provider.allow_fallbacks==true,
    \+ get_dict(authorization,Body,_).

as_model_write_request(Root,Hash,QuestionRef,Scope,ResourceId,Profile,Body) :-
    as_model_named_json(Root,requests,Hash,Path), \+ exists_file(Path),
    term_string(QuestionRef,QuestionRefText,[quoted(true),ignore_ops(true)]),
    term_string(Scope,ScopeText,[quoted(true),ignore_ops(true)]),
    as_write_json_durable(Path,_{schema:"miter-model-request-v1",
      question_sha256:Hash,question_reference:QuestionRefText,scope:ScopeText,
      resource_id:ResourceId,endpoint:Profile.endpoint,body:Body,
      authorization:"macos-keychain-redacted",
      standing:"claimed-not-yet-observed"}).

as_model_keychain(Profile,Key) :-
    Credential=Profile.credential_reference,
    process_create('/usr/bin/security',
      ['find-generic-password','-a',Credential.account,'-s',Credential.service,
       '-w'],
      [stdin(null),stdout(pipe(Out)),stderr(null),process(Pid)]),
    read_string(Out,1024,Raw), close(Out),
    process_wait(Pid,exit(0),[timeout(15)]),
    normalize_space(string(Key),Raw), string_length(Key,Length),
    Length>=16, Length=<512.

as_model_execute(Root,Hash,QuestionRef,Scope,Question,ResourceId,Profile,Body,
    Key,Deadline,Observation) :-
    string_concat("Bearer ",Key,Authorization), get_time(Start),
    catch(call_with_time_limit(Deadline,
      setup_call_cleanup(
        http_open(Profile.endpoint,In,
          [method(post),post(json(Body)),status_code(Status),timeout(Deadline),
           redirect(false),request_header('Authorization'=Authorization),
           request_header('Content-Type'='application/json'),
           request_header('Accept'='application/json')]),
        read_string(In,262145,Captured),close(In))),Error,true),
    get_time(End), ElapsedMs is round((End-Start)*1000),
    ( var(Error) ->
        string_length(Captured,Bytes),
        ( Bytes=<262144 -> Raw=Captured, Transport=eof, ErrorClass=none
        ; sub_string(Captured,0,262144,_,Raw), Transport='capture-limit',
          ErrorClass='response-truncated' )
    ; Raw="", Bytes=0,
      as_model_error_class(Error,Transport,ErrorClass), Status=0 ),
    as_model_named_text(Root,raw,Hash,RawPath),
    as_model_write_text_durable(RawPath,Raw),
    crypto_data_hash(Raw,RawHash,[algorithm(sha256),encoding(utf8)]),
    ( Transport==eof, Status=:=200 ->
        ( as_model_provider_response(Raw,Question,Candidates,Finish,Usage) ->
            Observation=['c3-model-observation-v1',QuestionRef,Scope,ResourceId,
              'z-ai/glm-5.3',['transport',eof],['http-status',200],
              ['finish-reason',Finish],['raw-sha256',RawHash],
              [candidates,Candidates],Usage,
              'provider-reading-no-contact-no-authority-no-choice']
        ; as_model_provider_failure(Raw,Failure),
          throw(error(model_provider_hold(Failure,ElapsedMs,Bytes),_)) )
    ; throw(error(model_transport_or_schema_hold(Transport,Status,ErrorClass,
        ElapsedMs,Bytes),_)) ).

as_model_provider_failure(Raw,'provider-output-truncated') :-
    catch(atom_json_dict(Raw,Response,[]),_,fail), is_dict(Response),
    get_dict(choices,Response,[Choice]), is_dict(Choice),
    as_dict_atom(Choice,finish_reason,length), !.
as_model_provider_failure(Raw,'provider-finish-held') :-
    catch(atom_json_dict(Raw,Response,[]),_,fail), is_dict(Response),
    get_dict(choices,Response,[Choice]), is_dict(Choice),
    get_dict(finish_reason,Choice,_), !.
as_model_provider_failure(Raw,'provider-artifact-malformed') :-
    catch(atom_json_dict(Raw,Response,[]),_,fail), is_dict(Response), !.
as_model_provider_failure(_,'provider-envelope-malformed').

as_model_error_class(time_limit_exceeded,timeout,'deadline-exceeded') :- !.
as_model_error_class(error(timeout_error(_,_),_),timeout,
    'deadline-exceeded') :- !.
as_model_error_class(_,transport_error,'redacted-transport-error').

as_model_provider_response(Raw,Question,Candidates,Finish,Usage) :-
    atom_json_dict(Raw,Response,[]), is_dict(Response),
    get_dict(model,Response,"z-ai/glm-5.3"),
    get_dict(choices,Response,[Choice]), is_dict(Choice),
    as_dict_atom(Choice,finish_reason,Finish), Finish==stop,
    get_dict(message,Choice,Message), is_dict(Message),
    get_dict(content,Message,Content), string(Content),
    \+ sub_string(Content,_,_,_,"```"),
    atom_json_dict(Content,Result,[]), as_model_result(Result,Candidates),
    as_model_candidates_match_question(Candidates,Question),
    as_model_usage(Response,Usage).

as_model_candidates_match_question(Candidates,
    ['c3-semantic-question-v1',_,_,_,_,['partial-openings',Openings]|_]) :-
    forall(member(Candidate,Candidates),
      (member(Opening,Openings),as_model_candidate_matches_opening(Candidate,Opening))),
    forall(member(Opening,Openings),
      (member(Candidate,Candidates),as_model_candidate_matches_opening(Candidate,Opening))).

as_model_candidate_matches_opening(
    ['c3-model-candidate-v1',_,_,['preserve',Preserve],['explore',Explore]|_],
    ['c3-partial-alignment-opening-v2',_,_,_,['preserve',OpeningPreserve],
      ['explore',OpeningExplore]|_]) :-
    sort(Preserve, PreserveSet), sort(OpeningPreserve, OpeningPreserveSet),
    sort(Explore, ExploreSet), sort(OpeningExplore, OpeningExploreSet),
    PreserveSet==OpeningPreserveSet, ExploreSet==OpeningExploreSet.

as_model_result(Result,Candidates) :-
    is_dict(Result), as_model_exact_keys(Result,[candidates,uncertainty]),
    get_dict(uncertainty,Result,Uncertainty),
    as_model_bounded_text(Uncertainty,1,1000),
    get_dict(candidates,Result,Rows), is_list(Rows),
    length(Rows,Count), between(2,3,Count),
    maplist(as_model_candidate,Rows,Candidates),
    maplist(as_model_candidate_id,Candidates,Ids),
    sort(Ids,Unique), same_length(Ids,Unique).

as_model_candidate(Row,
    ['c3-model-candidate-v1',Id,Summary,['preserve',Preserve],
      ['explore',Explore],Counterfactual,'model-proposal-only']) :-
    is_dict(Row), as_model_exact_keys(Row,
      [counterfactual,explore,preserve,summary]),
    get_dict(summary,Row,Summary), as_model_bounded_text(Summary,1,1200),
    get_dict(counterfactual,Row,Counterfactual),
    as_model_bounded_text(Counterfactual,1,1200),
    get_dict(preserve,Row,Preserve0),
    get_dict(explore,Row,Explore0),
    maplist(as_model_perspective_string_atom,Preserve0,Preserve1),
    maplist(as_model_perspective_string_atom,Explore0,Explore1),
    sort(Preserve1,Preserve), sort(Explore1,Explore),
    same_length(Preserve0,Preserve), same_length(Explore0,Explore),
    Preserve=[_|_], Explore=[_|_], ord_intersection(Preserve,Explore,[]),
    append(Preserve,Explore,Combined), sort(Combined,All),
    All==['Appropriateness','Precision','Relatedness'],
    with_output_to(string(Canonical),json_write_dict(current_output,Row,
      [width(0)])),
    crypto_data_hash(Canonical,Hash,[algorithm(sha256),encoding(utf8)]),
    sub_atom(Hash,0,24,_,Prefix), atom_concat('model-candidate-',Prefix,Id).

as_model_candidate_id(['c3-model-candidate-v1',Id|_],Id).

as_model_perspective_string_atom(String,Atom) :-
    string(String), atom_string(Atom,String), as_model_perspective(Atom).

as_model_bounded_text(Text,Min,Max) :-
    string(Text), string_length(Text,Length), Length>=Min, Length=<Max,
    string_codes(Text,Codes), \+ member(0,Codes).

as_model_usage(Response,['usage',Prompt,Completion,Total,Cost]) :-
    ( get_dict(usage,Response,U), is_dict(U) ->
        as_model_number(U,prompt_tokens,Prompt),
        as_model_number(U,completion_tokens,Completion),
        as_model_number(U,total_tokens,Total),
        as_model_number(U,cost,Cost)
    ; Prompt=0, Completion=0, Total=0, Cost=0 ).
as_model_number(Dict,Key,Number) :-
    ( get_dict(Key,Dict,Value), number(Value) -> Number=Value ; Number=0 ).

as_model_exact_keys(Dict,Expected) :-
    dict_pairs(Dict,_,Pairs), pairs_keys(Pairs,Keys),
    sort(Keys,Sorted), sort(Expected,Sorted).

as_model_write_observation(Path,Observation) :-
    \+ exists_file(Path), as_write_term_atomic(Path,Observation).
as_model_read_observation(Path,Observation) :-
    setup_call_cleanup(open(Path,read,Stream,[encoding(utf8)]),
      read_term(Stream,Observation,[syntax_errors(error)]),close(Stream)),
    ground(Observation), Observation=['c3-model-observation-v1'|_].

as_model_write_text_durable(Path,Text) :-
    \+ exists_file(Path), file_directory_name(Path,Directory),
    make_directory_path(Directory), current_prolog_flag(pid,Pid),
    format(atom(Suffix),'.tmp.~d',[Pid]), atom_concat(Path,Suffix,Temporary),
    setup_call_cleanup(true,
      (setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
        (chmod(Temporary,0o600),format(Stream,'~s',[Text]),flush_output(Stream),
         miter_store_fsync_stream(Stream)),close(Stream)),
       rename_file(Temporary,Path)),
      (exists_file(Temporary)->delete_file(Temporary);true)).

as_model_unavailable(Question,Error,
    ['c3-model-observation-unavailable-v1',QuestionRef,Scope,
      'openrouter-glm53',Reason,'no-candidate-admitted']) :-
    ( Question=['c3-semantic-question-v1',QuestionRef,Scope|_] -> true
    ; QuestionRef=['question-reference',unknown,'partial-rap-alignment'],
      Scope=[scope,unknown,unknown,unknown] ),
    as_model_failure_reason(Error,Reason).

as_model_failure_reason(uncertain_prior_transmission,
    'uncertain-prior-transmission-no-replay') :- !.
as_model_failure_reason(error(model_transport_or_schema_hold(_,_,_,_,_),_),
    'transport-or-schema-held') :- !.
as_model_failure_reason(error(model_provider_hold(Reason,_,_),_),Reason) :- !.
as_model_failure_reason(error(_,_),'grant-profile-or-mechanical-hold') :- !.
as_model_failure_reason(_,'grant-profile-or-mechanical-hold').
