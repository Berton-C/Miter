% Sole supported operator profile for the authority-grounded assistant.
% assistant_operator_base.pl supplies non-cognitive process mechanics; this file
% selects the one cognitive entry and the complete last-known-good closure.

:- include('assistant_operator_base.pl').

as_write_service_entry(Root) :-
    as_operator_repo_root(Repo),
    directory_file_path(Repo,'src/bootstrap.metta',Bootstrap),
    directory_file_path(Root,'service-entry.metta',Entry),
    atom_string(Bootstrap,BootstrapString),atom_string(Root,RootString),
    with_output_to(string(BootstrapLiteral),json_write(current_output,BootstrapString)),
    with_output_to(string(RootLiteral),json_write(current_output,RootString)),
    with_output_to(string(Text),
      (format('!(import! &self ~s)~n',[BootstrapLiteral]),
       format('!(AssistantServiceStartV2 ~s)~n',[RootLiteral]))),
    as_write_text_durable(Entry,Text).

as_lkg_relative_paths([
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC.md',
  'authority/M24.md','authority/M25.md','authority/M25_5.md',
  'authority/M26_0.md','authority/M26_3.md',
  'bin/miter',
  'constitution/authority-manifest.json','constitution/soul.metta',
  'constitution/soul_compass.metta','constitution/fact9_projection.metta',
  'src/soul.metta','src/constitutive_foundation.metta',
  'src/generative_invariance.metta',
  'src/generative_participation.metta',
  'src/authority_inheritance.metta','src/fact9_composition.metta',
  'src/constitutive_authority_joint.metta',
  'src/assistant_reactor_foundation.metta','src/scope_continuity.metta',
  'src/semantic_participation.metta','src/assistant_reactor_authority.metta',
  'src/bootstrap.metta',
  'effect_membranes/integrity.pl','effect_membranes/store.pl',
  'effect_membranes/continuity.pl','effect_membranes/continuity_adapter.pl',
  'effect_membranes/semantic_adapter.pl','effect_membranes/assistant_service.pl',
  'effect_membranes/assistant_operator_base.pl','effect_membranes/assistant_operator.pl',
  'effect_membranes/runtime_extensions/store_posix.c',
  'config/constitutive-projection.json','config/miter.json','config/continuity.json'
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
