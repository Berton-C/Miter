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
    as_model_continuity_context_verified_if_present(Root,Question,Scope),
    as_model_current_direction_authorizes(Root,Question,Scope,Purpose,
      ResourceId,MaxTokens,Deadline),
    as_model_question_sha256(Question, QuestionHash),
    as_model_observation_path(Root, QuestionHash, ObservationPath),
    ( exists_file(ObservationPath) ->
        as_model_read_observation(ObservationPath, Observation)
    ; as_model_claim_path(Root, QuestionHash, ClaimPath),
      ( exists_directory(ClaimPath) ->
          as_model_unavailable(Question, uncertain_prior_transmission,
            Observation)
      ; as_model_profile(Root, ResourceId, Profile),
        as_model_grant(Root, Question, QuestionHash, Scope, Purpose, ResourceId,
          MaxTokens, Deadline, Grant),
        as_evaluation_model_available(Root,Scope,ResourceId),
        as_model_claim(Root, QuestionHash, QuestionRef, Scope, ResourceId,
          Purpose, Grant, ClaimPath),
        as_model_request(Profile, Question, Instructions, MaxTokens, Body),
        as_model_write_request(Root, QuestionHash, QuestionRef, Scope,
          Purpose, ResourceId, Profile, Body),
        as_model_credential(Root,Profile,Key),
        as_model_execute(Root, QuestionHash, QuestionRef, Scope, Question,
          ResourceId, Profile, Body, Key, Deadline, Observation0),
        as_model_write_observation(ObservationPath, Observation0),
        Observation=Observation0
      )
    ).

as_model_current_direction_authorizes(Root,Question,Scope,Purpose,ResourceId,
    MaxTokens,Deadline) :-
    Question=[Kind|_],
    ( Kind=='c4-contact-semantic-question-v1' ->
        as_model_direction_checked(Root,Scope,Purpose,Direction),
        Direction=['model-resource-direction-v1',ResourceId,ModelId,
          'human-operator-direction-not-cognitive-authority',Purpose,
          MaxTokens,Deadline],
        last(Question,['resource-request',ResourceId,ModelId,
          'human-operator-direction-not-cognitive-authority',Purpose,
          MaxTokens,Deadline])
    ; memberchk(Kind,['c4-voice-render-question-v1',
          'c4-voice-audit-question-v1']) ->
        last(Question,['resource-request',ResourceId,ModelId,Authority,Purpose,
          MaxTokens,Deadline]),
        Authority=='human-operator-direction-not-cognitive-authority',
        as_model_direction_checked(Root,Scope,Purpose,Direction),
        Direction=['model-resource-direction-v1',ResourceId,ModelId,Authority,
          Purpose,MaxTokens,Deadline]
    ; true ).

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
    as_symbol(ResourceId,_),integer(MaxTokens),MaxTokens>=1,MaxTokens=<2048,
    number(Deadline),Deadline>=1,Deadline=<300.

as_model_question_carrier(
    ['c4-voice-audit-question-v1',QuestionRef,Scope,
      ['source-contact',ContactId,['payload-reference',PayloadRef]],
      ['exact-contact-text',ContentHash,Text,RawRef],
      ['native-movement',MovementReference],
      ['semantic-readings',Readings],
      ['candidate-rendering',['raw-sha256',CandidateHash],Rendering],
      VoiceCommitments,
      ['request-contract',Instructions,'audit-not-movement',
        'candidate-reading-not-effect','no-contact-no-authority-no-choice'],
      ['resource-request',ResourceId,ModelId,DirectionAuthority,
        'language-rendering',MaxTokens,Deadline]],
    QuestionRef,Scope,Instructions,'language-rendering',ResourceId,MaxTokens,
    Deadline) :-
    QuestionRef=['question-reference',ContactId,'voice-audit'],
    as_symbol(ContactId,_),as_symbol(PayloadRef,_),as_sha256(ContentHash,_),
    as_model_bounded_text(Text,1,32768),as_model_raw_reference(RawRef),
    MovementReference=['movement-reference'|_],length(MovementReference,5),
    is_list(Readings),length(Readings,Count),between(2,3,Count),
    maplist(as_model_c4_semantic_reading,Readings),
    as_sha256(CandidateHash,_),
    as_model_c4_voice_commitments(VoiceCommitments),
    as_model_c4_rendering(Rendering,Readings,VoiceCommitments),
    as_local_scope(Scope),string(Instructions),
    string_length(Instructions,InstructionLength),
    InstructionLength>=100,InstructionLength=<4096,
    as_symbol(ResourceId,_),as_model_identifier(ModelId),
    DirectionAuthority='human-operator-direction-not-cognitive-authority',
    integer(MaxTokens),MaxTokens>=1,MaxTokens=<800,
    number(Deadline),Deadline>=1,Deadline=<300.

as_model_c4_rendering(
    ['rendered-utterance',Utterance,['bindings',Bindings],
      ['uncertainty',Uncertainty]],Readings,Commitments) :-
    as_model_bounded_text(Utterance,1,3000),
    as_model_bounded_text(Uncertainty,1,600),
    is_list(Bindings),Bindings=[_|_],maplist(as_symbol,Bindings,_),
    sort(Bindings,Unique),same_length(Bindings,Unique),
    as_model_c4_allowed_binding_ids(Readings,Commitments,Available),
    forall(member(Binding,Bindings),memberchk(Binding,Available)).

as_model_c4_allowed_binding_ids(Readings,Commitments,Ids) :-
    maplist(as_model_c4_reading_id,Readings,ReadingIds),
    last(Commitments,RevisionContext),
    as_model_c4_voice_revision_context(RevisionContext),
    nth0(7,Commitments,PrivateContext),
    as_model_c4_private_context(PrivateContext,Entries),
    findall(MemoryId,
      member(['c4-private-memory-evidence-v1',MemoryId|_],Entries),MemoryIds),
    append(ReadingIds,MemoryIds,Ids).

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
      ['resource-request',ResourceId,ModelId,
        'human-operator-direction-not-cognitive-authority',
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
    as_symbol(ResourceId,_),as_model_identifier(ModelId),
    integer(MaxTokens),MaxTokens>=1,MaxTokens=<1200,
    number(Deadline),Deadline>=1,Deadline=<300.

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
      ['active-organization',ActiveOrganization],
      ['live-undertakings',Undertakings],['present',Present],
      ['retrieved-memory-candidates',MemoryCandidates],
      'exact-native-capsule-authority-not-provider-memory']) :-
    as_model_c4_predecessor(Predecessor),
    as_model_c4_active_organization(ActiveOrganization,Predecessor),
    is_list(Undertakings), maplist(as_symbol,Undertakings,_),
    Present=['present-context',_,_], ground(Present),
    is_list(MemoryCandidates),length(MemoryCandidates,MemoryCount),
    MemoryCount=<4,maplist(as_model_c4_memory_candidate,MemoryCandidates).

as_model_c4_predecessor('no-predecessor').
as_model_c4_predecessor(['source-cut',CutId]) :-
    as_local_cut_id(CutId).

as_model_c4_active_organization('no-prior-active-organization',
    'no-predecessor').
as_model_c4_active_organization(
    ['prior-active',['source-cut',CutId],MovementReference,
      ['live-undertakings',Undertakings]],['source-cut',CutId]) :-
    as_local_cut_id(CutId), MovementReference=['movement-reference'|_],
    length(MovementReference,5), is_list(Undertakings),
    maplist(as_symbol,Undertakings,_).

as_model_c4_memory_candidate(
    ['c4-memory-reference',MemoryId,SourceKind,
      ['body-sha256',BodyHash],['snapshot-sha256',SnapshotHash],
      'scope-and-capsule-verified','content-withheld-from-remote-provider',
      'rank-not-authority']) :-
    as_symbol(MemoryId,_),
    memberchk(SourceKind,['human-contact','certified-expression']),
    as_sha256(BodyHash,_),as_sha256(SnapshotHash,_).

as_model_c4_semantic_reading(
    ['c4-semantic-reading-v1',Id,Understanding,ResponsePurpose,
      ['fact9-roles',Fact9Roles],['flourishing-values',Flourishings],
      ['continuity-requirement',ContinuityRequirement],Counterfactual,
      'model-proposal-only']) :-
    as_symbol(Id,_), as_model_bounded_text(Understanding,1,1200),
    as_model_bounded_text(ResponsePurpose,1,900),
    is_list(Fact9Roles), Fact9Roles=[_|_],
    maplist(as_model_fact9_role,Fact9Roles), sort(Fact9Roles,Fact9Roles),
    is_list(Flourishings), Flourishings=[_|_],
    maplist(as_flourishing,Flourishings), sort(Flourishings,Flourishings),
    memberchk(ContinuityRequirement,
      ['not-material','candidate-content-needed','uncertain']),
    as_model_bounded_text(Counterfactual,1,1200).

as_model_question_carrier(
    ['c4-voice-render-question-v1',QuestionRef,Scope,
      ['source-contact',ContactId,['payload-reference',PayloadRef]],
      ['exact-contact-text',ContentHash,Text,RawRef],
      ['native-movement',MovementReference],
      ['semantic-readings',Readings],NativeIntention,VoiceCommitments,
      ['request-contract',Instructions,'rendering-not-movement',
        'candidate-utterance-not-effect','no-contact-no-authority-no-choice'],
      ['resource-request',ResourceId,ModelId,DirectionAuthority,
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
    as_model_c4_voice_commitments(VoiceCommitments),
    as_local_scope(Scope), string(Instructions),
    string_length(Instructions,InstructionLength),
    InstructionLength>=100, InstructionLength=<4096,
    as_symbol(ResourceId,_),as_model_identifier(ModelId),
    DirectionAuthority='human-operator-direction-not-cognitive-authority',
    integer(MaxTokens),MaxTokens>=1,MaxTokens=<800,
    number(Deadline),Deadline>=1,Deadline=<300.

as_model_c4_voice_commitments(
    ['voice-commitments','source-bound','scope-bound','movement-bound',
      Disclosure,'relational-not-fixed-style',
      'no-unsupported-internal-state-claim',PrivateContext,RevisionContext]) :-
    memberchk(Disclosure,
      ['disclosure-current-contact-only',
       'disclosure-current-contact-and-scoped-continuity']),
    as_model_c4_private_context(PrivateContext,Entries),
    as_model_c4_voice_revision_context(RevisionContext),
    ( Entries==[] -> Disclosure=='disclosure-current-contact-only'
    ; Disclosure=='disclosure-current-contact-and-scoped-continuity' ).

as_model_c4_voice_revision_context(
    ['voice-revision-context','initial-no-prior-defect']).
as_model_c4_voice_revision_context(
    ['voice-revision-context','revise-on-audit',AuditReading]) :-
    as_model_c4_voice_audit_reading(AuditReading,Findings),Findings=[_|_].

as_model_c4_voice_audit_reading(
    ['voice-audit-reading-v2',['findings',Findings],
      ['uncertainty',Uncertainty],'candidate-fidelity-reading-not-verdict'],
    Findings) :-
    is_list(Findings),length(Findings,Count),Count=<4,
    maplist(as_model_c4_voice_finding,Findings),
    as_model_bounded_text(Uncertainty,1,600).

as_model_c4_voice_finding(
    ['voice-audit-finding-v2',Kind,['source-basis',SourceBasis],
      ['candidate-span',CandidateSpan],['inferred-alteration',Alteration],
      ['why-material',WhyMaterial],['affected-dependency',Dependency]]) :-
    memberchk(Kind,['semantic-drift','soul-absence','person-not-seen',
      'task-smearing','unsupported-certainty','authority-inflation',
      'coercive-dominance','hidden-scope','tone-mismatch','lost-tension',
      'unsupported-inner-state','unsupported-action','memory-misstatement',
      'source-fidelity','uncertainty-erasure','ungrounded-authority-claim',
      'voice-displacement']),
    maplist(as_model_bounded_finding_text,
      [SourceBasis,CandidateSpan,Alteration,WhyMaterial,Dependency]).

as_model_bounded_finding_text(Text) :-
    as_model_bounded_text(Text,1,600).

as_model_c4_private_context(
    ['private-continuity-context',Entries,
      'scope-verified-native-candidates-not-authority'],Entries) :-
    is_list(Entries),length(Entries,Count),Count=<4,
    maplist(as_model_c4_private_memory_entry,Entries),
    findall(Id,member(['c4-private-memory-evidence-v1',Id|_],Entries),Ids),
    sort(Ids,Unique),same_length(Ids,Unique).

as_model_c4_private_memory_entry(
    ['c4-private-memory-evidence-v1',MemoryId,SourceKind,
      ['source-capsule',SourceReference,SourceHash,CapsuleHash,
        ['source-occurrence',SourceKey],['runtime-id',RuntimeId]],
      ['body',BodyHash,Body],['snapshot-sha256',SnapshotHash],
      'scope-and-capsule-verified','rank-not-authority']) :-
    as_symbol(MemoryId,_),
    memberchk(SourceKind,['human-contact','certified-expression']),
    as_model_raw_reference(SourceReference),as_sha256(SourceHash,_),
    as_sha256(CapsuleHash,_),as_model_raw_reference(SourceKey),
    atom(RuntimeId),re_match('^[0-9a-f-]{36}$',RuntimeId),
    as_sha256(BodyHash,_),as_model_bounded_text(Body,1,8000),
    crypto_data_hash(Body,BodyHash,[algorithm(sha256),encoding(utf8)]),
    as_sha256(SnapshotHash,_).

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

% A human model direction selects only the transport resource for a bounded
% live scope.  It cannot form a question or decide what any returned text
% means.  The direction is read by native MeTTa before it constructs the exact
% resource request, so the membrane cannot silently substitute a provider.
as_model_direction(Root0,Scope,Purpose0,Direction) :-
    catch((as_model_direction_checked(Root0,Scope,Purpose0,Direction0)->true
          ; throw(error(model_direction_hold,_))),_,
      Direction0=['model-resource-direction-unavailable',
        'no-current-explicit-human-resource-direction']),
    Direction=Direction0, !.

as_model_direction_checked(Root0,Scope,Purpose0,
    ['model-resource-direction-v1',ResourceId,ModelId,
      'human-operator-direction-not-cognitive-authority',Purpose,
      MaxTokens,Deadline]) :-
    as_root(Root0,Root),as_local_scope(Scope),as_symbol(Purpose0,Purpose),
    memberchk(Purpose,['semantic-reading','language-rendering']),
    as_path(Root,'model-direction.json',Path),
    miter_store_read_json(Path,Document),is_dict(Document),
    as_dict_atom(Document,schema,'miter-model-direction-v1'),
    as_dict_atom(Document,standing,'active-human-direction'),
    as_dict_atom(Document,resource_id,ResourceId),
    get_dict(purposes,Document,PurposeStrings),is_list(PurposeStrings),
    maplist(as_symbol,PurposeStrings,Purposes),memberchk(Purpose,Purposes),
    get_dict(activated_at_epoch,Document,Activated),number(Activated),
    get_dict(expires_at_epoch,Document,Expiry),number(Expiry),
    get_time(Now),(Expiry=:=0;Now=<Expiry),
    get_dict(max_calls,Document,MaxCalls),integer(MaxCalls),MaxCalls>=0,
    as_model_direction_claim_count(Root,ResourceId,Activated,Used),
    (MaxCalls=:=0;Used<MaxCalls),
    as_model_profile(Root,ResourceId,Profile),
    get_dict(model,Profile,ModelString),atom_string(ModelId,ModelString),
    atom_string(Purpose,PurposeString),memberchk(PurposeString,Profile.roles),
    as_model_direction_limits(Purpose,Profile,MaxTokens,Deadline).

as_model_direction_limits('semantic-reading',Profile,MaxTokens,Deadline) :-
    get_dict(limits,Profile,Limits),
    MaxTokens is min(1200,Limits.max_output_tokens),
    Deadline=Limits.deadline_seconds.
as_model_direction_limits('language-rendering',Profile,MaxTokens,Deadline) :-
    get_dict(limits,Profile,Limits),
    MaxTokens is min(800,Limits.max_output_tokens),
    Deadline=Limits.deadline_seconds.

as_model_continuity_context_verified_if_present(Root,Question,Scope) :-
    ( as_model_question_has_private_continuity(Question) ->
        as_model_continuity_context_verified(Root,Question,Scope)
    ; true ).

as_model_continuity_context_verified(Root,Question,Scope) :-
    Question=[Kind,_,Scope,_,_,_,_,_,Commitments,_,_],
    memberchk(Kind,['c4-voice-render-question-v1',
      'c4-voice-audit-question-v1']),
    as_model_c4_voice_commitments(Commitments),
    nth0(7,Commitments,PrivateContext),
    as_model_c4_private_context(PrivateContext,Entries),Entries=[_|_],
    maplist(as_model_private_memory_entry_verified(Root,Scope),Entries).

as_model_private_memory_entry_verified(Root,Scope,
    ['c4-private-memory-evidence-v1',MemoryId,SourceKind,
      ['source-capsule',SourceReference,SourceHash,CapsuleHash,
        ['source-occurrence',SourceKey],['runtime-id',RuntimeId]],
      ['body',BodyHash,_],['snapshot-sha256',_],
      'scope-and-capsule-verified','rank-not-authority']) :-
    miter_chroma_runtime_id(Root,RuntimeId),
    miter_chroma_verified_capsule(Root,SourceReference,SourceHash,CapsuleHash,
      Scope),
    miter_chroma_memory_id(RuntimeId,Scope,SourceKind,SourceKey,BodyHash,
      MemoryId).

as_model_direction_claim_count(Root,ResourceId,Activated,Count) :-
    as_path(Root,'model/claims',Directory),directory_files(Directory,Entries),
    findall(Owner,
      (member(Name,Entries),Name\=='.',Name\=='..',
       directory_file_path(Directory,Name,Claim),exists_directory(Claim),
       directory_file_path(Claim,'owner.json',Owner),exists_file(Owner),
       catch((miter_store_read_json(Owner,Dict),
         as_dict_atom(Dict,resource_id,ResourceId),
         get_dict(claimed_at_epoch,Dict,Claimed),number(Claimed),
         Claimed>=Activated),_,fail)),Owners),
    length(Owners,Count).

as_model_identifier(Value) :-
    miter_store_nonempty_atom(Value,Atom),
    atom_length(Atom,Length),Length=<256,
    re_match('^[A-Za-z][A-Za-z0-9_./:-]{0,255}$',Atom).

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
    get_dict(credential_reference,Profile,Credential),is_dict(Credential),
    as_model_credential_reference_shape(Credential).
as_model_profile_exact(Profile) :-
    as_dict_atom(Profile,id,ResourceId),
    memberchk(ResourceId,['qwen-local','nemotron-local']),
    as_dict_atom(Profile,kind,local),get_dict(enabled,Profile,true),
    as_dict_atom(Profile,adapter,'lm-studio'),
    as_model_local_identity(ResourceId,Model),get_dict(model,Profile,Model),
    get_dict(endpoint,Profile,"http://127.0.0.1:1234/v1/chat/completions"),
    get_dict(roles,Profile,["semantic-reading","language-rendering"]),
    get_dict(limits,Profile,Limits),is_dict(Limits),
    get_dict(max_output_tokens,Limits,2048),
    get_dict(deadline_seconds,Limits,300),
    get_dict(capture_bytes,Limits,262144),
    get_dict(credential_reference,Profile,null).

as_model_local_identity('qwen-local',"qwen/qwen3.8-27b").
as_model_local_identity('nemotron-local',
    "nemotron-3.5-30b-a3b-antislop-ftpo-i1").

as_model_credential_reference_shape(Credential) :-
    ( Credential=_{source:"macos-keychain",account:Account,service:Service},
      as_credential_name(Account),as_credential_name(Service)
    ; Credential=_{source:"private-runtime-file",path:Path},string(Path) ).

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

as_model_grant(Root, Question, QuestionHash, Scope, Purpose, ResourceId, MaxTokens,
    Deadline, Grant) :-
    as_path(Root,'model-grants.json',Path),
    miter_store_read_json(Path,Document), is_dict(Document),
    as_dict_atom(Document,standing,'active-explicit-grants'),
    as_model_secret_free(Document),
    get_dict(grants,Document,Grants), is_list(Grants),
    ( as_dict_atom(Document,schema,'miter-model-grants-v1') ->
        findall(G,(member(G,Grants),is_dict(G),
          as_model_grant_exact(G,Question,QuestionHash,Scope,Purpose,ResourceId,
            MaxTokens,Deadline)),[Grant])
    ; as_dict_atom(Document,schema,'miter-model-grants-v2'),
      findall(G,(member(G,Grants),is_dict(G),
        as_model_grant_scoped(Root,G,Question,Scope,Purpose,ResourceId,MaxTokens,
          Deadline)),[Grant])
    ).

as_model_grant_exact(Grant,Question,QuestionHash,
    [scope,Principal,Audience,Project],
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
    \+ as_model_question_has_private_continuity(Question),
    get_dict(expires_at_epoch,Grant,Expiry), number(Expiry),
    get_time(Now), Now=<Expiry.

as_model_grant_scoped(Root,Grant,Question,
    [scope,Principal,Audience,Project],Purpose,
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
    as_model_grant_disclosure(Root,Grant,ResourceId,Question),
    get_dict(expires_at_epoch,Grant,Expiry), number(Expiry),
    get_time(Now), Now=<Expiry.

as_model_question_has_private_continuity(
    [Kind,_,_,_,_,_,_,_,Commitments,_,_]) :-
    memberchk(Kind,['c4-voice-render-question-v1',
      'c4-voice-audit-question-v1']),
    nth0(7,Commitments,PrivateContext),
    as_model_c4_private_context(PrivateContext,[_|_]).

as_model_grant_disclosure(Root,Grant,ResourceId,Question) :-
    as_model_profile(Root,ResourceId,Profile),
    ( as_dict_atom(Profile,kind,remote) ->
        ( (get_dict(remote_context_authorized,Grant,true),
           get_dict(secret_and_security_risk_material_excluded,Grant,true))
        ; (get_dict(public_safe_only,Grant,true),
           \+ as_model_question_has_private_continuity(Question)) ),
        as_model_remote_question_security_safe(Question)
    ; as_dict_atom(Profile,kind,local) ).

as_model_remote_question_security_safe(Question) :-
    as_model_public_question(Question,ProviderQuestion),
    as_model_public_value_security_safe(ProviderQuestion).

as_model_public_value_security_safe(Value) :-
    is_list(Value), !, maplist(as_model_public_value_security_safe,Value).
as_model_public_value_security_safe(Value) :-
    string(Value), !, as_model_remote_text_security_safe(Value).
as_model_public_value_security_safe(_).

as_model_remote_text_security_safe(Text) :-
    string(Text),
    \+ as_model_security_risk_text(Text).

as_model_security_risk_text(Text) :-
    re_match('(?i)-----BEGIN[[:space:]]+[A-Z0-9 ]*PRIVATE KEY-----',Text),!.
as_model_security_risk_text(Text) :-
    re_match('(?i)(sk-(or-v1-)?[A-Za-z0-9_-]{16,}|github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[A-Z0-9]{16})',Text),!.
as_model_security_risk_text(Text) :-
    re_match('(?i)bearer[[:space:]]+[A-Za-z0-9._~+/-]{16,}',Text),!.
as_model_security_risk_text(Text) :-
    re_match('(?i)(password|passwd|passphrase|api[ _-]?key|access[ _-]?token|auth[ _-]?token|client[ _-]?secret)[[:space:]]*[:=][[:space:]]*[^[:space:]]{4,}',Text),!.
as_model_security_risk_text(Text) :-
    re_match('(?i)(pin|passcode|door[ _-]?code)[[:space:]]*[:=][[:space:]]*[0-9A-Za-z_-]{3,}',Text),!.
as_model_security_risk_text(Text) :-
    re_match('eyJ[A-Za-z0-9_-]{8,}[.][A-Za-z0-9_-]{8,}[.][A-Za-z0-9_-]{8,}',Text),!.
as_model_security_risk_text(Text) :-
    re_match('(^|[^0-9])[0-9]{3}-[0-9]{2}-[0-9]{4}([^0-9]|$)',Text).

as_model_grant_claim_count(Root,GrantId,Count) :-
    as_path(Root,'model/claims',Directory), directory_files(Directory,Entries),
    findall(Owner,(member(Name,Entries),Name\=='.',Name\=='..',
      directory_file_path(Directory,Name,Claim),exists_directory(Claim),
      directory_file_path(Claim,'owner.json',Owner),exists_file(Owner),
      catch((miter_store_read_json(Owner,Dict),
        as_dict_atom(Dict,grant_id,GrantId)),_,fail)),Owners),
    length(Owners,Count).

% The per-question model grant and the AMA-1.2 evaluation window are distinct
% mechanical authorities.  Both must be current before a new transmission.
% This aggregate counter enforces the shared remote-call ceiling; it does not
% decide whether the Soul asks a question or which returned reading matters.
as_evaluation_model_available(Root,[scope,Principal,Audience,Project],ResourceId) :-
    as_mattermost_config(Root,Config),
    as_mattermost_binding_local(Root,Config,Binding),
    as_evaluation_grant(Root,Config,Binding,_GrantId,EvaluationGrant),
    memberchk("authorized-model-participation",EvaluationGrant.capabilities),
    miter_store_nonempty_atom(Principal,PrincipalAtom),
    atom_string(PrincipalAtom,PrincipalString),
    memberchk(PrincipalString,EvaluationGrant.principals),
    miter_store_nonempty_atom(Audience,AudienceAtom),
    miter_store_nonempty_atom(Project,ProjectAtom),
    atom_string(AudienceAtom,Config.scope.audience),
    atom_string(ProjectAtom,Config.scope.project),
    as_model_profile(Root,ResourceId,Profile),
    ( as_dict_atom(Profile,kind,local) -> true
    ; as_dict_atom(Profile,kind,remote),
      as_evaluation_model_claim_count(Root,Used),
      Used<EvaluationGrant.limits.remote_calls ).

as_evaluation_model_claim_count(Root,Count) :-
    as_path(Root,'model/claims',Directory),directory_files(Directory,Entries),
    findall(Owner,
      (member(Name,Entries),Name\=='.',Name\=='..',
       directory_file_path(Directory,Name,Claim),exists_directory(Claim),
       directory_file_path(Claim,'owner.json',Owner),exists_file(Owner),
       catch((miter_store_read_json(Owner,Dict),
         as_dict_atom(Dict,grant_id,GrantId),
         sub_atom(GrantId,0,8,_,'ama-1.2-'),
         as_dict_atom(Dict,resource_id,ResourceId),
         as_model_profile(Root,ResourceId,Profile),
         as_dict_atom(Profile,kind,remote)),_,fail)),Owners),
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
    % Remote GLM is the ordinary configured resource.  Its projection may carry
    % exact conversation and scope-verified continuity content, but surface and
    % proof identifiers, credential stores and detected concrete security-risk
    % text remain outside the provider request. Opaque memory identities remain
    % so any recalled content used by a rendering can be attributed locally.
    ( as_dict_atom(Profile,kind,remote) ->
        as_model_remote_question_security_safe(Question),
        as_model_public_question(Question,ProviderQuestion),
        as_model_public_question_valid(Question,ProviderQuestion)
    ; as_dict_atom(Profile,kind,local),ProviderQuestion=Question ),
    term_string(ProviderQuestion,QuestionText,[quoted(true),ignore_ops(true)]),
    with_output_to(string(User), json_write_dict(current_output,
      _{native_question:QuestionText,
        interpretation_boundary:"Derived readings only. Miter retains contact, authority, comparison, movement, and consequence interpretation."},
      [width(0)])),
    get_dict(model,Profile,Model),
    as_model_response_format(Profile,Question,ResponseFormat),
    Common=_{model:Model,messages:[_{role:"system",content:Instructions},
      _{role:"user",content:User}],temperature:0,top_p:1,
      max_tokens:MaxTokens,stream:false,
      response_format:ResponseFormat},
    ( as_dict_atom(Profile,kind,remote) ->
        get_dict(reasoning_effort,Profile,Reasoning),
        get_dict(provider,Profile,Provider),
        put_dict(_{reasoning_effort:Reasoning,provider:Provider},Common,Body)
    ; as_dict_atom(Profile,kind,local),Body=Common ),
    as_model_request_valid(Profile,Body).

as_model_response_format(Profile,Question,
    _{type:"json_schema",json_schema:_{name:Name,strict:true,schema:Schema}}) :-
    (as_dict_atom(Profile,kind,remote);as_dict_atom(Profile,kind,local)),
    Question=[Kind|_],
    as_model_local_response_schema(Kind,Name,Schema).

as_model_local_response_schema('c3-semantic-question-v1',
    "miter_c3_semantic_readings",Schema) :-
    Perspective=_{type:"string",enum:["Relatedness","Appropriateness","Precision"]},
    Candidate=_{type:"object",additionalProperties:false,
      required:["summary","preserve","explore","counterfactual"],
      properties:_{summary:_{type:"string",minLength:1,maxLength:1200},
        preserve:_{type:"array",minItems:1,maxItems:2,uniqueItems:true,
          items:Perspective},
        explore:_{type:"array",minItems:1,maxItems:2,uniqueItems:true,
          items:Perspective},
        counterfactual:_{type:"string",minLength:1,maxLength:1200}}},
    Schema=_{type:"object",additionalProperties:false,
      required:["candidates","uncertainty"],
      properties:_{candidates:_{type:"array",minItems:2,maxItems:3,
          items:Candidate},
        uncertainty:_{type:"string",minLength:1,maxLength:1000}}}.
as_model_local_response_schema('c4-contact-semantic-question-v1',
    "miter_c4_semantic_readings",Schema) :-
    FactRole=_{type:"string",enum:["Balance","Connection","Effortlessness",
      "Gravity","Love","Precision","Sacred","Transformation"]},
    Flourishing=_{type:"string",enum:["AgencyBalance","AttentionStewardship",
      "CognitiveResilience","ConnectionDepth","CreativeTranscendence",
      "PurposeBeyondUtility","SharedUnderstanding","TimeCoherence",
      "WonderPreservation"]},
    Reading=_{type:"object",additionalProperties:false,
      required:["understanding","response_purpose","fact9_roles",
        "flourishing_values","continuity_requirement","counterfactual"],
      properties:_{understanding:_{type:"string",minLength:1,maxLength:300},
        response_purpose:_{type:"string",minLength:1,maxLength:240},
        fact9_roles:_{type:"array",minItems:1,uniqueItems:true,items:FactRole},
        flourishing_values:_{type:"array",minItems:1,uniqueItems:true,
          items:Flourishing},
        continuity_requirement:_{type:"string",enum:["not-material",
          "candidate-content-needed","uncertain"]},
        counterfactual:_{type:"string",minLength:1,maxLength:300}}},
    Schema=_{type:"object",additionalProperties:false,
      required:["readings","uncertainty"],
      properties:_{readings:_{type:"array",minItems:2,maxItems:2,
          items:Reading},
        uncertainty:_{type:"string",minLength:1,maxLength:600}}}.
as_model_local_response_schema('c4-voice-render-question-v1',
    "miter_c4_voice_rendering",Schema) :-
    Schema=_{type:"object",additionalProperties:false,
      required:["utterance","uncertainty","bindings"],
      properties:_{utterance:_{type:"string",minLength:1,maxLength:3000},
        uncertainty:_{type:"string",minLength:1,maxLength:600},
        bindings:_{type:"array",minItems:1,uniqueItems:true,
          items:_{type:"string",minLength:1,maxLength:256}}}}.
as_model_local_response_schema('c4-voice-audit-question-v1',
    "miter_c4_voice_audit",Schema) :-
    Kind=_{type:"string",enum:["semantic-drift","soul-absence",
      "person-not-seen","task-smearing","unsupported-certainty",
      "authority-inflation","coercive-dominance","hidden-scope",
      "tone-mismatch","lost-tension","unsupported-inner-state",
      "unsupported-action","memory-misstatement","source-fidelity",
      "uncertainty-erasure","ungrounded-authority-claim",
      "voice-displacement"]},
    Finding=_{type:"object",additionalProperties:false,
      required:["kind","source_basis","candidate_span",
        "inferred_alteration","why_material","affected_dependency"],
      properties:_{kind:Kind,
        source_basis:_{type:"string",minLength:1,maxLength:600},
        candidate_span:_{type:"string",minLength:1,maxLength:600},
        inferred_alteration:_{type:"string",minLength:1,maxLength:600},
        why_material:_{type:"string",minLength:1,maxLength:600},
        affected_dependency:_{type:"string",minLength:1,maxLength:600}}},
    Schema=_{type:"object",additionalProperties:false,
      required:["findings","uncertainty"],
      properties:_{findings:_{type:"array",maxItems:4,items:Finding},
        uncertainty:_{type:"string",minLength:1,maxLength:600}}}.

as_model_public_question(
    ['c3-semantic-question-v1',QuestionRef,
      [scope,_,_,_],Movement,Source,Openings,Facts,Flourishings,Uncertainty,
      Contract,Resource],
    PublicQuestion) :-
    as_model_public_redact_local_identifiers(
      ['c3-semantic-question-v1',QuestionRef,
        [scope,'private-principal-redacted','private-audience-redacted',
          'private-project-redacted'],
        Movement,Source,Openings,Facts,Flourishings,Uncertainty,Contract,
        Resource],PublicQuestion).
as_model_public_question(
    ['c4-contact-semantic-question-v1',QuestionRef,[scope,_,_,_],
      _Source,['exact-contact-text',_,Text,_],_Movement,
      ['fact9-participation',FactEntries,FactStanding],
      ['flourishing-participation',FlourishingEntries,FlourishingStanding],
      Continuity,Contract,Resource],
    ['c4-contact-semantic-question-v1',
      ['question-reference','current-contact','general-contact-semantics'],
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      ['source-contact','current-contact',
        ['payload-reference','private-local-reference-redacted']],
      ['exact-contact-text','private-content-hash-redacted',Text,
        'private-local-reference-redacted'],
      ['preliminary-movement',
        ['current-native-movement','local-proof-reference-withheld']],
      ['fact9-participation',PublicFactEntries,FactStanding],
      ['flourishing-participation',PublicFlourishingEntries,
        FlourishingStanding],
      PublicContinuity,Contract,Resource]) :-
    QuestionRef=['question-reference',_,'general-contact-semantics'],
    as_model_public_c4_fact_entries(FactEntries,PublicFactEntries),
    as_model_public_c4_flourishing_entries(FlourishingEntries,
      PublicFlourishingEntries),
    as_model_public_c4_continuity(Continuity,PublicContinuity).
as_model_public_question(
    ['c4-voice-render-question-v1',QuestionRef,[scope,_,_,_],
      _Source,['exact-contact-text',_,Text,_],_Movement,Readings,Intention,
      Commitments,Contract,Resource],
    ['c4-voice-render-question-v1',
      ['question-reference','current-contact','voice-rendering'],
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      ['source-contact','current-contact',
        ['payload-reference','private-local-reference-redacted']],
      ['exact-contact-text','private-content-hash-redacted',Text,
        'private-local-reference-redacted'],
      ['native-movement',
        ['current-native-movement','local-proof-reference-withheld']],
      Readings,Intention,PublicCommitments,Contract,Resource]) :-
    as_model_public_c4_voice_commitments(Commitments,PublicCommitments),
    QuestionRef=['question-reference',_,'voice-rendering'].
as_model_public_question(
    ['c4-voice-audit-question-v1',QuestionRef,[scope,_,_,_],
      _Source,['exact-contact-text',_,Text,_],_Movement,Readings,
      ['candidate-rendering',_,Rendering],Commitments,Contract,Resource],
    ['c4-voice-audit-question-v1',
      ['question-reference','current-contact','voice-audit'],
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      ['source-contact','current-contact',
        ['payload-reference','private-local-reference-redacted']],
      ['exact-contact-text','private-content-hash-redacted',Text,
        'private-local-reference-redacted'],
      ['native-movement',
        ['current-native-movement','local-proof-reference-withheld']],
      Readings,
      ['candidate-rendering',['raw-sha256','private-hash-redacted'],Rendering],
      PublicCommitments,Contract,Resource]) :-
    as_model_public_c4_voice_commitments(Commitments,PublicCommitments),
    QuestionRef=['question-reference',_,'voice-audit'].

as_model_public_c4_voice_commitments(
    ['voice-commitments',SourceBound,ScopeBound,MovementBound,Disclosure,
      Relational,InternalClaim,PrivateContext,RevisionContext],
    ['voice-commitments',SourceBound,ScopeBound,MovementBound,Disclosure,
      Relational,InternalClaim,
      PublicContext,RevisionContext]) :-
    as_model_c4_private_context(PrivateContext,_),
    as_model_public_c4_continuity_context(PrivateContext,PublicContext).

as_model_public_c4_continuity_context(
    ['private-continuity-context',Entries,
      'scope-verified-native-candidates-not-authority'],
    ['authorized-continuity-context',PublicEntries,
      'conversation-project-and-personal-context-authorized',
      'credentials-authentication-and-concrete-security-risk-excluded']) :-
    include(as_model_remote_memory_entry_safe,Entries,SafeEntries),
    maplist(as_model_public_c4_memory_entry,SafeEntries,PublicEntries).

as_model_remote_memory_entry_safe(
    ['c4-private-memory-evidence-v1',_,_,_,['body',_,Body]|_]) :-
    as_model_remote_text_security_safe(Body).

as_model_public_c4_memory_entry(
    ['c4-private-memory-evidence-v1',MemoryId,SourceKind,_,['body',_,Body],_,
      'scope-and-capsule-verified','rank-not-authority'],
    ['c4-continuity-evidence-v1',MemoryId,SourceKind,['body',Body],
      'scope-verified','candidate-not-authority']).

as_model_public_c4_fact_entries([],[]).
as_model_public_c4_fact_entries(
    [['c4-fact9-entry',_,['roles',Roles],['material-relations',_],_]|Rest],
    [['c4-fact9-entry','current-contact-fact-expression',['roles',Roles],
      ['material-relations',['current-contact-relation']],
      ['composition','finite-contact-relative-expression']]|PublicRest]) :-
    as_model_public_c4_fact_entries(Rest,PublicRest).

as_model_public_c4_flourishing_entries([],[]).
as_model_public_c4_flourishing_entries(
    [['c4-flourishing-entry',Value,
      ['current-relational-standings',Standings]]|Rest],
    [['c4-flourishing-entry',Value,
      ['current-relational-standings',PublicStandings]]|PublicRest]) :-
    as_model_public_c4_flourishing_standings(Standings,PublicStandings),
    as_model_public_c4_flourishing_entries(Rest,PublicRest).

as_model_public_c4_flourishing_standings([],[]).
as_model_public_c4_flourishing_standings(
    [['flourishing-standing',_,Standing,_]|Rest],
    [['flourishing-standing','current-contact-relation',Standing,
      'native-evidence-present']|PublicRest]) :-
    as_model_public_c4_flourishing_standings(Rest,PublicRest).

as_model_public_c4_continuity(
    ['continuity-participation',['predecessor',Predecessor],
      ['active-organization',ActiveOrganization],
      ['live-undertakings',Undertakings],['present',_],
      ['retrieved-memory-candidates',MemoryCandidates],
      'exact-native-capsule-authority-not-provider-memory'],
    ['continuity-participation',
      ['predecessor',PublicPredecessor],
      ['active-organization',PublicActive],
      ['live-undertaking-count',UndertakingCount],
      ['present',['present-context','current-contact-present',
        'native-present-evidence']],
      ['retrieved-memory-candidate-count',MemoryCount],
      'exact-native-capsule-and-memory-content-withheld']) :-
    as_model_public_c4_presence(Predecessor,'no-predecessor',
      'prior-cut-present',PublicPredecessor),
    as_model_public_c4_presence(ActiveOrganization,
      'no-prior-active-organization','prior-active-organization-present',
      PublicActive),
    length(Undertakings,UndertakingCount),
    length(MemoryCandidates,MemoryCount).

as_model_public_c4_presence(Value,Absent,_,Absent) :- Value==Absent, !.
as_model_public_c4_presence(_,_,Present,Present).

as_model_public_question_valid(Question,PublicQuestion) :-
    as_model_public_question_shape_valid(Question,PublicQuestion),
    \+ as_model_public_has_private_local_identifier(PublicQuestion).

as_model_public_question_shape_valid(
    ['c4-contact-semantic-question-v1',_,_,_,
      ['exact-contact-text',_,Text,_],_,_,_,_,Contract,Resource],
    ['c4-contact-semantic-question-v1',
      ['question-reference','current-contact','general-contact-semantics'],
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      ['source-contact','current-contact',
        ['payload-reference','private-local-reference-redacted']],
      ['exact-contact-text','private-content-hash-redacted',Text,
        'private-local-reference-redacted'],
      ['preliminary-movement',
        ['current-native-movement','local-proof-reference-withheld']],
      ['fact9-participation',[_|_],_],
      ['flourishing-participation',PublicFlourishings,_],
      ['continuity-participation'|_],Contract,Resource]) :-
    length(PublicFlourishings,9).
as_model_public_question_shape_valid(
    ['c4-voice-render-question-v1',_,_,_,
      ['exact-contact-text',_,Text,_],_,Readings,Intention,Commitments,
      Contract,Resource],
    ['c4-voice-render-question-v1',
      ['question-reference','current-contact','voice-rendering'],
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      ['source-contact','current-contact',
        ['payload-reference','private-local-reference-redacted']],
      ['exact-contact-text','private-content-hash-redacted',Text,
        'private-local-reference-redacted'],
      ['native-movement',
        ['current-native-movement','local-proof-reference-withheld']],
      Readings,Intention,PublicCommitments,Contract,Resource]) :-
    as_model_public_c4_voice_commitments(Commitments,PublicCommitments).
as_model_public_question_shape_valid(
    ['c4-voice-audit-question-v1',_,_,_,
      ['exact-contact-text',_,Text,_],_,Readings,
      ['candidate-rendering',_,Rendering],Commitments,Contract,Resource],
    ['c4-voice-audit-question-v1',
      ['question-reference','current-contact','voice-audit'],
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],
      ['source-contact','current-contact',
        ['payload-reference','private-local-reference-redacted']],
      ['exact-contact-text','private-content-hash-redacted',Text,
        'private-local-reference-redacted'],
      ['native-movement',
        ['current-native-movement','local-proof-reference-withheld']],
      Readings,
      ['candidate-rendering',['raw-sha256','private-hash-redacted'],Rendering],
      PublicCommitments,Contract,Resource]) :-
    as_model_public_c4_voice_commitments(Commitments,PublicCommitments).
as_model_public_question_shape_valid(
    ['c3-semantic-question-v1',_,[scope,_,_,_],_,_,_,_,_,_,Contract,
      Resource],
    ['c3-semantic-question-v1',_,
      [scope,'private-principal-redacted','private-audience-redacted',
        'private-project-redacted'],_,_,_,_,_,_,Contract,Resource]).

as_model_public_redact_local_identifiers(Value,Redacted) :-
    is_list(Value), !,
    maplist(as_model_public_redact_local_identifiers,Value,Redacted).
as_model_public_redact_local_identifiers(Value,
    'private-local-identifier-redacted') :-
    as_model_private_local_identifier(Value), !.
as_model_public_redact_local_identifiers(Value,Value).

as_model_public_has_private_local_identifier(Value) :-
    is_list(Value), !, member(Item,Value),
    as_model_public_has_private_local_identifier(Item).
as_model_public_has_private_local_identifier(Value) :-
    as_model_private_local_identifier(Value).

as_model_private_local_identifier(Value) :-
    atom(Value),
    ( sub_atom(Value,0,3,_,mm_)
    ; sub_atom(Value,0,_,_,'surface/raw/')
    ; is_absolute_file_name(Value)
    ).

as_model_request_valid(Profile,Body) :-
    as_dict_atom(Profile,kind,remote),
    is_dict(Body), dict_pairs(Body,_,Pairs), pairs_keys(Pairs,Keys),
    Keys==[max_tokens,messages,model,provider,reasoning_effort,
      response_format,stream,temperature,top_p],
    Body.model=="z-ai/glm-5.3", integer(Body.max_tokens),
    Body.max_tokens>=1, Body.max_tokens=<2048,
    Body.reasoning_effort=="high", Body.stream==false,
    Body.temperature=:=0, Body.top_p=:=1,
    is_dict(Body.response_format),
    Body.response_format.type=="json_schema",
    get_dict(json_schema,Body.response_format,JsonSchema),is_dict(JsonSchema),
    JsonSchema.strict==true,is_dict(JsonSchema.schema),
    Body.messages=[System,User], System.role=="system", User.role=="user",
    string(System.content), string(User.content),
    is_dict(Body.provider), Body.provider.zdr==true,
    Body.provider.data_collection=="deny",
    Body.provider.require_parameters==true,
    Body.provider.allow_fallbacks==true,
    \+ get_dict(authorization,Body,_).
as_model_request_valid(Profile,Body) :-
    as_dict_atom(Profile,kind,local),
    is_dict(Body),dict_pairs(Body,_,Pairs),pairs_keys(Pairs,Keys),
    Keys==[max_tokens,messages,model,response_format,stream,temperature,top_p],
    Body.model==Profile.model,integer(Body.max_tokens),
    Body.max_tokens>=1,Body.max_tokens=<2048,
    Body.stream==false,Body.temperature=:=0,Body.top_p=:=1,
    is_dict(Body.response_format),Body.response_format.type=="json_schema",
    get_dict(json_schema,Body.response_format,JsonSchema),is_dict(JsonSchema),
    JsonSchema.strict==true,is_dict(JsonSchema.schema),
    Body.messages=[System,User],System.role=="system",User.role=="user",
    string(System.content),string(User.content),
    \+ get_dict(authorization,Body,_),\+ get_dict(provider,Body,_),
    \+ get_dict(reasoning_effort,Body,_).

as_model_write_request(Root,Hash,QuestionRef,Scope,Purpose,ResourceId,Profile,
    Body) :-
    as_model_named_json(Root,requests,Hash,Path), \+ exists_file(Path),
    term_string(QuestionRef,QuestionRefText,[quoted(true),ignore_ops(true)]),
    term_string(Scope,ScopeText,[quoted(true),ignore_ops(true)]),
    as_model_authorization_standing(Profile,AuthorizationStanding),
    as_write_json_durable(Path,_{schema:"miter-model-request-v1",
      question_sha256:Hash,question_reference:QuestionRefText,scope:ScopeText,
      purpose:Purpose,resource_id:ResourceId,endpoint:Profile.endpoint,body:Body,
      authorization:AuthorizationStanding,
      standing:"claimed-not-yet-observed"}).

as_model_authorization_standing(Profile,"named-private-credential-redacted") :-
    as_dict_atom(Profile,kind,remote).
as_model_authorization_standing(Profile,"none-loopback-local") :-
    as_dict_atom(Profile,kind,local).

as_model_credential(Root,Profile,Key) :-
    as_dict_atom(Profile,kind,remote),
    as_credential_read(Root,Profile.credential_reference,512,Key).
as_model_credential(_Root,Profile,'no-authorization-loopback-local') :-
    as_dict_atom(Profile,kind,local).

as_model_resource_health(Root,Profile,'remote-credential-available') :-
    as_dict_atom(Profile,kind,remote),as_model_credential(Root,Profile,_).
as_model_resource_health(_Root,Profile,'local-model-available') :-
    as_dict_atom(Profile,kind,local),
    get_dict(endpoint,Profile,"http://127.0.0.1:1234/v1/chat/completions"),
    setup_call_cleanup(
      http_open("http://127.0.0.1:1234/v1/models",In,
        [method(get),status_code(Status),timeout(5),redirect(false),
         request_header('Accept'='application/json')]),
      (set_stream(In,encoding(utf8)),json_read_dict(In,Document)),close(In)),
    Status=:=200,is_dict(Document),get_dict(data,Document,Rows),is_list(Rows),
    get_dict(model,Profile,Model),
    findall(Id,(member(Row,Rows),is_dict(Row),get_dict(id,Row,Id),Id==Model),
      [Model]).

as_model_execute(Root,Hash,QuestionRef,Scope,Question,ResourceId,Profile,Body,
    Key,Deadline,Observation) :-
    as_model_http_options(Profile,Body,Key,Deadline,Status,HttpOptions),
    get_dict(limits,Profile,Limits),
    get_dict(capture_bytes,Limits,CaptureBytes),
    ReadLimit is CaptureBytes+1,
    get_time(Start),
    as_heartbeat_model_lease(Root,Deadline),
    setup_call_cleanup(true,
      catch(call_with_time_limit(Deadline,
        setup_call_cleanup(
          http_open(Profile.endpoint,In,HttpOptions),
          (set_stream(In,encoding(utf8)),
           read_string(In,ReadLimit,Captured)),close(In))),
        Error,true),
      (get_time(TransportEnded),
       as_heartbeat(Root,'assistant-processing',TransportEnded))),
    get_time(End), ElapsedMs is round((End-Start)*1000),
    ( var(Error) ->
        string_length(Captured,Bytes),
        ( Bytes=<CaptureBytes ->
            Raw=Captured,Transport=eof,ErrorClass=none
        ; sub_string(Captured,0,CaptureBytes,_,Raw),
          Transport='capture-limit',
          ErrorClass='response-truncated' )
    ; Raw="", Bytes=0,
      as_model_error_class(Error,Transport,ErrorClass), Status=0 ),
    as_model_named_text(Root,raw,Hash,RawPath),
    as_model_write_text_durable(RawPath,Raw),
    crypto_data_hash(Raw,RawHash,[algorithm(sha256),encoding(utf8)]),
    ( Transport==eof, Status=:=200 ->
        ( as_model_provider_observation(Raw,Question,QuestionRef,Scope,
              ResourceId,Profile,RawHash,Observation) -> true
        ; as_model_provider_failure(Raw,Failure),
          throw(error(model_provider_hold(Failure,ElapsedMs,Bytes),_)) )
    ; throw(error(model_transport_or_schema_hold(Transport,Status,ErrorClass,
        ElapsedMs,Bytes),_)) ).

as_model_http_options(Profile,Body,Key,Deadline,Status,
    [method(post),post(json(Body)),status_code(Status),timeout(Deadline),
     redirect(false),encoding(utf8),
     request_header('Authorization'=Authorization),
     request_header('Content-Type'='application/json'),
     request_header('Accept'='application/json')]) :-
    as_dict_atom(Profile,kind,remote),string_concat("Bearer ",Key,Authorization).
as_model_http_options(Profile,Body,_Key,Deadline,Status,
    [method(post),post(json(Body)),status_code(Status),timeout(Deadline),
     redirect(false),encoding(utf8),
     request_header('Content-Type'='application/json'),
     request_header('Accept'='application/json')]) :-
    as_dict_atom(Profile,kind,local).

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

as_model_provider_envelope(Raw,ExpectedModel,Content,Finish,Usage) :-
    atom_json_dict(Raw,Response,[]), is_dict(Response),
    get_dict(model,Response,ExpectedModel),
    get_dict(choices,Response,[Choice]), is_dict(Choice),
    as_dict_atom(Choice,finish_reason,Finish), Finish==stop,
    get_dict(message,Choice,Message), is_dict(Message),
    get_dict(content,Message,Content), string(Content),
    \+ sub_string(Content,_,_,_,"```"),
    as_model_usage(Response,Usage).

as_model_provider_observation(Raw,Question,QuestionRef,Scope,ResourceId,Profile,
    RawHash,Observation) :-
    get_dict(model,Profile,ExpectedModel),
    as_model_provider_envelope(Raw,ExpectedModel,Content,Finish,Usage),
    atom_string(ModelId,ExpectedModel),
    Question=['c3-semantic-question-v1'|_],
    atom_json_dict(Content,Result,[]), as_model_result(Result,Candidates),
    as_model_candidates_match_question(Candidates,Question),
    Observation=['c3-model-observation-v1',QuestionRef,Scope,ResourceId,
      ModelId,['transport',eof],['http-status',200],
      ['finish-reason',Finish],['raw-sha256',RawHash],
      [candidates,Candidates],Usage,
      'provider-reading-no-contact-no-authority-no-choice'].
as_model_provider_observation(Raw,Question,QuestionRef,Scope,ResourceId,Profile,
    RawHash,Observation) :-
    get_dict(model,Profile,ExpectedModel),
    as_model_provider_envelope(Raw,ExpectedModel,Content,Finish,Usage),
    atom_string(ModelId,ExpectedModel),
    Question=['c4-contact-semantic-question-v1'|_],
    atom_json_dict(Content,Result,[]),
    as_model_c4_semantic_result(Result,Question,Readings),
    Observation=['c4-semantic-observation-v1',QuestionRef,Scope,ResourceId,
      ModelId,['transport',eof],['http-status',200],
      ['finish-reason',Finish],['raw-sha256',RawHash],
      [readings,Readings],Usage,
      'provider-reading-no-contact-no-authority-no-choice'].
as_model_provider_observation(Raw,Question,QuestionRef,Scope,ResourceId,Profile,
    RawHash,Observation) :-
    get_dict(model,Profile,ExpectedModel),
    as_model_provider_envelope(Raw,ExpectedModel,Content,Finish,Usage),
    atom_string(ModelId,ExpectedModel),
    Question=['c4-voice-render-question-v1'|_],
    atom_json_dict(Content,Result,[]),
    as_model_c4_voice_result(Result,Question,Profile,Utterance,Bindings,
      Uncertainty),
    Observation=['c4-voice-observation-v1',QuestionRef,Scope,ResourceId,
      ModelId,['transport',eof],['http-status',200],
      ['finish-reason',Finish],['raw-sha256',RawHash],
      ['rendered-utterance',Utterance,[bindings,Bindings],
        [uncertainty,Uncertainty]],Usage,
      'candidate-rendering-no-effect-authority',
      'structurally-bound-semantic-fidelity-remains-consequence-testable'].
as_model_provider_observation(Raw,Question,QuestionRef,Scope,ResourceId,Profile,
    RawHash,Observation) :-
    get_dict(model,Profile,ExpectedModel),
    as_model_provider_envelope(Raw,ExpectedModel,Content,Finish,Usage),
    atom_string(ModelId,ExpectedModel),
    Question=['c4-voice-audit-question-v1'|_],
    atom_json_dict(Content,Result,[]),
    as_model_c4_voice_audit_json(Result,AuditResult),
    Observation=['c4-voice-audit-observation-v1',QuestionRef,Scope,ResourceId,
      ModelId,['transport',eof],['http-status',200],
      ['finish-reason',Finish],['raw-sha256',RawHash],AuditResult,Usage,
      'candidate-audit-no-movement-or-effect-authority',
      'voice-fidelity-requires-native-use'].

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
    as_model_bounded_text(Uncertainty,1,600),
    get_dict(readings,Result,Rows), is_list(Rows), length(Rows,2),
    maplist(as_model_c4_semantic_row(Question),Rows,Readings),
    maplist(as_model_c4_reading_id,Readings,Ids),
    sort(Ids,Unique), same_length(Ids,Unique).

as_model_c4_semantic_row(Question,Row,
    ['c4-semantic-reading-v1',Id,Understanding,ResponsePurpose,
      ['fact9-roles',Fact9Roles],['flourishing-values',Flourishings],
      ['continuity-requirement',ContinuityRequirement],Counterfactual,
      'model-proposal-only']) :-
    is_dict(Row), as_model_exact_keys(Row,
      [continuity_requirement,counterfactual,fact9_roles,flourishing_values,
        response_purpose,understanding]),
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
    get_dict(continuity_requirement,Row,ContinuityString),
    as_model_string_atom(ContinuityString,ContinuityRequirement),
    memberchk(ContinuityRequirement,
      ['not-material','candidate-content-needed','uncertain']),
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

as_model_c4_voice_result(Result,Question,Profile,Utterance,Bindings,
    Uncertainty) :-
    is_dict(Result), as_model_exact_keys(Result,
      [bindings,uncertainty,utterance]),
    get_dict(utterance,Result,Utterance),
    as_model_bounded_text(Utterance,1,3000),
    get_dict(uncertainty,Result,Uncertainty),
    as_model_bounded_text(Uncertainty,1,600),
    get_dict(bindings,Result,BindingStrings), is_list(BindingStrings),
    BindingStrings=[_|_], maplist(as_model_string_atom,BindingStrings,Bindings0),
    sort(Bindings0,Bindings), same_length(BindingStrings,Bindings),
    as_model_c4_voice_binding_ids(Question,Profile,Available),
    forall(member(Binding,Bindings),memberchk(Binding,Available)).

as_model_c4_voice_audit_json(Result,AuditResult) :-
    is_dict(Result),as_model_exact_keys(Result,[findings,uncertainty]),
    get_dict(findings,Result,Rows),is_list(Rows),length(Rows,Count),Count=<4,
    maplist(as_model_c4_voice_finding_json,Rows,Findings),
    get_dict(uncertainty,Result,Uncertainty),
    as_model_bounded_text(Uncertainty,1,600),
    AuditResult=['voice-audit-reading-v2',['findings',Findings],
      ['uncertainty',Uncertainty],'candidate-fidelity-reading-not-verdict'],
    as_model_c4_voice_audit_reading(AuditResult,Findings).

as_model_c4_voice_finding_json(Row,
    ['voice-audit-finding-v2',Kind,['source-basis',SourceBasis],
      ['candidate-span',CandidateSpan],['inferred-alteration',Alteration],
      ['why-material',WhyMaterial],['affected-dependency',Dependency]]) :-
    is_dict(Row),as_model_exact_keys(Row,
      [affected_dependency,candidate_span,inferred_alteration,kind,
        source_basis,why_material]),
    get_dict(kind,Row,KindString),as_model_string_atom(KindString,Kind),
    get_dict(source_basis,Row,SourceBasis),
    get_dict(candidate_span,Row,CandidateSpan),
    get_dict(inferred_alteration,Row,Alteration),
    get_dict(why_material,Row,WhyMaterial),
    get_dict(affected_dependency,Row,Dependency),
    as_model_c4_voice_finding(
      ['voice-audit-finding-v2',Kind,['source-basis',SourceBasis],
        ['candidate-span',CandidateSpan],['inferred-alteration',Alteration],
        ['why-material',WhyMaterial],['affected-dependency',Dependency]]).

as_model_c4_voice_binding_ids(
    ['c4-voice-render-question-v1',_,_,_,_,_,
      ['semantic-readings',Readings],_,Commitments|_],Profile,Ids) :-
    maplist(as_model_c4_reading_id,Readings,ReadingIds),
    nth0(7,Commitments,PrivateContext),
    as_model_c4_private_context(PrivateContext,Entries),
    ( as_dict_atom(Profile,kind,remote) ->
        include(as_model_remote_memory_entry_safe,Entries,BindableEntries)
    ; as_dict_atom(Profile,kind,local),BindableEntries=Entries ),
    findall(MemoryId,
      member(['c4-private-memory-evidence-v1',MemoryId|_],BindableEntries),
      MemoryIds),
    append(ReadingIds,MemoryIds,Ids).

as_model_string_atom(String,Atom) :-
    string(String), string_length(String,Length), Length>=1, Length=<256,
    atom_string(Atom,String).

as_model_perspective_string_atom(String,Atom) :-
    string(String), atom_string(Atom,String), as_model_perspective(Atom).

as_model_bounded_text(Text,Min,Max) :-
    string(Text), string_length(Text,Length), Length>=Min, Length=<Max,
    string_codes(Text,Codes), maplist(as_model_supported_text_code,Codes).

as_model_supported_text_code(Code) :-
    integer(Code), Code>=0,
    ( memberchk(Code,[9,10,13])
    ; Code>=32, \+ between(127,159,Code) ).

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
      'c4-voice-observation-v1','c4-voice-audit-observation-v1']).

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
      ResourceId,Reason,'no-candidate-admitted']) :-
    Question=[Kind,QuestionRef,Scope|_],
    memberchk(Kind,['c4-contact-semantic-question-v1',
      'c4-voice-render-question-v1','c4-voice-audit-question-v1']), !,
    as_model_question_resource(Question,ResourceId),
    as_model_failure_reason(Error,Reason).
as_model_unavailable(Question,Error,
    ['c3-model-observation-unavailable-v1',QuestionRef,Scope,
      ResourceId,Reason,'no-candidate-admitted']) :-
    ( Question=['c3-semantic-question-v1',QuestionRef,Scope|_] -> true
    ; QuestionRef=['question-reference',unknown,'partial-rap-alignment'],
      Scope=[scope,unknown,unknown,unknown] ),
    as_model_question_resource(Question,ResourceId),
    as_model_failure_reason(Error,Reason).

as_model_question_resource(Question,ResourceId) :-
    is_list(Question),last(Question,Request),
    Request=['resource-request',Candidate|_],
    as_symbol(Candidate,ResourceId),!.
as_model_question_resource(_,'unknown-model-resource').

as_model_failure_reason(uncertain_prior_transmission,
    'uncertain-prior-transmission-no-replay') :- !.
as_model_failure_reason(error(model_transport_or_schema_hold(_,_,_,_,_),_),
    'transport-or-schema-held') :- !.
as_model_failure_reason(error(model_provider_hold(Reason,_,_),_),Reason) :- !.
as_model_failure_reason(error(_,_),'grant-profile-or-mechanical-hold') :- !.
as_model_failure_reason(_,'grant-profile-or-mechanical-hold').
