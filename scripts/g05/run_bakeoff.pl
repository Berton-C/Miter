:- use_module(library(http/json)).
:- use_module(library(filesex)).
:- use_module(library(process)).
:- use_module(library(readutil)).
:- ensure_loaded('../../effect_membranes/miter_llm.pl').

:- initialization(main, main).

main(Argv) :-
    (   Argv = [CorpusPath, ConfigPath, Alias, Endpoint, OutputRoot]
    ->  run_bakeoff(CorpusPath, ConfigPath, Alias, Endpoint, OutputRoot)
    ;   format(user_error,
               'usage: run_bakeoff.pl CORPUS CONFIG ALIAS ENDPOINT OUTPUT_ROOT~n',
               []),
        halt(64)
    ).

run_bakeoff(CorpusPath, ConfigPath, Alias0, Endpoint0, OutputRoot) :-
    Alias = Alias0,
    Endpoint = Endpoint0,
    (   exists_directory(OutputRoot)
    ->  format(user_error, 'output root already exists: ~w~n', [OutputRoot]),
        halt(73)
    ;   true
    ),
    miter_lm_read_json_file(CorpusPath, Corpus),
    valid_corpus(Corpus, Repetitions, Decoding, System, Cases),
    miter_lm_resolve_profile(ConfigPath, Alias, ModelId),
    (   memberchk(ModelId,
                  ['unknown-model-profile', 'local-model-config-unavailable',
                   'invalid-local-model-config', 'local-model-config-io-error'])
    ->  format(user_error, 'profile resolution failed: ~w~n', [ModelId]),
        halt(69)
    ;   true
    ),
    make_directory_path(OutputRoot),
    maplist(run_case(CorpusPath, ConfigPath, Alias, Endpoint, ModelId,
                     OutputRoot, Repetitions, Decoding, System),
            Cases,
            NestedRows),
    append(NestedRows, Rows),
    Manifest = _{
        schema:'miter-g05-bakeoff-run-v1',
        alias:Alias,
        model:ModelId,
        endpoint:Endpoint,
        corpus:CorpusPath,
        repetitions:Repetitions,
        decoding:Decoding,
        calls:Rows
    },
    directory_file_path(OutputRoot, 'run-manifest.json', ManifestPath),
    miter_lm_write_json_atomic(ManifestPath, Manifest),
    (   forall(member(Row, Rows),
               ( Row.transport_status == 'raw-model-response-stored',
                 Row.parse_status == 'semantic-result-valid' ))
    ->  halt(0)
    ;   halt(1)
    ).

valid_corpus(Corpus, Repetitions, Decoding, System, Cases) :-
    is_dict(Corpus),
    Corpus.schema == "miter-g05-bakeoff-corpus-v1",
    Repetitions = Corpus.repetitions,
    integer(Repetitions),
    Repetitions >= 3,
    Decoding = Corpus.decoding,
    is_dict(Decoding),
    System = Corpus.system,
    string(System),
    Cases = Corpus.cases,
    is_list(Cases),
    Cases \== [].

run_case(CorpusPath, ConfigPath, Alias, Endpoint, ModelId, OutputRoot,
         Repetitions, Decoding, System, Case, Rows) :-
    findall(Row,
            ( between(1, Repetitions, Repetition),
              run_one(CorpusPath, ConfigPath, Alias, Endpoint, ModelId,
                      OutputRoot, Decoding, System, Case, Repetition, Row) ),
            Rows).

run_one(_CorpusPath, ConfigPath, Alias, Endpoint, ModelId, OutputRoot,
        Decoding, System, Case, Repetition, Row) :-
    atom_string(CaseId, Case.case_id),
    format(atom(RequestId), 'g05-~w-~w-r~|~`0t~d~2+',
           [CaseId, Alias, Repetition]),
    format(atom(RepetitionDirectory), 'r~|~`0t~d~2+', [Repetition]),
    directory_file_path(OutputRoot, CaseId, CaseDirectory),
    directory_file_path(CaseDirectory, RepetitionDirectory, CallDirectory),
    make_directory_path(CallDirectory),
    directory_file_path(CallDirectory, 'template.json', TemplatePath),
    directory_file_path(CallDirectory, 'request.json', RequestPath),
    directory_file_path(CallDirectory, 'raw.json', RawPath),
    directory_file_path(CallDirectory, 'typed.json', TypedPath),
    directory_file_path(CallDirectory, 'timing.json', TimingPath),
    directory_file_path(CallDirectory, 'lms-ps.json', LmsPsPath),
    request_template(RequestId, Endpoint, Decoding, System, Case.user, Template),
    miter_lm_write_json_atomic(TemplatePath, Template),
    miter_lm_prepare_request(ConfigPath, Alias, TemplatePath, RequestPath,
                             PreparationStatus),
    miter_lm_execute_request(RequestPath, RawPath, TimingPath, TransportStatus),
    miter_lm_parse_result(TemplatePath, RawPath, TypedPath, ParseStatus),
    capture_provider_processes(Endpoint, LmsPsPath, LmsStatus),
    Row = _{
        request_id:RequestId,
        case_id:Case.case_id,
        role:Case.role,
        repetition:Repetition,
        alias:Alias,
        model:ModelId,
        template_path:TemplatePath,
        request_path:RequestPath,
        raw_path:RawPath,
        typed_path:TypedPath,
        timing_path:TimingPath,
        lms_ps_path:LmsPsPath,
        preparation_status:PreparationStatus,
        transport_status:TransportStatus,
        parse_status:ParseStatus,
        lms_ps_status:LmsStatus
    }.

request_template(RequestId, Endpoint, Decoding, System, User, Template) :-
    response_schema(RequestId, ResponseSchema),
    Body = _{
        messages:[_{role:"system", content:System},
                  _{role:"user", content:User}],
        response_format:_{
            type:"json_schema",
            json_schema:_{name:"miter_g05_product", strict:true,
                          schema:ResponseSchema}
        },
        temperature:Decoding.temperature,
        top_p:Decoding.top_p,
        reasoning_effort:Decoding.reasoning_effort,
        seed:Decoding.seed,
        max_tokens:Decoding.max_tokens,
        stream:Decoding.stream,
        ttl:Decoding.ttl
    },
    Template = _{schema:'miter-schema-request-v1',
                 request_id:RequestId, endpoint:Endpoint, body:Body}.

response_schema(RequestId, Schema) :-
    Schema = _{
        type:"object",
        properties:_{
            request_id:_{type:"string", const:RequestId},
            answer:_{type:"string", minLength:1, maxLength:240},
            uncertainty:_{type:"number", minimum:0, maximum:1},
            evidence_spans:_{type:"array", minItems:1, maxItems:3,
                             items:_{type:"string", minLength:1,
                                     maxLength:160}},
            completion_status:_{type:"string",
                                enum:["complete", "insufficient_evidence"]}
        },
        required:["request_id", "answer", "uncertainty",
                  "evidence_spans", "completion_status"],
        additionalProperties:false
    }.

capture_provider_processes(Endpoint, Path, direct_service) :-
    sub_atom(Endpoint, _, _, _, ':1235/'),
    !,
    miter_lm_write_text_atomic(Path, "[]\n").
capture_provider_processes(_, Path, Status) :-
    catch(
        setup_call_cleanup(
            process_create('/Users/bcb/.lmstudio/bin/lms', ['ps', '--json'],
                           [stdout(pipe(Out)), stderr(pipe(Err)), process(Pid)]),
            ( read_string(Out, _, Stdout),
              read_string(Err, _, Stderr),
              process_wait(Pid, Exit),
              ( Exit == exit(0)
              -> miter_lm_write_text_atomic(Path, Stdout), Status = captured
              ;  format(string(Combined), '~s~s', [Stdout, Stderr]),
                 miter_lm_write_text_atomic(Path, Combined), Status = failed
              ) ),
            ( close(Out), close(Err) )
        ),
        _,
        Status = unavailable
    ).
