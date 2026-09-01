:- use_module(library(http/json)).
:- use_module(library(readutil)).
:- use_module(library(filesex)).
:- use_module(library(pcre)).
:- use_module(library(crypto)).

:- initialization(main, main).

main([SourceRoot, DestinationRoot, MutationReportPath]) :-
    directory_file_path(SourceRoot, 'trajectory.jsonl', SourceLedger),
    directory_file_path(DestinationRoot, 'trajectory.jsonl', DestinationLedger),
    make_directory_path(DestinationRoot),
    copy_payload_objects(SourceRoot, DestinationRoot),
    setup_call_cleanup(
        open(SourceLedger, read, Input, [encoding(utf8)]),
        read_lines(Input, Lines),
        close(Input)
    ),
    nth1(2, Lines, OriginalLine),
    re_replace("movement-candidate", "movement-certified",
               OriginalLine, MutatedLine),
    OriginalLine \== MutatedLine,
    replace_nth1(Lines, 2, MutatedLine, MutatedLines),
    setup_call_cleanup(
        open(DestinationLedger, write, Output, [encoding(utf8)]),
        forall(member(Line, MutatedLines), format(Output, '~s~n', [Line])),
        close(Output)
    ),
    crypto_data_hash(OriginalLine, OriginalHash,
                     [algorithm(sha256), encoding(utf8)]),
    crypto_data_hash(MutatedLine, MutatedHash,
                     [algorithm(sha256), encoding(utf8)]),
    Report = _{
        schema:'miter-g07-ledger-mutation-v1',
        modified_line:2,
        replacement:'movement-candidate -> movement-certified',
        original_line_sha256:OriginalHash,
        mutated_line_sha256:MutatedHash,
        hashes_differ:true
    },
    setup_call_cleanup(
        open(MutationReportPath, write, ReportStream, [encoding(utf8)]),
        ( json_write_dict(ReportStream, Report, [width(100)]),
          nl(ReportStream)
        ),
        close(ReportStream)
    ),
    halt(0).
main(_) :-
    format(user_error,
           'usage: make_corrupt_copy.pl SOURCE_ROOT DEST_ROOT REPORT~n', []),
    halt(64).

copy_payload_objects(SourceRoot, DestinationRoot) :-
    directory_file_path(SourceRoot, objects, SourceObjects),
    directory_file_path(SourceObjects, sha256, SourceHashDirectory),
    directory_file_path(DestinationRoot, objects, DestinationObjects),
    directory_file_path(DestinationObjects, sha256, DestinationHashDirectory),
    make_directory_path(DestinationHashDirectory),
    directory_files(SourceHashDirectory, Entries),
    forall(
        ( member(Entry, Entries), Entry \== '.', Entry \== '..' ),
        ( directory_file_path(SourceHashDirectory, Entry, SourcePath),
          directory_file_path(DestinationHashDirectory, Entry, DestinationPath),
          copy_file(SourcePath, DestinationPath)
        )
    ).

read_lines(Stream, Lines) :-
    read_line_to_string(Stream, Line),
    ( Line == end_of_file -> Lines = []
    ; Lines = [Line|Rest], read_lines(Stream, Rest)
    ).

replace_nth1([_|Rest], 1, Replacement, [Replacement|Rest]) :- !.
replace_nth1([Item|Rest], Index, Replacement, [Item|UpdatedRest]) :-
    Index > 1,
    NextIndex is Index - 1,
    replace_nth1(Rest, NextIndex, Replacement, UpdatedRest).
