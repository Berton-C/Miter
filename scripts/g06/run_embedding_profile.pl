:- ensure_loaded('../../effect_membranes/miter_chroma.pl').
:- use_module(library(http/json)).

:- initialization(main, main).

main(Argv) :-
    (   Argv = [ProfilePath, LocalConfigPath, InputPath,
                RawOnePath, MetadataOnePath,
                RawTwoPath, MetadataTwoPath,
                WrongProfilePath, NegativePath, SummaryPath]
    ->  run(ProfilePath, LocalConfigPath, InputPath,
            RawOnePath, MetadataOnePath,
            RawTwoPath, MetadataTwoPath,
            WrongProfilePath, NegativePath, SummaryPath)
    ;   format(user_error,
               'usage: run_embedding_profile.pl PROFILE LOCAL_CONFIG INPUT RAW1 META1 RAW2 META2 WRONG NEGATIVE SUMMARY~n',
               []),
        halt(64)
    ).

run(ProfilePath, LocalConfigPath, InputPath,
    RawOnePath, MetadataOnePath,
    RawTwoPath, MetadataTwoPath,
    WrongProfilePath, NegativePath, SummaryPath) :-
    miter_chroma_read_json(InputPath, InputFixture),
    get_dict(schema, InputFixture, InputSchema0),
    miter_chroma_nonempty_atom(InputSchema0, InputSchema),
    InputSchema == 'miter-g06-embedding-input-v1',
    get_dict(text, InputFixture, Input),
    miter_chroma_embed_text(ProfilePath, LocalConfigPath, Input,
                            RawOnePath, MetadataOnePath, FirstResult),
    miter_chroma_embed_text(ProfilePath, LocalConfigPath, Input,
                            RawTwoPath, MetadataTwoPath, SecondResult),
    miter_chroma_validate_embedding_response(
        WrongProfilePath, RawOnePath, NegativeResult
    ),
    miter_chroma_read_json(MetadataOnePath, MetadataOne),
    miter_chroma_read_json(MetadataTwoPath, MetadataTwo),
    get_dict(vector_sha256, MetadataOne, FirstVectorHash),
    get_dict(vector_sha256, MetadataTwo, SecondVectorHash),
    get_dict(dimension, MetadataOne, Dimension),
    get_dict(input_sha256, MetadataOne, FirstInputHash),
    get_dict(input_sha256, MetadataTwo, SecondInputHash),
    ( FirstVectorHash == SecondVectorHash -> Deterministic = true
    ; Deterministic = false
    ),
    ( FirstInputHash == SecondInputHash -> InputHashesEqual = true
    ; InputHashesEqual = false
    ),
    Negative = _{
        schema:'miter-g06-negative-control-v1',
        expected_dimension:767,
        observed_dimension:Dimension,
        result:NegativeResult,
        rejected_before_chroma_insertion:true,
        chroma_requests:0
    },
    miter_chroma_write_json_atomic(NegativePath, Negative),
    Summary = _{
        schema:'miter-g06-run-summary-v1',
        profile_id:'embedding-local',
        first_result:FirstResult,
        second_result:SecondResult,
        dimension:Dimension,
        deterministic:Deterministic,
        vector_sha256:FirstVectorHash,
        input_sha256:FirstInputHash,
        input_hashes_equal:InputHashesEqual,
        service_requests:2,
        chroma_requests:0,
        negative_control:NegativeResult
    },
    miter_chroma_write_json_atomic(SummaryPath, Summary),
    (   FirstResult == 'embedding-vector-stored',
        SecondResult == 'embedding-vector-stored',
        Deterministic == true,
        NegativeResult == 'embedding-dimension-mismatch'
    ->  halt(0)
    ;   halt(1)
    ).
