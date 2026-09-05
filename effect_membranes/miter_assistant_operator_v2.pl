% AMA-1.2 R3 operator profile for the authority-grounded assistant v2 entry.
% The promoted v1 operator remains the shared deterministic process substrate and
% rollback artifact. This profile changes only the service entry and exact LKG;
% it creates no second runtime and makes no semantic choice.

:- multifile user:term_expansion/2.

user:term_expansion(Term, []) :-
    prolog_load_context(file, File),
    file_base_name(File, 'miter_assistant_operator_v1.pl'),
    as2_suppressed_v1_term(Term).

as2_suppressed_v1_term((:- initialization(miter_assistant_main, main))).
as2_suppressed_v1_term((Head :- _)) :-
    functor(Head, Name, _),
    memberchk(Name, [as_write_service_entry,as_write_lkg,as_verify_lkg]).
as2_suppressed_v1_term(Head) :-
    functor(Head, as_lkg_relative_paths, 1).

:- include('miter_assistant_operator_v1.pl').

as_write_service_entry(Root) :-
    as_operator_repo_root(Repo),
    directory_file_path(Repo,'src/bootstrap_assistant_v2.metta',Bootstrap),
    directory_file_path(Root,'service-entry.metta',Entry),
    atom_string(Bootstrap,BootstrapString),atom_string(Root,RootString),
    with_output_to(string(BootstrapLiteral),json_write(current_output,BootstrapString)),
    with_output_to(string(RootLiteral),json_write(current_output,RootString)),
    with_output_to(string(Text),
      (format('!(import! &self ~s)~n',[BootstrapLiteral]),
       format('!(AssistantServiceStartV2 ~s)~n',[RootLiteral]))),
    as_write_text_durable(Entry,Text).

as_lkg_relative_paths([
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md',
  'bin/miter',
  'constitution/authority-manifest.json','constitution/soul.metta',
  'constitution/soul_compass_v02.metta','constitution/fact9_projection_v1.metta',
  'src/soul.metta','src/constitutive_participation_v1.metta',
  'src/authority_inheritance_v1.metta','src/constitutive_participation_v2.metta',
  'src/assistant_reactor_v1.metta','src/assistant_scope_continuity_v1.metta',
  'src/assistant_semantic_participation_v1.metta','src/bootstrap_assistant_v1.metta',
  'src/assistant_reactor_v2.metta','src/bootstrap_assistant_v2.metta',
  'effect_membranes/miter_integrity.pl','effect_membranes/miter_store.pl',
  'effect_membranes/miter_assistant_service_v1.pl',
  'effect_membranes/miter_assistant_continuity_v1.pl',
  'effect_membranes/miter_assistant_semantic_v1.pl',
  'effect_membranes/miter_assistant_operator_v1.pl',
  'effect_membranes/miter_assistant_operator_v2.pl',
  'effect_membranes/runtime_extensions/miter_store_posix.c',
  'config/constitutive-projection-v1.json','config/miter-assistant-v1.json',
  'config/miter-assistant-continuity-v1.json',
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/plan.json',
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json',
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R1/plan.json',
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/plan.json'
]).

as_write_lkg(Root, LkgHash) :-
    as_operator_repo_root(Repo), as_lkg_relative_paths(Paths),
    maplist(as_file_identity(Repo),Paths,Files),
    as_petta_main(Petta), as_file_identity_absolute(Petta,PettaIdentity),
    as_petta_pin(Pin),
    directory_file_path(Root,'service-entry.metta',Entry),
    as_file_identity_absolute(Entry,EntryIdentity),
    directory_file_path(Root,'lib/libmiter_store_posix.dylib',Extension),
    as_file_identity_absolute(Extension,ExtensionIdentity),
    Lkg=_{schema:"miter-assistant-lkg-v2",petta_pin:Pin,files:Files,
      petta:PettaIdentity,entry:EntryIdentity,extension:ExtensionIdentity},
    directory_file_path(Root,'lkg.json',Path), as_write_json_durable(Path,Lkg),
    crypto_file_hash(Path,LkgHash,[algorithm(sha256),encoding(octet)]).

as_verify_lkg(Root, Standing) :-
    ( catch((as_root(Root,_),directory_file_path(Root,'lkg.json',Path),
      miter_store_read_json(Path,Lkg),as_dict_atom(Lkg,schema,'miter-assistant-lkg-v2'),
      as_operator_repo_root(Repo),as_lkg_relative_paths(ExpectedPaths),
      get_dict(files,Lkg,Files),maplist(as_verify_relative_identity(Repo),Files,SeenPaths),
      SeenPaths==ExpectedPaths,
      get_dict(petta,Lkg,Petta),as_verify_absolute_identity(Petta,_),
      get_dict(entry,Lkg,Entry),as_verify_absolute_identity(Entry,_),
      get_dict(extension,Lkg,Extension),as_verify_absolute_identity(Extension,_),
      as_petta_pin(Pin),as_dict_atom(Lkg,petta_pin,Pin)),_,fail)
    -> Standing=verified ; Standing=mismatch ), !.

:- initialization(miter_assistant_main, main).
