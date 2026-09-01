:- use_module(library(http/json)).
:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(lists)).
:- ensure_loaded('../../effect_membranes/miter_llm.pl').

:- initialization(main, main).

main([measure, CorpusPath, QwenRoot, NemotronRoot, ResourcesPath, OutputPath]) :- !,
    measure(CorpusPath, QwenRoot, NemotronRoot, ResourcesPath, OutputPath).
main([select, MetricsPath, EvidenceRun, OutputPath]) :- !,
    select_roles(MetricsPath, EvidenceRun, OutputPath).
main(_) :-
    format(user_error,
           'usage: score_and_select.pl measure CORPUS QWEN_ROOT NEMOTRON_ROOT RESOURCES OUTPUT | select METRICS EVIDENCE_RUN OUTPUT~n',
           []),
    halt(64).

measure(CorpusPath, QwenRoot, NemotronRoot, ResourcesPath, OutputPath) :-
    miter_lm_read_json_file(CorpusPath, Corpus),
    Corpus.schema == "miter-g05-bakeoff-corpus-v1",
    score_root(Corpus, QwenRoot, QwenCalls, QwenProfile0),
    score_root(Corpus, NemotronRoot, NemotronCalls, NemotronProfile0),
    miter_lm_read_json_file(ResourcesPath, Resources),
    apply_resource(Resources, QwenProfile0, QwenProfile),
    apply_resource(Resources, NemotronProfile0, NemotronProfile),
    append(QwenCalls, NemotronCalls, Calls),
    Profiles = [QwenProfile, NemotronProfile],
    metrics_digest(Calls, Profiles, Digest),
    Metrics = _{schema:'miter-g05-measurements-v1',
                corpus:CorpusPath, calls:Calls, profiles:Profiles,
                metrics_digest:Digest},
    miter_lm_write_json_atomic(OutputPath, Metrics),
    halt(0).

apply_resource(Resources, Profile0, Profile) :-
    member(Observation, Resources.profiles),
    Observation.alias == Profile0.alias,
    !,
    put_dict(_{observed_model_size_bytes:Observation.observed_model_size_bytes,
               observed_resident_bytes:Observation.observed_resident_bytes,
               resource_measurement:Observation.measurement},
             Profile0, Profile).
apply_resource(_, Profile0, Profile) :-
    put_dict(_{observed_resident_bytes: -1,
               resource_measurement:"unavailable"}, Profile0, Profile).

score_root(Corpus, Root, Calls, Profile) :-
    directory_file_path(Root, 'run-manifest.json', ManifestPath),
    miter_lm_read_json_file(ManifestPath, Manifest),
    Alias = Manifest.alias,
    Model = Manifest.model,
    provider_mode(Manifest.endpoint, ProviderMode),
    findall(Scored,
            ( member(Row, Manifest.calls),
              member(Case, Corpus.cases),
              Case.case_id == Row.case_id,
              score_call(Case, Row, Scored0),
              put_dict(provider_mode, Scored0, ProviderMode, Scored) ),
            Calls),
    aggregate_profile(Alias, Model, ProviderMode, Calls, Profile).

provider_mode(Endpoint, "lm-studio-gpu-jit") :-
    sub_string(Endpoint, _, _, _, ":1234/"), !.
provider_mode(Endpoint, "lm-studio-runtime-cpu-safe") :-
    sub_string(Endpoint, _, _, _, ":1235/"), !.
provider_mode(_, "unclassified-local-provider").

score_call(Case, Row, Scored) :-
    ( exists_file(Row.typed_path),
      catch(miter_lm_read_json_file(Row.typed_path, Typed), _, fail)
    -> SchemaPass = true,
       answer_pass(Case, Typed, AnswerPass),
       completion_pass(Case, Typed, CompletionPass),
       uncertainty_pass(Case, Typed, UncertaintyPass),
       evidence_pass(Case, Typed, EvidencePass)
    ;  SchemaPass = false, AnswerPass = false, CompletionPass = false,
       UncertaintyPass = false, EvidencePass = false
    ),
    bool_score(SchemaPass, A), bool_score(AnswerPass, B),
    bool_score(CompletionPass, C), bool_score(UncertaintyPass, D),
    bool_score(EvidencePass, E), QualityScore is A+B+C+D+E,
    ( exists_file(Row.timing_path),
      catch(miter_lm_read_json_file(Row.timing_path, Timing), _, fail)
    -> DurationMs = Timing.duration_ms
    ;  DurationMs = -1
    ),
    memory_snapshot(Row.lms_ps_path, Row.model, MemoryBytes, ContextLength),
    Scored = _{request_id:Row.request_id, case_id:Row.case_id,
               role:Row.role, repetition:Row.repetition, alias:Row.alias,
               model:Row.model, schema_pass:SchemaPass,
               answer_pass:AnswerPass, completion_pass:CompletionPass,
               uncertainty_pass:UncertaintyPass, evidence_pass:EvidencePass,
               quality_score:QualityScore, duration_ms:DurationMs,
               model_size_bytes:MemoryBytes, context_length:ContextLength,
               typed_path:Row.typed_path, raw_path:Row.raw_path,
               timing_path:Row.timing_path}.

answer_pass(Case, Typed, Pass) :-
    string_lower(Typed.answer, Lower),
    ( forall(member(Required, Case.required_answer_substrings),
             contains_lower(Lower, Required)),
      forall(member(Forbidden, Case.forbidden_answer_substrings),
             \+ contains_lower(Lower, Forbidden))
    -> Pass = true ; Pass = false ).

contains_lower(LowerHaystack, Needle0) :-
    string_lower(Needle0, Needle),
    sub_string(LowerHaystack, _, _, _, Needle).

completion_pass(Case, Typed, Pass) :-
    ( Typed.completion_status == Case.expected_completion_status
    -> Pass = true ; Pass = false ).

uncertainty_pass(Case, Typed, Pass) :-
    U = Typed.uncertainty,
    ( number(U), U >= Case.uncertainty_min, U =< Case.uncertainty_max
    -> Pass = true ; Pass = false ).

evidence_pass(Case, Typed, Pass) :-
    ( forall(member(Required, Case.required_evidence_spans),
             memberchk(Required, Typed.evidence_spans))
    -> Pass = true ; Pass = false ).

bool_score(true, 1).
bool_score(false, 0).

memory_snapshot(Path, Model, Bytes, ContextLength) :-
    ( exists_file(Path),
      catch(miter_lm_read_json_file(Path, Models), _, fail),
      is_list(Models),
      member(Entry, Models),
      ( get_dict(identifier, Entry, Identifier), Identifier == Model
      ; get_dict(modelKey, Entry, ModelKey), ModelKey == Model )
    -> ( get_dict(sizeBytes, Entry, Bytes0) -> Bytes = Bytes0 ; Bytes = -1 ),
       ( get_dict(contextLength, Entry, Context0)
       -> ContextLength = Context0 ; ContextLength = -1 )
    ;  Bytes = -1, ContextLength = -1 ).

aggregate_profile(Alias, Model, ProviderMode, Calls, Profile) :-
    length(Calls, Count),
    include(call_schema_pass, Calls, SchemaCalls), length(SchemaCalls, SchemaCount),
    findall(Q, (member(CallQ, Calls), Q = CallQ.quality_score),
            Qualities),
    sum_list(Qualities, QSum),
    findall(D, (member(CallD, Calls), D = CallD.duration_ms, D >= 0),
            Durations),
    average(Durations, MeanDuration),
    findall(B, (member(CallB, Calls), B = CallB.model_size_bytes, B >= 0),
            Sizes),
    max_or_unknown(Sizes, ModelSize),
    SchemaRate is SchemaCount / Count,
    MeanQuality is QSum / Count,
    Profile = _{alias:Alias, model:Model, provider_mode:ProviderMode,
                call_count:Count,
                schema_rate:SchemaRate, mean_quality_score:MeanQuality,
                mean_duration_ms:MeanDuration, observed_model_size_bytes:ModelSize}.

call_schema_pass(Call) :- Call.schema_pass == true.

average([], -1).
average(Values, Average) :- Values \== [], sum_list(Values, Sum),
    length(Values, Count), Average is Sum / Count.

max_or_unknown([], -1).
max_or_unknown(Values, Maximum) :- Values \== [], max_list(Values, Maximum).

metrics_digest(Calls, Profiles, Digest) :-
    Payload = _{calls:Calls, profiles:Profiles},
    with_output_to(string(Text), json_write_dict(current_output, Payload,
                                                  [width(0)])),
    crypto_data_hash(Text, Digest, [algorithm(sha256), encoding(utf8)]).

select_roles(MetricsPath, EvidenceRun0, OutputPath) :-
    EvidenceRun = EvidenceRun0,
    miter_lm_read_json_file(MetricsPath, Metrics),
    metrics_digest(Metrics.calls, Metrics.profiles, ExpectedDigestAtom),
    atom_string(ExpectedDigestAtom, ExpectedDigest),
    ( ExpectedDigest == Metrics.metrics_digest
    -> select_valid(Metrics, EvidenceRun, OutputPath), halt(0)
    ;  Verdict = _{schema:'miter-g05-role-selection-v1',
                   status:inconsistent_metrics,
                   expected_digest:ExpectedDigest,
                   observed_digest:Metrics.metrics_digest},
       miter_lm_write_json_atomic(OutputPath, Verdict), halt(2)
    ).

select_valid(Metrics, EvidenceRun, OutputPath) :-
    Profiles = Metrics.profiles,
    findall(Role, (member(Call, Metrics.calls), Role = Call.role),
            RoleDuplicates),
    sort(RoleDuplicates, Roles),
    maplist(select_role(Metrics.calls, Profiles), Roles, Assignments),
    overall_default(Profiles, Default),
    Map = _{schema:'miter-model-role-map-v1', status:selected,
            evidence_run:EvidenceRun, metrics_digest:Metrics.metrics_digest,
            selection_policy:'quality-then-10pct-latency-then-10pct-memory-v1',
            default_profile:Default, profiles:Profiles, roles:Assignments},
    miter_lm_write_json_atomic(OutputPath, Map).

select_role(Calls, Profiles, Role, Assignment) :-
    Profiles = [P1, P2],
    role_profile_summary(Calls, Role, P1, S1),
    role_profile_summary(Calls, Role, P2, S2),
    choose_summary(S1, S2, Primary, Standing, Basis),
    ( S1.provider_mode == S2.provider_mode
    -> ResourcesComparable = true
    ;  ResourcesComparable = false ),
    alternatives(Primary, P1.alias, P2.alias, Alternate, EligibleProfiles),
    Assignment = _{role:Role, primary:Primary, alternate:Alternate,
                   eligible_profiles:EligibleProfiles, standing:Standing,
                   basis:Basis,
                   resources_comparable:ResourcesComparable,
                   measurements:[S1,S2]}.

alternatives(Primary, A, B, Alternate, Eligible) :-
    ( Primary == A -> Alternate = B, Eligible = [A,B]
    ; Primary == B -> Alternate = A, Eligible = [B,A]
    ; Alternate = none, Eligible = [A,B] ).

role_profile_summary(Calls, Role, Profile, Summary) :-
    Alias = Profile.alias,
    include(call_for(Role, Alias), Calls, Selected),
    length(Selected, Count),
    findall(Q, (member(CallQ, Selected), Q = CallQ.quality_score), Qs),
    average(Qs, Quality),
    findall(D, (member(CallD, Selected), D = CallD.duration_ms, D >= 0),
            Ds),
    average(Ds, Latency),
    ( Selected = [First|_] -> ProviderMode = First.provider_mode
    ; ProviderMode = "unavailable" ),
    Summary = _{alias:Alias, repetitions:Count, mean_quality_score:Quality,
                mean_duration_ms:Latency,
                observed_model_size_bytes:Profile.observed_model_size_bytes,
                observed_resident_bytes:Profile.observed_resident_bytes,
                provider_mode:ProviderMode}.

call_for(Role, Alias, Call) :- Call.role == Role, Call.alias == Alias.

choose_summary(A, B, Primary, selected, quality) :-
    A.mean_quality_score > B.mean_quality_score, !, Primary = A.alias.
choose_summary(A, B, Primary, selected, quality) :-
    B.mean_quality_score > A.mean_quality_score, !, Primary = B.alias.
choose_summary(A, B, Primary, selected, latency) :-
    A.provider_mode == B.provider_mode,
    A.mean_duration_ms > 0, B.mean_duration_ms > 0,
    A.mean_duration_ms =< B.mean_duration_ms * 0.9, !, Primary = A.alias.
choose_summary(A, B, Primary, selected, latency) :-
    A.provider_mode == B.provider_mode,
    A.mean_duration_ms > 0, B.mean_duration_ms > 0,
    B.mean_duration_ms =< A.mean_duration_ms * 0.9, !, Primary = B.alias.
choose_summary(A, B, Primary, selected, memory) :-
    A.provider_mode == B.provider_mode,
    A.observed_model_size_bytes > 0, B.observed_model_size_bytes > 0,
    A.observed_model_size_bytes =< B.observed_model_size_bytes * 0.9, !,
    Primary = A.alias.
choose_summary(A, B, Primary, selected, memory) :-
    A.provider_mode == B.provider_mode,
    A.observed_model_size_bytes > 0, B.observed_model_size_bytes > 0,
    B.observed_model_size_bytes =< A.observed_model_size_bytes * 0.9, !,
    Primary = B.alias.
choose_summary(_, _, none, no_material_difference, tied_measurements).

overall_default(Profiles, Default) :-
    Profiles = [A,B],
    ( A.schema_rate > B.schema_rate -> Default = A.alias
    ; B.schema_rate > A.schema_rate -> Default = B.alias
    ; A.mean_quality_score > B.mean_quality_score -> Default = A.alias
    ; B.mean_quality_score > A.mean_quality_score -> Default = B.alias
    ; A.provider_mode == B.provider_mode,
      A.mean_duration_ms =< B.mean_duration_ms -> Default = A.alias
    ; A.provider_mode == B.provider_mode -> Default = B.alias
    ; Default = none ).
