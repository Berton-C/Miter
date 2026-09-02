:- ensure_loaded('../../effect_membranes/miter_memory.pl').
:- initialization(main,main).
main :-
    miter_chroma_read_json('runtime/g12/before-collection.json',Before),
    miter_mem_request_base("g12-delete","delete-disposable",Q),
    Delete=Q.put(_{expected_collection_id:Before.details.collection.id,
                  expected_count:3,confirm_disposable:true}),
    miter_cs_write('runtime/g12/delete-request.json',Delete),
    miter_mem_request_base("g12-list","list",List),miter_cs_write('runtime/g12/list-request.json',List),
    miter_chroma_read_json('runtime/g12/corrupt-store/memories/mem-g10-checkpoint.json',Good),
    Bad=Good.put(summary,"Intentionally corrupted synthetic summary; original hash retained."),
    miter_cs_write('runtime/g12/corrupt-store/memories/mem-g10-checkpoint.json',Bad).
