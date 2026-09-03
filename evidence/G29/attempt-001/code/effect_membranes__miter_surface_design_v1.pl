% G29 observation/storage membrane only. Modality and extension meaning stay native.
:- ensure_loaded('miter_store.pl').
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(http/websocket)).
:- use_module(library(pcre)).
:- use_module(library(process)).

sd_root(R,A) :- miter_store_nonempty_atom(R,A),
 re_match('^/Users/claritymiter/miter/evidence/G29/attempt-[0-9]{3}$',A),
 exists_directory(A),sd_no_links(A).
sd_no_links('/Users/claritymiter/miter/evidence/G29') :- !.
sd_no_links(P) :- \+read_link(P,_,_),file_directory_name(P,D),D\==P,sd_no_links(D).
sd_path(R,F0,P) :- sd_root(R,A),miter_store_nonempty_atom(F0,F),
 re_match('^[a-zA-Z0-9_.-]+$',F),\+sub_atom(F,_,_,_,'..'),directory_file_path(A,F,P),\+read_link(P,_,_).
sd_verify(R) :- sd_path(R,'manifest.json',P),rv_json(P,M),M.schema=="miter-g29-freeze-v1",
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','config/surface-event-v1.json','config/surface-effect-v1.json',
  'config/mattermost-design-candidate-v1.json','src/surface_design_v1.metta','src/bootstrap_surface_design_v1.metta',
  'src/surface_extension_v1.metta','src/bootstrap_surface_extension_v1.metta','effect_membranes/miter_surface_design_v1.pl',
  'effect_membranes/miter_surface_extension_v1.pl','effect_membranes/miter_model_stream_v1.pl','effect_membranes/miter_llm.pl']),
  (atom_concat('/Users/claritymiter/miter/',Rel,Path),member(E,M.files),atom_string(Path,E.path))).
sd_input(R,N) :- catch((sd_verify(R),sd_path(R,'input.json',P),rv_json(P,D),rv_native(D.native,N)),_,fail),!.
sd_input(_,['surface-design-input-unavailable']).
sd_runtime(R,['runtime-inventory',[
 ['modality-capability','swi-prolog',Caps,'non-cognitive-effect-membrane','runtime-authorized','no-new-runtime-dependency'],
 ['modality-capability','nodejs',[['capability','process-control']], 'offline-evidence-tooling','runtime-not-authorized','new-runtime-boundary'],
 ['modality-capability','rust',[['capability','process-control']], 'candidate-language','runtime-not-authorized','new-runtime-dependencies']
 ]]) :- sd_verify(R),
 findall(['capability',C],sd_capability(C),Caps).
sd_capability('http-client') :- current_predicate(http_open/3).
sd_capability('json-codec') :- current_predicate(atom_json_dict/3).
sd_capability('websocket-client') :- current_predicate(http_open_websocket/3).
sd_capability('durable-files') :- current_predicate(miter_store_fsync_stream/1).
sd_capability(hashing) :- current_predicate(crypto_file_hash/3).
sd_capability('process-control') :- current_predicate(process_create/3).
sd_nonempty(A,B,true) :- nonvar(A),nonvar(B),term_string(A,AS),term_string(B,BS),string_length(AS,AN),string_length(BS,BN),AN>0,BN>0,!.
sd_nonempty(_,_,false).
sd_save(R,Name0,N,Result) :- catch(
 ((sd_verify(R),miter_store_nonempty_atom(Name0,Name),atom_concat(Name,'.json',F),sd_path(R,F,P),
   (exists_file(P)->rv_json(P,Old),tv_document_native(Old,N);tv_encode(N,Enc),tv_durable_json(P,_{native:N,term:Enc})))
  ->Result=stored;Result='surface-storage-incomplete'),_,Result='surface-storage-incomplete'),!.
