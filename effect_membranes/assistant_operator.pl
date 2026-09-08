% Sole supported operator profile for the authority-grounded assistant.
% assistant_operator_base.pl supplies non-cognitive process mechanics; this file
% selects the one cognitive entry and the complete last-known-good closure.

:- include('assistant_operator_base.pl').

as_write_service_entry(Root) :-
    as_lkg_source_root(Root,SourceRoot),
    directory_file_path(SourceRoot,'src/bootstrap.metta',Bootstrap),
    directory_file_path(Root,'service-entry.metta',Entry),
    atom_string(Bootstrap,BootstrapString),atom_string(Root,RootString),
    with_output_to(string(BootstrapLiteral),json_write(current_output,BootstrapString)),
    with_output_to(string(RootLiteral),json_write(current_output,RootString)),
    with_output_to(string(Text),
      (format('!(import! &self ~s)~n',[BootstrapLiteral]),
       format('!(AssistantServiceStartV3 ~s)~n',[RootLiteral]))),
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
  'src/authority_inheritance.metta','src/m24_completion.metta',
  'src/m25_completion.metta',
  'src/m255_completion.metta',
  'src/fact9_composition.metta',
  'src/provisional_dynamics.metta',
  'src/model_participation.metta',
  'src/soul_regeneration.metta',
  'src/constitutive_authority_joint.metta',
  'src/assistant_reactor_foundation.metta','src/scope_continuity.metta',
  'src/semantic_participation.metta','src/assistant_reactor_authority.metta',
  'src/dialogue_participation.metta',
  'src/bootstrap.metta',
  'effect_membranes/integrity.pl','effect_membranes/store.pl',
  'effect_membranes/continuity.pl','effect_membranes/continuity_adapter.pl',
  'effect_membranes/semantic_adapter.pl','effect_membranes/assistant_service.pl',
  'effect_membranes/runtime_continuity.pl',
  'effect_membranes/assistant_operator_base.pl','effect_membranes/assistant_operator.pl',
  'effect_membranes/runtime_extensions/store_posix.c',
  'effect_membranes/runtime_extensions/petta_parallel.pl',
  'effect_membranes/model.pl',
  'effect_membranes/chroma.pl',
  'effect_membranes/mattermost.pl',
  'config/constitutive-projection.json','config/miter.json','config/continuity.json'
]).

as_write_lkg(Root, LkgHash) :-
    as_lkg_source_root(Root,SourceRoot),as_lkg_relative_paths(Paths),
    maplist(as_file_identity(SourceRoot),Paths,Files),
    as_petta_main(Petta), as_file_identity_absolute(Petta,PettaIdentity),
    as_petta_pin(Pin),
    directory_file_path(Root,'service-entry.metta',Entry),
    as_file_identity_absolute(Entry,EntryIdentity),
    directory_file_path(Root,'lib/libmiter_store_posix.dylib',Extension),
    as_file_identity_absolute(Extension,ExtensionIdentity),
    as_lkg_source_relative(SourceRelative),
    Lkg=_{schema:"miter-assistant-lkg-v3",source_root:SourceRelative,
      petta_pin:Pin,files:Files,
      petta:PettaIdentity,entry:EntryIdentity,extension:ExtensionIdentity},
    directory_file_path(Root,'lkg.json',Path), as_write_json_durable(Path,Lkg),
    crypto_file_hash(Path,LkgHash,[algorithm(sha256),encoding(octet)]).

as_verify_lkg(Root, Standing) :-
    ( catch((as_root(Root,_),directory_file_path(Root,'lkg.json',Path),
      miter_store_read_json(Path,Lkg),
      as_lkg_file_bound_to_runtime(Root,Path),
      as_dict_atom(Lkg,schema,'miter-assistant-lkg-v3'),
      get_dict(source_root,Lkg,SourceValue),
      miter_store_nonempty_atom(SourceValue,SourceRelative),
      as_lkg_source_relative(SourceRelative),
      directory_file_path(Root,SourceRelative,SourceRoot),
      get_dict(files,Lkg,Files),is_list(Files),Files=[_|_],
      maplist(as_verify_lkg_source_identity(SourceRoot),Files,SeenPaths),
      sort(SeenPaths,UniquePaths),same_length(SeenPaths,UniquePaths),
      as_lkg_required_paths(RequiredPaths),
      forall(member(Required,RequiredPaths),memberchk(Required,SeenPaths)),
      as_petta_main(PettaPath),get_dict(petta,Lkg,Petta),
      as_verify_absolute_identity(Petta,PettaPath),
      directory_file_path(Root,'service-entry.metta',EntryPath),
      get_dict(entry,Lkg,Entry),as_verify_absolute_identity(Entry,EntryPath),
      directory_file_path(Root,'lib/libmiter_store_posix.dylib',ExtensionPath),
      get_dict(extension,Lkg,Extension),
      as_verify_absolute_identity(Extension,ExtensionPath),
      as_petta_pin(Pin),as_dict_atom(Lkg,petta_pin,Pin)),_,fail)
    -> Standing=verified ; Standing=mismatch ), !.

as_verify_lkg_source_identity(SourceRoot, Dict, Relative) :-
    is_dict(Dict),get_dict(path,Dict,Relative0),
    miter_store_nonempty_atom(Relative0,Relative),
    as_safe_lkg_relative_path(Relative),
    directory_file_path(SourceRoot,Relative,Path),\+ read_link(Path,_,_),
    as_verify_hash(Dict,Path).

as_lkg_file_bound_to_runtime(Root, Path) :-
    directory_file_path(Root,'runtime.json',RuntimePath),
    miter_store_read_json(RuntimePath,Runtime),
    get_dict(lkg_sha256,Runtime,Expected0),as_sha256(Expected0,Expected),
    crypto_file_hash(Path,Expected,[algorithm(sha256),encoding(octet)]).

as_lkg_required_paths([
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC.md',
  'authority/M24.md','authority/M25.md','authority/M25_5.md',
  'authority/M26_0.md','authority/M26_3.md',
  'constitution/authority-manifest.json','constitution/soul.metta',
  'constitution/soul_compass.metta','constitution/fact9_projection.metta',
  'src/bootstrap.metta','src/assistant_reactor_authority.metta',
  'src/soul_regeneration.metta',
  'src/constitutive_authority_joint.metta','src/dialogue_participation.metta',
  'effect_membranes/assistant_service.pl','effect_membranes/store.pl',
  'effect_membranes/integrity.pl','effect_membranes/runtime_continuity.pl',
  'effect_membranes/model.pl','effect_membranes/chroma.pl',
  'effect_membranes/mattermost.pl',
  'effect_membranes/runtime_extensions/petta_parallel.pl',
  'effect_membranes/runtime_extensions/store_posix.c'
]).

:- initialization(miter_assistant_main, main).
