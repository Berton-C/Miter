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
:- discontiguous as_model_question_carrier/8.

as_model(Root0, Question, Observation) :-
    catch((as_model_checked(Root0, Question, Observation0) -> true
          ; throw(error(model_boundary_hold,_))), Error,
      as_model_unavailable(Question, Error, Observation0)),
    Observation=Observation0, !.

as_model_checked(Root0, Question, Observation) :-
    as_root(Root0, Root),
    ground(Question),
    as_model_question_carrier(Question, QuestionRef, Scope, Instructions,
      Purpose, ResourceId, MaxTokens, Deadline),
    as_model_question_sha256(Question, QuestionHash),
    as_model_observation_path(Root, QuestionHash, ObservationPath),
    ( exists_file(ObservationPath) ->
        as_model_read_observation(ObservationPath, Observation)
    ; as_model_claim_path(Root, QuestionHash, ClaimPath),
      ( exists_directory(ClaimPath) ->
          as_model_unavailable(Question, uncertain_prior_transmission,
            Observation)
      ; as_model_profile(Root, ResourceId, Profile),
        as_model_grant(Root, QuestionHash, Scope, Purpose, ResourceId,
          MaxTokens, Deadline, Grant),
        as_model_claim(Root, QuestionHash, QuestionRef, Scope, ResourceId,
          Purpose, Grant, ClaimPath),
        as_model_request(Profile, Question, Instructions, MaxTokens, Body),
        as_model_write_request(Root, QuestionHash, QuestionRef, Scope,
          Purpose, ResourceId, Profile, Body),
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
    QuestionRef, Scope, Instructions, 'semantic-reading', ResourceId,
    MaxTokens, Deadline) :-
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

as_model_question_carrier(
    ['c4-contact-semantic-question-v1',QuestionRef,Scope,
      ['source-contact',ContactId,['payload-reference',PayloadRef]],
      ['exact-contact-text',ContentHash,Text,RawRef],
      ['preliminary-movement',MovementReference],
      ['fact9-participation',FactEntries,FactStanding],
      ['flourishing-participation',FlourishingEntries,FlourishingStanding],
      Continuity,
      ['request-contract',Instructions,'authorized-current-contact-only',
        'derived-readings-not-verdict','no-contact-no-authority-no-choice'],
      ['resource-request',ResourceId,
        'human-preferred-default-not-cognitive-authority',
        'semantic-reading',MaxTokens,Deadline]],
    QuestionRef, Scope,Instructions,'semantic-reading',ResourceId,MaxTokens,
    Deadline) :-
    QuestionRef=['question-reference',ContactId,'general-contact-semantics'],
    as_symbol(ContactId,_), as_symbol(PayloadRef,_), as_sha256(ContentHash,_),
    as_model_bounded_text(Text,1,32768), as_model_raw_reference(RawRef),
    MovementReference=['movement-reference'|_], length(MovementReference,5),
    as_model_c4_fact_entries(FactEntries),
    as_symbol(FactStanding,_), as_model_c4_flourishing_entries(FlourishingEntries),
    as_symbol(FlourishingStanding,_), as_model_c4_continuity(Continuity),
    as_local_scope(Scope), string(Instructions),
    string_length(Instructions,InstructionLength),
    InstructionLength>=100, InstructionLength=<4096,
    ResourceId='openrouter-glm53', MaxTokens=1200, Deadline=120.

as_model_c4_fact_entries(Entries) :-
    is_list(Entries), Entries=[_|_], maplist(as_model_c4_fact_entry,Entries).
as_model_c4_fact_entry(
    ['c4-fact9-entry',Id,['roles',Roles],
      ['material-relations',Relations],Composition]) :-
    as_symbol(Id,_), is_list(Roles), Roles=[_|_],
    maplist(as_model_fact9_role,Roles), sort(Roles,Roles),
    is_list(Relations), Relations=[_|_], maplist(as_symbol,Relations,_),
    sort(Relations,Relations), Composition=['composition'|_],
    ground(Composition).

as_model_c4_flourishing_entries(Entries) :-
    is_list(Entries), length(Entries,9),
    maplist(as_model_c4_flourishing_entry,Entries),
    maplist(as_model_c4_flourishing_value,Entries,Values),
    sort(Values,Unique), same_length(Values,Unique).
as_model_c4_flourishing_entry(
    ['c4-flourishing-entry',Value,
      ['current-relational-standings',Standings]]) :-
    as_flourishing(Value), is_list(Standings), Standings=[_|_],
    maplist(as_model_flourishing_standing,Standings).
as_model_c4_flourishing_value(['c4-flourishing-entry',Value,_],Value).

as_model_c4_continuity(
    ['continuity-participation',['predecessor',Predecessor],
      ['live-undertakings',Undertakings],['present',Present],
      'exact-native-capsule-authority-not-provider-memory']) :-
    (Predecessor=='no-predecessor';Predecessor=['source-cut',_]),
    is_list(Undertakings), maplist(as_symbol,Undertakings,_),
    Present=['present-context',_,_], ground(Present).

as_model_c4_semantic_reading(
    ['c4-semantic-reading-v1',Id,Understanding,ResponsePurpose,
      ['fact9-roles',Fact9Roles],['flourishing-values',Flourishings],
      Counterfactual,'model-proposal-only']) :-
    as_symbol(Id,_), as_model_bounded_text(Understanding,1,1200),
    as_model_bounded_text(ResponsePurpose,1,900),
    is_list(Fact9Roles), Fact9Roles=[_|_],
    maplist(as_model_fact9_role,Fact9Roles), sort(Fact9Roles,Fact9Roles),
    is_list(Flourishings), Flourishings=[_|_],
    maplist(as_flourishing,Flourishings), sort(Flourishings,Flourishings),
    as_model_bounded_text(Counterfactual,1,1200).

as_model_question_carrier(
    ['c4-voice-render-question-v1',QuestionRef,Scope,
      ['source-contact',ContactId,['payload-reference',PayloadRef]],
      ['exact-contact-text',ContentHash,Text,RawRef],
      ['native-movement',MovementReference],
      ['semantic-readings',Readings],NativeIntention,VoiceCommitments,
      ['request-contract',Instructions,'rendering-not-movement',
        'candidate-utterance-not-effect','no-contact-no-authority-no-choice'],
      ['resource-request',ResourceId,
        'human-preferred-default-not-cognitive-authority',
        'language-rendering',MaxTokens,Deadline]],
    QuestionRef,Scope,Instructions,'language-rendering',ResourceId,MaxTokens,
    Deadline) :-
    QuestionRef=['question-reference',ContactId,'voice-rendering'],
    as_symbol(ContactId,_), as_symbol(PayloadRef,_), as_sha256(ContentHash,_),
    as_model_bounded_text(Text,1,32768), as_model_raw_reference(RawRef),
    MovementReference=['movement-reference'|_], length(MovementReference,5),
    is_list(Readings), length(Readings,Count), between(2,3,Count),
    maplist(as_model_c4_semantic_reading,Readings),
    NativeIntention=['native-intention'|_], ground(NativeIntention),
    VoiceCommitments=['voice-commitments'|_], ground(VoiceCommitments),
    as_local_scope(Scope), string(Instructions),
    string_length(Instructions,InstructionLength),
    InstructionLength>=100, InstructionLength=<4096,
    ResourceId='openrouter-glm53', MaxTokens=800, Deadline=120.

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
    % The native Soul may expose only the materially participating subset.
    % The membrane checks that subset against the source-required identities;
    % it does not enlarge relevance by requiring every available flourishing.
    forall(member(Value,Unique),memberchk(Value,RequiredUnique)).

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
    is_list(Relations), Relations=[_|_],
    maplist(as_model_relation_identity,Relations),
    sort(Relations,UniqueRelations), same_length(Relations,UniqueRelations),
    is_list(Flourishings), Flourishings=[_|_],
    maplist(as_flourishing,Flourishings),
    sort(Flourishings,UniqueFlourishings),
    same_length(Flourishings,UniqueFlourishings).

% Most relation identities are symbols.  Native construction may also retain
% this exact typed standing identity; recognizing its carrier shape here does
% not interpret or choose its standing.
as_model_relation_identity(Relation) :- as_symbol(Relation,_), !.
as_model_relation_identity(
    ['c3-alignment-candidate-standing',Candidate]) :-
    as_symbol(Candidate,_).

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
    get_dict(roles,Profile,["semantic-reading","language-rendering"]),
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

as_model_grant(Root, QuestionHash, Scope, Purpose, ResourceId, MaxTokens,
    Deadline, Grant) :-
    as_path(Root,'model-grants.json',Path),
    miter_store_read_json(Path,Document), is_dict(Document),
    as_dict_atom(Document,standing,'active-explicit-grants'),
    as_model_secret_free(Document),
    get_dict(grants,Document,Grants), is_list(Grants),
    ( as_dict_atom(Document,schema,'miter-model-grants-v1') ->
        findall(G,(member(G,Grants),is_dict(G),
          as_model_grant_exact(G,QuestionHash,Scope,Purpose,ResourceId,
            MaxTokens,Deadline)),[Grant])
    ; as_dict_atom(Document,schema,'miter-model-grants-v2'),
      findall(G,(member(G,Grants),is_dict(G),
        as_model_grant_scoped(Root,G,Scope,Purpose,ResourceId,MaxTokens,
          Deadline)),[Grant])
    ).

as_model_grant_exact(Grant,QuestionHash,[scope,Principal,Audience,Project],
    Purpose,ResourceId,MaxTokens,Deadline) :-
    as_dict_atom(Grant,id,_), as_dict_atom(Grant,standing,active),
    as_dict_atom(Grant,resource_id,ResourceId),
    as_dict_atom(Grant,purpose,Purpose),
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

as_model_grant_scoped(Root,Grant,[scope,Principal,Audience,Project],Purpose,
    ResourceId,MaxTokens,Deadline) :-
    as_dict_atom(Grant,id,GrantId), as_dict_atom(Grant,standing,active),
    as_dict_atom(Grant,resource_id,ResourceId),
    get_dict(purposes,Grant,Purposes0), is_list(Purposes0),
    maplist(as_symbol,Purposes0,Purposes), memberchk(Purpose,Purposes),
    get_dict(scope,Grant,Scope), is_dict(Scope),
    as_dict_atom(Scope,principal,Principal),
    as_dict_atom(Scope,audience,Audience),
    as_dict_atom(Scope,project,Project),
    get_dict(max_calls,Grant,MaxCalls), integer(MaxCalls), MaxCalls>=1,
    as_model_grant_claim_count(Root,GrantId,Used), Used<MaxCalls,
    get_dict(max_output_tokens,Grant,GrantedTokens), integer(GrantedTokens),
    MaxTokens=<GrantedTokens,
    get_dict(deadline_seconds,Grant,GrantedDeadline), number(GrantedDeadline),
    Deadline=<GrantedDeadline,
    get_dict(public_safe_only,Grant,true),
    get_dict(expires_at_epoch,Grant,Expiry), number(Expiry),
    get_time(Now), Now=<Expiry.

as_model_grant_claim_count(Root,GrantId,Count) :-
    as_path(Root,'model/claims',Directory), directory_files(Directory,Entries),
    findall(Owner,(member(Name,Entries),Name\=='.',Name\=='..',
      directory_file_path(Directory,Name,Claim),exists_directory(Claim),
      directory_file_path(Claim,'owner.json',Owner),exists_file(Owner),
      catch((miter_store_read_json(Owner,Dict),
        as_dict_atom(Dict,grant_id,GrantId)),_,fail)),Owners),
    length(Owners,Count).

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

as_model_claim(_Root, Hash, QuestionRef, Scope, ResourceId, Purpose, Grant,
    ClaimPath) :-
    \+ exists_directory(ClaimPath), make_directory(ClaimPath),
    directory_file_path(ClaimPath,'owner.json',Owner),
    as_dict_atom(Grant,id,GrantId), get_time(Now),
    term_string(QuestionRef,QuestionRefText,[quoted(true),ignore_ops(true)]),
    term_string(Scope,ScopeText,[quoted(true),ignore_ops(true)]),
    as_write_json_durable(Owner,_{schema:"miter-model-spend-claim-v1",
      question_sha256:Hash,question_reference:QuestionRefText,
      scope:ScopeText,resource_id:ResourceId,purpose:Purpose,grant_id:GrantId,
      standing:"claimed-before-transmission",claimed_at_epoch:Now}).

as_model_request(Profile, Question, Instructions, MaxTokens, Body) :-
    % Scope is required locally for grant matching and continuity isolation, but
    % it contributes nothing to the provider's semantic reading.  The membrane
    % therefore removes principal, audience and project identifiers before the
    % exact Soul-selected R/A/P, Fact9, flourishing and returned-contact surface
    % leaves the machine.
    as_model_public_question(Question,PublicQuestion),
    term_string(PublicQuestion,QuestionText,[quoted(true),ignore_ops(true)]),
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
      response_format:_{type:"json_object"},provider:Provider},
    as_model_request_valid(Body).

as_model_public_question(
    ['c3-semantic-question-v1',QuestionRef,
      [scope,_,_,_],Movement,Source,Openings,Facts,Flourishings,Uncertainty,
      Contract,Resource],
    ['c3-semantic-question-v1',QuestionRef,
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      Movement,Source,Openings,Facts,Flourishings,Uncertainty,Contract,
      Resource]).
as_model_public_question(
    ['c4-contact-semantic-question-v1',QuestionRef,[scope,_,_,_],
      Source,Text,Movement,Facts,Flourishings,Continuity,Contract,Resource],
    ['c4-contact-semantic-question-v1',QuestionRef,
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      Source,Text,Movement,Facts,Flourishings,Continuity,Contract,Resource]).
as_model_public_question(
    ['c4-voice-render-question-v1',QuestionRef,[scope,_,_,_],
      Source,Text,Movement,Readings,Intention,Commitments,Contract,Resource],
    ['c4-voice-render-question-v1',QuestionRef,
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      Source,Text,Movement,Readings,Intention,Commitments,Contract,Resource]).

as_model_request_valid(Body) :-
    is_dict(Body), dict_pairs(Body,_,Pairs), pairs_keys(Pairs,Keys),
    Keys==[max_tokens,messages,model,provider,reasoning_effort,
      response_format,stream,temperature,top_p],
    Body.model=="z-ai/glm-5.3", integer(Body.max_tokens),
    Body.max_tokens>=1, Body.max_tokens=<2048,
    Body.reasoning_effort=="high", Body.stream==false,
    Body.temperature=:=0, Body.top_p=:=1,
    is_dict(Body.response_format),
    Body.response_format.type=="json_object",
    Body.messages=[System,User], System.role=="system", User.role=="user",
    string(System.content), string(User.content),
    is_dict(Body.provider), Body.provider.zdr==true,
    Body.provider.data_collection=="deny",
    Body.provider.require_parameters==true,
    Body.provider.allow_fallbacks==true,
    \+ get_dict(authorization,Body,_).

as_model_write_request(Root,Hash,QuestionRef,Scope,Purpose,ResourceId,Profile,
    Body) :-
    as_model_named_json(Root,requests,Hash,Path), \+ exists_file(Path),
    term_string(QuestionRef,QuestionRefText,[quoted(true),ignore_ops(true)]),
    term_string(Scope,ScopeText,[quoted(true),ignore_ops(true)]),
    as_write_json_durable(Path,_{schema:"miter-model-request-v1",
      question_sha256:Hash,question_reference:QuestionRefText,scope:ScopeText,
      purpose:Purpose,resource_id:ResourceId,endpoint:Profile.endpoint,body:Body,
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
           redirect(false),encoding(utf8),
           request_header('Authorization'=Authorization),
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
        ( as_model_provider_observation(Raw,Question,QuestionRef,Scope,
              ResourceId,RawHash,Observation) -> true
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

as_model_provider_envelope(Raw,Content,Finish,Usage) :-
    atom_json_dict(Raw,Response,[]), is_dict(Response),
    get_dict(model,Response,"z-ai/glm-5.3"),
    get_dict(choices,Response,[Choice]), is_dict(Choice),
    as_dict_atom(Choice,finish_reason,Finish), Finish==stop,
    get_dict(message,Choice,Message), is_dict(Message),
    get_dict(content,Message,Content), string(Content),
    \+ sub_string(Content,_,_,_,"```"),
    as_model_usage(Response,Usage).

as_model_provider_observation(Raw,Question,QuestionRef,Scope,ResourceId,
    RawHash,Observation) :-
    as_model_provider_envelope(Raw,Content,Finish,Usage),
    Question=['c3-semantic-question-v1'|_],
    atom_json_dict(Content,Result,[]), as_model_result(Result,Candidates),
    as_model_candidates_match_question(Candidates,Question),
    Observation=['c3-model-observation-v1',QuestionRef,Scope,ResourceId,
      'z-ai/glm-5.3',['transport',eof],['http-status',200],
      ['finish-reason',Finish],['raw-sha256',RawHash],
      [candidates,Candidates],Usage,
      'provider-reading-no-contact-no-authority-no-choice'].
as_model_provider_observation(Raw,Question,QuestionRef,Scope,ResourceId,
    RawHash,Observation) :-
    as_model_provider_envelope(Raw,Content,Finish,Usage),
    Question=['c4-contact-semantic-question-v1'|_],
    atom_json_dict(Content,Result,[]),
    as_model_c4_semantic_result(Result,Question,Readings),
    Observation=['c4-semantic-observation-v1',QuestionRef,Scope,ResourceId,
      'z-ai/glm-5.3',['transport',eof],['http-status',200],
      ['finish-reason',Finish],['raw-sha256',RawHash],
      [readings,Readings],Usage,
      'provider-reading-no-contact-no-authority-no-choice'].
as_model_provider_observation(Raw,Question,QuestionRef,Scope,ResourceId,
    RawHash,Observation) :-
    as_model_provider_envelope(Raw,Content,Finish,Usage),
    Question=['c4-voice-render-question-v1'|_],
    atom_json_dict(Content,Result,[]),
    as_model_c4_voice_result(Result,Question,Utterance,Bindings,Uncertainty),
    Observation=['c4-voice-observation-v1',QuestionRef,Scope,ResourceId,
      'z-ai/glm-5.3',['transport',eof],['http-status',200],
      ['finish-reason',Finish],['raw-sha256',RawHash],
      ['rendered-utterance',Utterance,[bindings,Bindings],
        [uncertainty,Uncertainty]],Usage,
      'candidate-rendering-no-effect-authority',
      'structurally-bound-semantic-fidelity-remains-consequence-testable'].

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

as_model_c4_semantic_result(Result,Question,Readings) :-
    is_dict(Result), as_model_exact_keys(Result,[readings,uncertainty]),
    get_dict(uncertainty,Result,Uncertainty),
    as_model_bounded_text(Uncertainty,1,300),
    get_dict(readings,Result,Rows), is_list(Rows), length(Rows,2),
    maplist(as_model_c4_semantic_row(Question),Rows,Readings),
    maplist(as_model_c4_reading_id,Readings,Ids),
    sort(Ids,Unique), same_length(Ids,Unique).

as_model_c4_semantic_row(Question,Row,
    ['c4-semantic-reading-v1',Id,Understanding,ResponsePurpose,
      ['fact9-roles',Fact9Roles],['flourishing-values',Flourishings],
      Counterfactual,'model-proposal-only']) :-
    is_dict(Row), as_model_exact_keys(Row,
      [counterfactual,fact9_roles,flourishing_values,response_purpose,
        understanding]),
    get_dict(understanding,Row,Understanding),
    as_model_bounded_text(Understanding,1,300),
    get_dict(response_purpose,Row,ResponsePurpose),
    as_model_bounded_text(ResponsePurpose,1,240),
    get_dict(counterfactual,Row,Counterfactual),
    as_model_bounded_text(Counterfactual,1,300),
    get_dict(fact9_roles,Row,Fact9Strings), is_list(Fact9Strings),
    maplist(as_model_fact9_string_atom,Fact9Strings,Fact9Roles0),
    sort(Fact9Roles0,Fact9Roles), same_length(Fact9Strings,Fact9Roles),
    Fact9Roles=[_|_], as_model_c4_question_fact_roles(Question,AllowedFact9),
    forall(member(Role,Fact9Roles),memberchk(Role,AllowedFact9)),
    get_dict(flourishing_values,Row,FlourishingStrings),
    is_list(FlourishingStrings),
    maplist(as_model_flourishing_string_atom,FlourishingStrings,Flourishings0),
    sort(Flourishings0,Flourishings),
    same_length(FlourishingStrings,Flourishings), Flourishings=[_|_],
    as_model_c4_question_flourishings(Question,AllowedFlourishings),
    forall(member(Value,Flourishings),memberchk(Value,AllowedFlourishings)),
    with_output_to(string(Canonical),json_write_dict(current_output,Row,
      [width(0)])),
    crypto_data_hash(Canonical,Hash,[algorithm(sha256),encoding(utf8)]),
    sub_atom(Hash,0,24,_,Prefix), atom_concat('dialogue-reading-',Prefix,Id).

as_model_c4_reading_id(['c4-semantic-reading-v1',Id|_],Id).

as_model_c4_question_fact_roles(
    ['c4-contact-semantic-question-v1',_,_,_,_,_,
      ['fact9-participation',Entries,_]|_],Roles) :-
    findall(Role,(member(Entry,Entries),
      Entry=['c4-fact9-entry',_,['roles',EntryRoles]|_],
      member(Role,EntryRoles)),Roles0),sort(Roles0,Roles).

as_model_c4_question_flourishings(
    ['c4-contact-semantic-question-v1',_,_,_,_,_,_,
      ['flourishing-participation',Entries,_]|_],Values) :-
    findall(Value,member(['c4-flourishing-entry',Value,_],Entries),Values0),
    sort(Values0,Values).

as_model_fact9_string_atom(String,Atom) :-
    string(String), atom_string(Atom,String), as_model_fact9_role(Atom).
as_model_flourishing_string_atom(String,Atom) :-
    string(String), atom_string(Atom,String), as_flourishing(Atom).

as_model_c4_voice_result(Result,Question,Utterance,Bindings,Uncertainty) :-
    is_dict(Result), as_model_exact_keys(Result,
      [bindings,uncertainty,utterance]),
    get_dict(utterance,Result,Utterance),
    as_model_bounded_text(Utterance,1,3000),
    get_dict(uncertainty,Result,Uncertainty),
    as_model_bounded_text(Uncertainty,1,600),
    get_dict(bindings,Result,BindingStrings), is_list(BindingStrings),
    BindingStrings=[_|_], maplist(as_model_string_atom,BindingStrings,Bindings0),
    sort(Bindings0,Bindings), same_length(BindingStrings,Bindings),
    as_model_c4_voice_reading_ids(Question,Available),
    forall(member(Binding,Bindings),memberchk(Binding,Available)).

as_model_c4_voice_reading_ids(
    ['c4-voice-render-question-v1',_,_,_,_,_,
      ['semantic-readings',Readings]|_],Ids) :-
    maplist(as_model_c4_reading_id,Readings,Ids).

as_model_string_atom(String,Atom) :-
    string(String), string_length(String,Length), Length>=1, Length=<256,
    atom_string(Atom,String).

as_model_perspective_string_atom(String,Atom) :-
    string(String), atom_string(Atom,String), as_model_perspective(Atom).

as_model_bounded_text(Text,Min,Max) :-
    string(Text), string_length(Text,Length), Length>=Min, Length=<Max,
    string_codes(Text,Codes), \+ member(0,Codes).

as_model_raw_reference(Value) :-
    miter_store_nonempty_atom(Value,Reference),
    atom_length(Reference,Length), Length>=1, Length=<512,
    \+ is_absolute_file_name(Reference),
    \+ sub_atom(Reference,_,_,_,'..'),
    re_match('^[A-Za-z0-9_.:/-]+$',Reference).

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
    ground(Observation), Observation=[Kind|_],
    memberchk(Kind,['c3-model-observation-v1','c4-semantic-observation-v1',
      'c4-voice-observation-v1']).

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
    ['c4-model-observation-unavailable-v1',QuestionRef,Scope,
      'openrouter-glm53',Reason,'no-candidate-admitted']) :-
    Question=[Kind,QuestionRef,Scope|_],
    memberchk(Kind,['c4-contact-semantic-question-v1',
      'c4-voice-render-question-v1']), !,
    as_model_failure_reason(Error,Reason).
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
