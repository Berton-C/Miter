:- ensure_loaded('../../effect_membranes/miter_chroma_service.pl').
:- initialization(main, main).
main :-
    Q = _{schema:"miter-chroma-request-v1",request_id:"g09-negative",
          idempotency_key:"g09-negative",operation:"add",endpoint:"http://127.0.0.1:8001",
          embedding_profile_sha256:"0bd1ec2ff3f91f5ee51bc8ee665761ccf24bab434518565eff0f8aea3a41dfc0",
          record_id:"must-not-be-inserted", document:"Synthetic forbidden insertion.",
          embedding_response_ref:"runtime/g06/vector.json",
          metadata:_{embedding_profile_sha256:"0bd1ec2ff3f91f5ee51bc8ee665761ccf24bab434518565eff0f8aea3a41dfc0"}},
    miter_cs_write('runtime/g09/wrong-profile.json', Q.put(embedding_profile_sha256,"wrong-version")),
    miter_cs_write('runtime/g09/legacy-target.json', Q.put(endpoint,"file:///Users/bcb/Documents/ClarityOmega/clarityomega/volumes/omegaclaw/chroma_db")),
    miter_cs_write('runtime/g09/legacy-http.json', Q.put(endpoint,"http://127.0.0.1:8000")).
