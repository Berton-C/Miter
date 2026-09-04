% G33 R2 mechanical membrane for bounded continuity-reading candidates.
% PeTTa/MeTTa decides whether a reading participates. This file performs only
% localhost transport, strict JSON handling, literal source-span verification,
% durable recording, and scalar access to the inert generated product.

:- ensure_loaded('miter_llm.pl').
:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

miter_continuity_reading_prepare(Context0, Alias0, Result) :-
    (   miter_lm_nonempty_atom(Context0, Context),
        miter_lm_nonempty_atom(Alias0, Alias)
    ->  (catch(miter_continuity_reading_prepare_checked(Context, Alias, Result0),
               _, Result0 = 'continuity-reading-preparation-error') -> true
        ; Result0 = 'continuity-reading-preparation-error'),
        Result = Result0
    ;   Result = 'invalid-continuity-reading-argument'
    ), !.

miter_continuity_reading_execute(Context0, Result) :-
    (   miter_lm_nonempty_atom(Context0, Context)
    ->  (catch(miter_continuity_reading_execute_checked(Context, Result0),
               Error, miter_continuity_reading_execute_error(Error, Result0)) -> true
        ; Result0 = 'continuity-reading-transport-error'),
        Result = Result0
    ;   Result = 'invalid-continuity-reading-argument'
    ), !.

miter_continuity_reading_execute_error(error(socket_error(_,_),_),
                                       'continuity-reading-provider-unavailable') :- !.
miter_continuity_reading_execute_error(error(timeout_error(_,_),_),
                                       'continuity-reading-provider-timeout') :- !.
miter_continuity_reading_execute_error(_, 'continuity-reading-transport-error').

miter_continuity_reading_parse(Context0, Result) :-
    (   miter_lm_nonempty_atom(Context0, Context)
    ->  (catch(miter_continuity_reading_parse_checked(Context, Result0),
               Error, miter_continuity_reading_parse_error(Error, Result0)) -> true
        ; Result0 = 'continuity-reading-malformed'),
        Result = Result0
    ;   Result = 'invalid-continuity-reading-argument'
    ), !.

miter_continuity_reading_field(Context0, Key0, Value) :-
    catch((miter_lm_nonempty_atom(Context0, Context),
           miter_lm_nonempty_atom(Key0, Key),
           miter_continuity_reading_load(Context, _, Product),
           get_dict(Key, Product, Raw),
           (string(Raw) -> Value=Raw ; atom(Raw) -> Value=Raw ; Value='reading-field-invalid')),
          _, Value='reading-field-unavailable'), !.

miter_continuity_reading_source_status(Context0, Result) :-
    catch((miter_lm_nonempty_atom(Context0, Context),
           miter_continuity_reading_load(Context, _, _)
          -> Result='reading-source-spans-verified'
          ;  Result='reading-source-unverified'),
          _, Result='reading-source-unverified'), !.

miter_continuity_reading_claim_total(Context0, Count) :-
    catch((miter_lm_nonempty_atom(Context0, Context),
           miter_continuity_reading_load(Context, _, Product),
           length(Product.claims, Count0) -> Count=Count0 ; Count= -1),
          _, Count= -1), !.

miter_continuity_reading_relation_count(Context0, Relation0, Count) :-
    catch((miter_lm_nonempty_atom(Context0, Context),
           miter_lm_nonempty_atom(Relation0, Relation),
           miter_continuity_reading_load(Context, _, Product),
           include(miter_continuity_claim_relation(Relation), Product.claims, Matches),
           length(Matches, Count0) -> Count=Count0 ; Count= -1),
          _, Count= -1), !.

miter_continuity_reading_claim_count(Context0, Relation0, Value0, Count) :-
    catch((miter_lm_nonempty_atom(Context0, Context),
           miter_lm_nonempty_atom(Relation0, Relation),
           miter_lm_nonempty_atom(Value0, Value),
           miter_continuity_reading_load(Context, _, Product),
           include(miter_continuity_claim_pair(Relation, Value), Product.claims, Matches),
           length(Matches, Count0) -> Count=Count0 ; Count= -1),
          _, Count= -1), !.

miter_continuity_reading_project_kind(Context0, Kind) :-
    catch((miter_lm_nonempty_atom(Context0, Context),
           miter_continuity_reading_load(Context, _, Product),
           include(miter_continuity_claim_relation('project-kind'), Product.claims, Matches),
           Matches=[Only] -> miter_lm_nonempty_atom(Only.value, Kind)
          ; Kind='continuity-project-kind-not-unique'),
          _, Kind='continuity-project-kind-unavailable'), !.

miter_continuity_reading_prepare_checked(Context, _Alias, Result) :-
    miter_continuity_reading_context(Context, _, _, _, OutputDir),
    miter_continuity_reading_paths(OutputDir, TemplatePath, PreparedPath, _, _, TypedPath),
    (   exists_file(TemplatePath) ; exists_file(PreparedPath) ; exists_file(TypedPath) ), !,
    Result='continuity-reading-output-exists'.
miter_continuity_reading_prepare_checked(Context, Alias, Result) :-
    miter_continuity_reading_context(Context, C, Text, RequestId, OutputDir),
    miter_continuity_source_hash(Text, SourceHash),
    miter_continuity_reading_paths(OutputDir, TemplatePath, PreparedPath, _, _, _),
    miter_continuity_reading_template(RequestId, SourceHash, Text, Template),
    miter_lm_write_json_atomic(TemplatePath, Template),
    miter_lm_prepare_request(C.model_config, Alias, TemplatePath, PreparedPath, Prepared),
    ( Prepared == 'model-request-prepared' -> Result='continuity-reading-request-prepared'
    ; Result=Prepared ).

miter_continuity_reading_execute_checked(Context, Result) :-
    miter_continuity_reading_context(Context, _, _, _, OutputDir),
    miter_continuity_reading_paths(OutputDir, _, PreparedPath, RawPath, TimingPath, _),
    (   \+ exists_file(PreparedPath) -> Result='prepared-request-unavailable'
    ;   (exists_file(RawPath);exists_file(TimingPath)) -> Result='inference-output-exists'
    ;   miter_lm_read_json_file(PreparedPath, Prepared),
        ( miter_lm_prepared_request(Prepared, RequestId, Alias, ModelId, Endpoint, Body) ->
          get_time(StartedAt),
          miter_continuity_http_post_raw(Endpoint, Body, HttpStatus, RawBody),
          get_time(CompletedAt),
          DurationMs is round((CompletedAt-StartedAt)*1000),
          miter_lm_write_text_atomic(RawPath, RawBody),
          miter_lm_write_json_atomic(TimingPath, _{
            schema:'miter-model-timing-v1',request_id:RequestId,alias:Alias,
            model:ModelId,http_status:HttpStatus,started_at_epoch:StartedAt,
            completed_at_epoch:CompletedAt,duration_ms:DurationMs,timeout_seconds:120}),
          (HttpStatus=:=200 -> Result='continuity-reading-raw-stored'
          ; Result='lm-studio-inference-http-error')
        ; Result='invalid-prepared-request' )
    ).

miter_continuity_http_post_raw(Endpoint, Body, HttpStatus, RawBody) :-
    setup_call_cleanup(
      http_open(Endpoint, Stream,
        [method(post),post(json(Body)),status_code(HttpStatus),timeout(120),
         request_header('Accept'='application/json')]),
      read_string(Stream, _, RawBody), close(Stream)).

miter_continuity_reading_parse_checked(Context, Result) :-
    miter_continuity_reading_context(Context, _, Text, RequestId, OutputDir),
    miter_continuity_source_hash(Text, SourceHash),
    miter_continuity_reading_paths(OutputDir, _, _, RawPath, _, TypedPath),
    ( exists_file(TypedPath) -> Result='continuity-reading-candidate-exists'
    ; exists_file(RawPath) ->
      miter_lm_read_json_file(RawPath, ProviderResponse),
      miter_lm_provider_product(ProviderResponse, Product),
      miter_continuity_reading_product(Product, RequestId, SourceHash, Text, Candidate),
      Typed=Candidate.put(_{schema:'miter-continuity-reading-v1',
                            standing:'generated-source-verified-candidate'}),
      miter_lm_write_json_atomic(TypedPath, Typed),
      Result='continuity-reading-candidate-stored'
    ; Result='continuity-reading-response-unavailable' ).

miter_continuity_reading_parse_error(error(continuity_reading_request_mismatch,_),
                                     'continuity-reading-request-mismatch') :- !.
miter_continuity_reading_parse_error(error(continuity_reading_source_mismatch,_),
                                     'continuity-reading-source-mismatch') :- !.
miter_continuity_reading_parse_error(error(continuity_reading_span_mismatch,_),
                                     'continuity-reading-span-mismatch') :- !.
miter_continuity_reading_parse_error(error(continuity_reading_kind_not_named,_),
                                     'continuity-reading-kind-not-named') :- !.
miter_continuity_reading_parse_error(_, 'continuity-reading-malformed').

miter_continuity_reading_context(Context, C, Text, RequestId, OutputDir) :-
    miter_lm_read_json_file(Context, C),
    is_dict(C),
    get_dict(text, C, Text), miter_continuity_bounded_string(Text, 1, 4000),
    get_dict(request_id, C, BaseRequest0), miter_lm_nonempty_atom(BaseRequest0, BaseRequest),
    format(atom(RequestId), '~w-continuity-reading', [BaseRequest]),
    get_dict(output_dir, C, OutputDir0), miter_lm_nonempty_atom(OutputDir0, OutputDir),
    exists_directory(OutputDir),
    get_dict(model_config, C, ModelConfig0), miter_lm_nonempty_atom(ModelConfig0, _).

miter_continuity_reading_paths(OutputDir, Template, Prepared, Raw, Timing, Typed) :-
    directory_file_path(OutputDir, 'continuity-reading-template.json', Template),
    directory_file_path(OutputDir, 'continuity-reading-request.json', Prepared),
    directory_file_path(OutputDir, 'continuity-reading-raw.json', Raw),
    directory_file_path(OutputDir, 'continuity-reading-timing.json', Timing),
    directory_file_path(OutputDir, 'continuity-reading-typed.json', Typed).

miter_continuity_source_hash(Text, Hash) :-
    crypto_data_hash(Text, Hash, [algorithm(sha256), encoding(utf8)]).

miter_continuity_reading_template(RequestId, SourceHash, Text, Template) :-
    format(string(User),
      'Read the SOURCE CONTACT only. Propose a bounded semantic reading; do not answer the request. Each claim must cite one or more exact, case-sensitive substrings copied from SOURCE CONTACT. Use relation "project-kind" only for a kind such as book, manuscript, codebase, or trip; never emit a project ID. Use relation "continuity-facet" for any requested relation, choosing only current-position, last-completed-work, unresolved-question, or next-movement. If the contact does not support a project-kind plus at least one continuity facet, set completion_status to insufficient_evidence and return no claims. Preserve uncertainty as concise prose and list plausible alternative readings when material.\nREQUEST ID: ~w\nSOURCE SHA256: ~w\nSOURCE CONTACT:\n~s',
      [RequestId, SourceHash, Text]),
    ClaimSchema=_{type:"object",properties:_{
      relation:_{type:"string",minLength:1,maxLength:80},
      value:_{type:"string",minLength:1,maxLength:120},
      evidence_spans:_{type:"array",minItems:1,maxItems:3,
        items:_{type:"string",minLength:1,maxLength:240}}},
      required:["relation","value","evidence_spans"],additionalProperties:false},
    ProductSchema=_{type:"object",properties:_{
      request_id:_{type:"string",const:RequestId},
      source_sha256:_{type:"string",const:SourceHash},
      claims:_{type:"array",minItems:0,maxItems:6,items:ClaimSchema},
      alternatives:_{type:"array",minItems:0,maxItems:3,
        items:_{type:"string",minLength:1,maxLength:240}},
      uncertainty:_{type:"string",minLength:1,maxLength:240},
      completion_status:_{type:"string",enum:["complete","insufficient_evidence"]}},
      required:["request_id","source_sha256","claims","alternatives","uncertainty",
                "completion_status"],additionalProperties:false},
    Template=_{schema:'miter-schema-request-v1',request_id:RequestId,
      endpoint:"http://127.0.0.1:1234/v1/chat/completions",body:_{
        messages:[
          _{role:"system",content:"Return only the JSON object required by the supplied schema. Your product is an inert generated reading, not authority, memory, an answer, executable code, or permission."},
          _{role:"user",content:User}],
        response_format:_{type:"json_schema",json_schema:_{
          name:"miter_continuity_reading",strict:true,schema:ProductSchema}},
        temperature:0,top_p:1,reasoning_effort:"none",max_tokens:512,
        seed:3302,stream:false,ttl:300}}.

miter_continuity_reading_product(Product, RequestId, SourceHash, Text, Candidate) :-
    is_dict(Product),
    dict_pairs(Product, _, Pairs), pairs_keys(Pairs, Keys0), sort(Keys0, Keys),
    Keys == [alternatives,claims,completion_status,request_id,source_sha256,uncertainty],
    miter_lm_nonempty_atom(Product.request_id, ProductRequest),
    (ProductRequest==RequestId -> true ; throw(error(continuity_reading_request_mismatch,_))),
    miter_lm_nonempty_atom(Product.source_sha256, ProductHash),
    (ProductHash==SourceHash -> true ; throw(error(continuity_reading_source_mismatch,_))),
    miter_continuity_bounded_string(Product.uncertainty, 1, 240),
    miter_continuity_string_list(Product.alternatives, 0, 3, 240),
    is_list(Product.claims), length(Product.claims, ClaimCount), between(0, 6, ClaimCount),
    maplist(miter_continuity_claim(Text), Product.claims),
    string(Product.completion_status),
    memberchk(Product.completion_status, ["complete","insufficient_evidence"]),
    ( Product.completion_status=="complete" -> ClaimCount>0 ; true ),
    Candidate=_{request_id:Product.request_id,source_sha256:Product.source_sha256,
      claims:Product.claims,alternatives:Product.alternatives,
      uncertainty:Product.uncertainty,completion_status:Product.completion_status}.

miter_continuity_claim(Text, Claim) :-
    is_dict(Claim),
    dict_pairs(Claim, _, Pairs), pairs_keys(Pairs, Keys0), sort(Keys0, Keys),
    Keys == [evidence_spans,relation,value],
    miter_continuity_bounded_string(Claim.relation, 1, 80),
    miter_continuity_bounded_string(Claim.value, 1, 120),
    miter_continuity_string_list(Claim.evidence_spans, 1, 3, 240),
    forall(member(Span, Claim.evidence_spans),
      ( sub_string(Text, _, _, _, Span) -> true
      ; throw(error(continuity_reading_span_mismatch,_)) )),
    ( Claim.relation=="project-kind" ->
      ( miter_continuity_kind_named(Claim.value, Claim.evidence_spans) -> true
      ; throw(error(continuity_reading_kind_not_named,_)) )
    ; true ).

miter_continuity_kind_named(Value, Spans) :-
    string_lower(Value, LowerValue),
    member(Span, Spans), string_lower(Span, LowerSpan),
    sub_string(LowerSpan, _, _, _, LowerValue), !.

miter_continuity_string_list(Values, Minimum, Maximum, StringMaximum) :-
    is_list(Values), length(Values, Count), Count>=Minimum, Count=<Maximum,
    maplist(miter_continuity_bounded_string_(1, StringMaximum), Values).
miter_continuity_bounded_string_(Minimum, Maximum, Value) :-
    miter_continuity_bounded_string(Value, Minimum, Maximum).
miter_continuity_bounded_string(Value, Minimum, Maximum) :-
    string(Value), string_length(Value, Length), Length>=Minimum, Length=<Maximum.

miter_continuity_reading_load(Context, C, Product) :-
    miter_continuity_reading_context(Context, C, Text, RequestId, OutputDir),
    miter_continuity_source_hash(Text, SourceHash),
    miter_continuity_reading_paths(OutputDir, _, _, _, _, TypedPath),
    miter_lm_read_json_file(TypedPath, Product),
    is_dict(Product), Product.schema=="miter-continuity-reading-v1",
    Product.standing=="generated-source-verified-candidate",
    miter_lm_nonempty_atom(Product.request_id, RequestId),
    miter_lm_nonempty_atom(Product.source_sha256, SourceHash),
    maplist(miter_continuity_claim(Text), Product.claims).

miter_continuity_claim_relation(Relation, Claim) :-
    miter_lm_nonempty_atom(Claim.relation, Relation).
miter_continuity_claim_pair(Relation, Value, Claim) :-
    miter_lm_nonempty_atom(Claim.relation, Relation),
    miter_lm_nonempty_atom(Claim.value, Value).
