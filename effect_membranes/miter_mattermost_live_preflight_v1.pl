% G31 P0 read-only local service inventory.
% No HTTP, WebSocket, credential lookup, Docker mutation, or activation exists.

:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- use_module(library(process)).
:- use_module(library(readutil)).

g31_docker_inventory(Output0, Result) :-
    catch(g31_docker_inventory_checked(Output0, Result0), Error,
          g31_inventory_error(Error, Result0)),
    Result = Result0,
    !.

g31_docker_inventory_checked(Output0, Result) :-
    g31_atom(Output0, Output),
    atom_concat('/Users/claritymiter/miter/evidence/G31/', _, Output),
    \+ exists_file(Output),
    Docker = '/Applications/Docker.app/Contents/Resources/bin/docker',
    process_create(Docker, [ps, '--format', '{{json .}}'],
                   [stdout(pipe(Out)), stderr(pipe(Err)), process(Pid)]),
    read_string(Out, _, Stdout),
    read_string(Err, _, Stderr),
    close(Out),
    close(Err),
    process_wait(Pid, Status),
    Status == exit(0),
    Stderr == "",
    split_string(Stdout, "\n", "\n", Lines0),
    exclude(=(""), Lines0, Lines),
    maplist(g31_json_line, Lines, Containers0),
    maplist(g31_public_container, Containers0, Containers),
    include(g31_mattermost_container, Containers, Mattermost),
    maplist(g31_container_name, Mattermost, Names),
    length(Containers, Count),
    length(Mattermost, MattermostCount),
    Evidence = _{
        schema:'miter-g31-local-service-inventory-v1',
        discovery:'docker-ps-read-only',
        container_count:Count,
        mattermost_candidate_count:MattermostCount,
        mattermost_candidates:Mattermost,
        credential_values_read:false,
        network_requests:0,
        docker_mutations:0
    },
    g31_write_json(Output, Evidence),
    crypto_file_hash(Output, Hash, [algorithm(sha256), encoding(octet)]),
    Result = ['g31-service-inventory', 'docker-ps-read-only',
              MattermostCount, Names, Hash, false, 0, 0].

g31_json_line(Line, Dict) :-
    atom_string(Atom, Line),
    atom_json_dict(Atom, Dict, []).

g31_public_container(Input, Output) :-
    Output = _{id:Input.'ID', name:Input.'Names', image:Input.'Image',
               ports:Input.'Ports', status:Input.'Status'}.

g31_mattermost_container(Container) :-
    string_lower(Container.name, Name),
    string_lower(Container.image, Image),
    ( sub_string(Name, _, _, _, "mattermost")
    ; sub_string(Image, _, _, _, "mattermost")
    ).

g31_container_name(Container, Name) :- Name = Container.name.

g31_write_json(Path, Dict) :-
    file_directory_name(Path, Directory),
    make_directory_path(Directory),
    atom_concat(Path, '.tmp', Temporary),
    setup_call_cleanup(open(Temporary, write, Stream, [encoding(utf8)]),
                       (json_write_dict(Stream, Dict, [width(0)]), nl(Stream),
                        flush_output(Stream)),
                       close(Stream)),
    rename_file(Temporary, Path).

g31_atom(Value, Atom) :-
    ( atom(Value) -> Atom = Value
    ; string(Value) -> atom_string(Atom, Value)
    ),
    atom_length(Atom, Length),
    Length > 0.

g31_inventory_error(Error, ['g31-service-inventory-failure', Text]) :-
    term_string(Error, Text, [quoted(true)]).
