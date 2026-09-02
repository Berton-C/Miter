% Independent record/body hash verifier: does not import Miter implementation.
:- use_module(library(http/json)).
:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- initialization(main, main).
main([Root]) :-
    directory_file_path(Root,memories,Directory),directory_files(Directory,Names),
    forall((member(Name,Names),file_name_extension(_,json,Name)),
      ( directory_file_path(Directory,Name,Path),
        setup_call_cleanup(open(Path,read,S),json_read_dict(S,R),close(S)),
        del_dict(content_hash,R,Expected,R0),
        with_output_to(string(Text),json_write_dict(current_output,R0,[width(0)])),
        crypto_data_hash(Text,H,[algorithm(sha256),encoding(utf8)]),atom_string(H,Expected),
        directory_file_path(Root,R.body_ref,Body),
        crypto_file_hash(Body,BH,[algorithm(sha256),encoding(octet)]),atom_string(BH,R.body_hash),
        format('PASS ~s ~w~n',[R.memory_id,H]) )).
