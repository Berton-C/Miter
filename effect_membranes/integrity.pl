% Mechanical SHA-256 and loaded-atom snapshot only. No Soul interpretation.
% Inputs: trusted pin path and diagnostic output path. Reads fixed source files
% and the constitutional spaces; never writes sources or runtime atoms.
% Consumers: native SoulStartup. Errors are total and deny readiness.
:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- use_module(library(filesex)).
miter_integrity_sources([
 'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC.md',
 'authority/M24.md','authority/M25.md','authority/M25_5.md',
 'authority/M26_0.md','authority/M26_3.md',
 'constitution/soul.metta','constitution/soul_compass.metta',
 'constitution/fact9_projection.metta','src/soul.metta',
 'src/constitutive_foundation.metta','src/generative_invariance.metta',
 'src/generative_participation.metta',
 'src/authority_inheritance.metta','src/m24_completion.metta',
 'src/m25_completion.metta',
 'src/m255_completion.metta',
 'src/fact9_composition.metta',
 'src/provisional_dynamics.metta',
 'src/model_participation.metta',
 'src/constitutive_authority_joint.metta','effect_membranes/integrity.pl']).
miter_integrity_snapshot(Output, Result) :-
 catch((miter_integrity_measure(D), miter_integrity_write(Output,D)
        -> Result='soul-snapshot-stored'; Result='soul-integrity-error'),
       _, Result='soul-integrity-error'), !.
miter_integrity_verify(Pin, Output, Result) :-
 catch((miter_integrity_measure(D),
        setup_call_cleanup(open(Pin,read,S,[encoding(utf8)]),json_read_dict(S,P),close(S)),
        with_output_to(string(DJ),json_write_dict(current_output,D,[width(0)])),
        with_output_to(string(PJ),json_write_dict(current_output,P,[width(0)])),
        (DJ == PJ -> R='soul-integrity-verified'; R='soul-integrity-mismatch'),
        miter_integrity_write(Output,_{result:R,measured:D,pin:P})
        -> Result=R; Result='soul-integrity-error'),
       _, Result='soul-integrity-error'), !.
miter_integrity_measure(D) :-
 miter_integrity_sources(Paths), maplist(miter_integrity_file,Paths,Files),
 miter_integrity_space('&soul','soul-kernel',Soul, SoulCanonical),
 miter_integrity_space('&compass','flourishing-compass',Compass, CompassCanonical),
 miter_integrity_space('&fact9','fact9-projection',Fact9, Fact9Canonical),
 Count is Soul.atom_count+Compass.atom_count+Fact9.atom_count,
 atomics_to_string([SoulCanonical,CompassCanonical,Fact9Canonical],"\n",Canonical),
 crypto_data_hash(Canonical,Hash,[algorithm(sha256),encoding(utf8)]),
 atom_string(Hash,HashString),
 D=_{schema:"miter-constitutional-integrity-v2",files:Files,
     constitutional_atom_count:Count,
     constitutional_manifest_sha256:HashString,
     spaces:[Soul,Compass,Fact9]}.
miter_integrity_space(Predicate, Label,
                      _{space:Label,atom_count:Count,atom_manifest_sha256:HashString},
                      Canonical) :-
 findall(Text, (current_predicate(Predicate/Arity), functor(Head,Predicate,Arity),
               clause(Head,true), Head=..[_|Atom], ground(Atom),
               with_output_to(string(Text),write_term(Atom,[quoted(true),ignore_ops(true)]))),Raw),
 msort(Raw,Atoms), length(Atoms,Count), atomics_to_string(Atoms,"\n",Canonical),
 crypto_data_hash(Canonical,Hash,[algorithm(sha256),encoding(utf8)]),
 atom_string(Hash,HashString).
miter_integrity_file(Path,_{path:Name,sha256:HashString}) :-
 crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]),
 atom_string(Path,Name), atom_string(Hash,HashString).
miter_integrity_write(Path,D) :-
 (atom(Path);string(Path)), file_directory_name(Path,Dir), make_directory_path(Dir),
 setup_call_cleanup(open(Path,write,S,[encoding(utf8)]),
   (json_write_dict(S,D,[width(0)]),nl(S)),close(S)).
