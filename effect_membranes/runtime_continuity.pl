% Native Continuity-of-Mind persistence membrane.
%
% This membrane does not summarize, interpret, retrieve by similarity, choose
% attention, or form a movement.  It projects the exact ground organization
% already formed by the one MeTTa reactor into immutable, content-addressed,
% per-scope capsules.  The active checkpoint pointer is the sole commit point
% for a checkpoint generation, so restart cannot silently join a snapshot to a
% different continuity generation.

:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(lists)).

miter_runtime_continuity_prepare(Root, Snapshot, SnapshotHash,
                                 ManifestRelative, ManifestFileHash) :-
    ground(Snapshot), acyclic_term(Snapshot),
    miter_runtime_continuity_term_hash(Snapshot, SnapshotHash),
    miter_runtime_continuity_model(Snapshot, SnapshotHash, Manifest),
    miter_runtime_continuity_write_capsules(Root, Snapshot, Manifest),
    miter_runtime_continuity_term_hash(Manifest, ManifestHash),
    atomic_list_concat(['continuity/native/manifests/',ManifestHash,'.term'],
      ManifestRelative),
    directory_file_path(Root, ManifestRelative, ManifestPath),
    miter_runtime_continuity_write_immutable(ManifestPath, Manifest),
    crypto_file_hash(ManifestPath, ManifestFileHash,
      [algorithm(sha256),encoding(octet)]).

miter_runtime_continuity_verify(Root, Snapshot, Meta) :-
    ground(Snapshot), acyclic_term(Snapshot), is_dict(Meta),
    get_dict(snapshot_sha256, Meta, SnapshotHash0),
    miter_store_nonempty_atom(SnapshotHash0, SnapshotHash),
    miter_runtime_continuity_sha256(SnapshotHash),
    miter_runtime_continuity_term_hash(Snapshot, SnapshotHash),
    miter_runtime_continuity_model(Snapshot, SnapshotHash, ExpectedManifest),
    miter_runtime_continuity_term_hash(ExpectedManifest, ManifestHash),
    atomic_list_concat(['continuity/native/manifests/',ManifestHash,'.term'],
      ExpectedRelative),
    get_dict(continuity_manifest, Meta, ManifestRelative0),
    miter_store_nonempty_atom(ManifestRelative0, ManifestRelative),
    ManifestRelative == ExpectedRelative,
    get_dict(continuity_manifest_sha256, Meta, ManifestFileHash0),
    miter_store_nonempty_atom(ManifestFileHash0, ManifestFileHash),
    miter_runtime_continuity_sha256(ManifestFileHash),
    directory_file_path(Root, ManifestRelative, ManifestPath),
    exists_file(ManifestPath),
    crypto_file_hash(ManifestPath, ManifestFileHash,
      [algorithm(sha256),encoding(octet)]),
    miter_runtime_continuity_read_factorized(ManifestPath, ActualManifest),
    ActualManifest == ExpectedManifest,
    miter_runtime_continuity_verify_capsules(Root, ActualManifest).

miter_runtime_continuity_model(
    ['assistant-snapshot',['state',State],['history',History]], SnapshotHash,
    ['miter-continuity-manifest-v1',SnapshotHash,References,
     ['retention-standing',
      'indefinite-no-age-expiry-explicit-authorized-erasure-repair-or-migration-only'],
     ['semantic-index-standing','rebuildable-projection-never-continuity-authority']]) :-
    is_list(State), is_list(History),
    miter_runtime_continuity_scopes(State, History, Scopes),
    maplist(miter_runtime_continuity_reference(State,History), Scopes, References).

miter_runtime_continuity_scopes(State, History, Scopes) :-
    findall(Scope,
      ( member(Row,State), Row=['active-organization',Scope,_,_]
      ; member(Row,History), Row=['assistant-history',_,_,Scope,_]
      ), ScopeRows),
    sort(ScopeRows, Scopes).

miter_runtime_continuity_reference(State, History, Scope,
    ['continuity-capsule-reference',Scope,CapsuleHash,CapsuleRelative]) :-
    miter_runtime_continuity_capsule(State, History, Scope, Capsule),
    miter_runtime_continuity_term_hash(Capsule, CapsuleHash),
    miter_runtime_continuity_term_hash(Scope, ScopeHash),
    atomic_list_concat(['continuity/native/scopes/',ScopeHash,
      '/capsules/',CapsuleHash,'.term'], CapsuleRelative).

miter_runtime_continuity_capsule(State, History, Scope,
    ['miter-continuity-capsule-v1',Scope,
     ['active-organization',Active],
     Relationship,
     Undertaking,
     Attention,
     ['developmental-organization',ScopedHistory],
     ['raw-source-references',RawReferences],
     Next,
     ['retention-standing',
      'indefinite-no-age-expiry-explicit-authorized-erasure-repair-or-migration-only'],
     ['semantic-index-standing','rebuildable-projection-never-continuity-authority']]) :-
    include(miter_runtime_continuity_active_for(Scope), State, Active),
    include(miter_runtime_continuity_history_for(Scope), History, ScopedHistory),
    miter_runtime_continuity_active_projections(Active, Relationship,
      Undertaking, Attention, Next),
    miter_runtime_continuity_raw_references(Active, ScopedHistory, RawReferences).

miter_runtime_continuity_active_for(Scope,
    ['active-organization',Candidate,_,_]) :- Candidate == Scope.

miter_runtime_continuity_history_for(Scope,
    ['assistant-history',_,_,Candidate,_]) :- Candidate == Scope.

miter_runtime_continuity_active_projections(
    [['active-organization',_,Cut,Movement]],
    ['relationship-organization',CutId,D,Omega,I,C],
    ['undertaking-organization',W,Movement],
    ['attention-organization',Present,Movement],
    ['next-movement',Movement]) :-
    Cut=['constitutive-cut',CutId,_,_,_,_,D,Omega,I,W,C,Present,_,_], !.
miter_runtime_continuity_active_projections([],
    ['relationship-organization-unresolved','no-active-cut'],
    ['undertaking-organization-unresolved','no-active-cut'],
    ['attention-organization-unresolved','no-active-cut'],
    ['next-movement-unresolved','no-active-cut']).

miter_runtime_continuity_raw_references(Active, History, References) :-
    findall(Reference,
      ( member(Container,[Active,History]),
        sub_term(Subterm,Container),
        miter_runtime_continuity_raw_reference(Subterm,Reference)
      ), Rows),
    sort(Rows, References).

miter_runtime_continuity_raw_reference(['payload-reference',Reference],
    ['payload-reference',Reference]).
miter_runtime_continuity_raw_reference(
    ['participant-text-claim',Hash,_,RawReference,_],
    ['raw-source-reference',Hash,RawReference]).

miter_runtime_continuity_write_capsules(Root,
    ['assistant-snapshot',['state',State],['history',History]],
    ['miter-continuity-manifest-v1',_,References,_,_]) :-
    maplist(miter_runtime_continuity_write_capsule(Root,State,History), References).

miter_runtime_continuity_write_capsule(Root, State, History,
    ['continuity-capsule-reference',Scope,CapsuleHash,CapsuleRelative]) :-
    miter_runtime_continuity_capsule(State, History, Scope, Capsule),
    miter_runtime_continuity_term_hash(Capsule, CapsuleHash),
    directory_file_path(Root, CapsuleRelative, CapsulePath),
    miter_runtime_continuity_write_immutable(CapsulePath, Capsule).

miter_runtime_continuity_verify_capsules(Root,
    ['miter-continuity-manifest-v1',_,References,_,_]) :-
    maplist(miter_runtime_continuity_verify_capsule(Root), References).

miter_runtime_continuity_verify_capsule(Root,
    ['continuity-capsule-reference',Scope,CapsuleHash,CapsuleRelative]) :-
    miter_runtime_continuity_term_hash(Scope, ScopeHash),
    atomic_list_concat(['continuity/native/scopes/',ScopeHash,
      '/capsules/',CapsuleHash,'.term'], CapsuleRelative),
    directory_file_path(Root, CapsuleRelative, CapsulePath),
    exists_file(CapsulePath),
    miter_runtime_continuity_read_factorized(CapsulePath, Capsule),
    miter_runtime_continuity_term_hash(Capsule, CapsuleHash),
    Capsule=['miter-continuity-capsule-v1',Scope|_].

miter_runtime_continuity_write_immutable(Path, Term) :-
    ( exists_file(Path) ->
        miter_runtime_continuity_read_factorized(Path, Existing), Existing == Term
    ; term_factorized(Term, Skeleton, Factors),
      Carrier=['miter-factorized-continuity-v1',Skeleton,Factors],
      as_write_term_atomic(Path, Carrier)
    ).

miter_runtime_continuity_read_factorized(Path, Term) :-
    setup_call_cleanup(open(Path,read,Stream,[encoding(utf8)]),
      read_term(Stream,Carrier,[syntax_errors(error)]), close(Stream)),
    Carrier=['miter-factorized-continuity-v1',Skeleton,Factors],
    is_list(Factors),
    as_checkpoint_factors_well_formed(Factors),
    maplist(as_unify_checkpoint_factor, Factors),
    ground(Skeleton), acyclic_term(Skeleton), Term=Skeleton.

miter_runtime_continuity_term_hash(Term, Hash) :-
    ground(Term), acyclic_term(Term),
    term_string(Term, Text, [quoted(true),ignore_ops(true)]),
    crypto_data_hash(Text, Hash, [algorithm(sha256),encoding(utf8)]).

miter_runtime_continuity_sha256(Hash) :-
    atom(Hash), atom_length(Hash,64), atom_codes(Hash,Codes),
    maplist(miter_store_hex_code,Codes).
