:- ensure_loaded('../../effect_membranes/miter_memory.pl').
:- initialization(main, main).
main :-
    miter_mem_all('runtime/g10/store',Records),
    miter_cs_write('runtime/g10/records.json',_{schema:"miter-memory-readback-v1",records:Records}),
    miter_store_verify_ledger('runtime/g10/store','runtime/g10/ledger-verification.json',R),
    writeln(R), R == 'trajectory-valid',
    miter_mem_request_base("g10-all-records","get",Q),
    miter_cs_write('runtime/g10/get-request.json',Q),
    miter_chroma_service_request('config/chroma-service.json','config/embedding-profile.json',
      'runtime/g10/get-request.json','runtime/g10/chroma-records.json',CR),
    writeln(CR), CR == 'chroma-records-stored'.
