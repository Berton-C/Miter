:- use_module(library(http/json)).
:- use_module(library(filesex)).
:- use_module(library(crypto)).

:- initialization(main, main).

main([SourceRoot, DestinationRoot, ProjectId, ReportPath]) :-
    project_paths(SourceRoot, ProjectId, _SourceProject, SourceCapsules,
                  SourceCurrent),
    project_paths(DestinationRoot, ProjectId, _DestinationProject,
                  DestinationCapsules, DestinationCurrent),
    exists_file(SourceCurrent),
    make_directory_path(DestinationCapsules),
    directory_files(SourceCapsules, Entries),
    include(json_file, Entries, CapsuleFiles),
    maplist(copy_capsule(SourceCapsules, DestinationCapsules),
            CapsuleFiles),
    copy_file(SourceCurrent, DestinationCurrent),
    delete_file(DestinationCurrent),
    maplist(capsule_hash_pair(SourceCapsules), CapsuleFiles, SourcePairs),
    maplist(capsule_hash_pair(DestinationCapsules), CapsuleFiles,
            DestinationPairs),
    SourcePairs == DestinationPairs,
    maplist(hash_record, SourcePairs, HashRecords),
    Report = _{
        schema:'miter-g08-indexless-copy-v1',
        project_id:ProjectId,
        removed_pointer:'current.json',
        source_pointer_existed:true,
        destination_pointer_exists:false,
        capsule_count:2,
        capsules_retained:true,
        capsule_file_sha256:HashRecords,
        timestamp_selection_permitted:false
    },
    setup_call_cleanup(
        open(ReportPath, write, Stream, [encoding(utf8)]),
        ( json_write_dict(Stream, Report, [width(100)]), nl(Stream) ),
        close(Stream)
    ),
    halt(0).
main(_) :-
    format(user_error,
           'usage: make_indexless_copy.pl SOURCE DESTINATION PROJECT_ID REPORT~n',
           []),
    halt(64).

project_paths(Root, ProjectId, ProjectDirectory, CapsulesDirectory,
              CurrentPath) :-
    directory_file_path(Root, projects, ProjectsDirectory),
    directory_file_path(ProjectsDirectory, ProjectId, ProjectDirectory),
    directory_file_path(ProjectDirectory, capsules, CapsulesDirectory),
    directory_file_path(ProjectDirectory, 'current.json', CurrentPath).

json_file(FileName) :-
    atom(FileName),
    file_name_extension(_, json, FileName).

copy_capsule(SourceDirectory, DestinationDirectory, FileName) :-
    directory_file_path(SourceDirectory, FileName, SourcePath),
    directory_file_path(DestinationDirectory, FileName, DestinationPath),
    copy_file(SourcePath, DestinationPath),
    chmod(DestinationPath, 0o600).

capsule_hash_pair(Directory, FileName, FileName-Hash) :-
    directory_file_path(Directory, FileName, Path),
    crypto_file_hash(Path, Hash, [algorithm(sha256), encoding(octet)]).

hash_record(FileName-Hash, _{file:FileName, sha256:Hash}).
