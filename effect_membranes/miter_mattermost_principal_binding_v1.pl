% G31 private principal binder. No network, credential, post, or live effect.

:- module(miter_mattermost_principal_binding_v1,[g31_bind_principal/7]).

:- ensure_loaded('miter_store.pl').
:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- use_module(library(process)).
:- use_module(library(readutil)).

g31_bind_principal(Root0,SelectionPath0,IdentityPath0,ExpectedIdentityHash0,
                   Candidate0,Transport0,Result) :-
    catch((g31_bind_checked(Root0,SelectionPath0,IdentityPath0,
                            ExpectedIdentityHash0,Candidate0,Transport0,Result0)
          -> true
          ; Result0=['g31-principal-binding-failure','contract-failed']),
          Error,g31_bind_error(Error,Result0)),
    Result=Result0,!.

g31_bind_checked(Root0,SelectionPath0,IdentityPath0,ExpectedIdentityHash0,
                 Candidate0,Transport0,Result) :-
    maplist(g31_atom,[Root0,SelectionPath0,IdentityPath0,ExpectedIdentityHash0,
                      Candidate0,Transport0],
                     [Root,SelectionPath,IdentityPath,ExpectedIdentityHash,
                      Candidate,Transport]),
    g31_root(Root),
    SelectionPath=='/Users/claritymiter/miter/config/local/g31/p6-selection-request.json',
    IdentityPath=='/Users/claritymiter/miter/config/local/g31/p5-identity-resolution.json',
    g31_sha256(ExpectedIdentityHash),g31_sha256(Candidate),g31_sha256(Transport),
    g31_file_mode(SelectionPath,0o600),g31_file_mode(IdentityPath,0o600),
    g31_file_hash(IdentityPath,ExpectedIdentityHash),
    g31_read_json(SelectionPath,Selection),g31_read_json(IdentityPath,Identity),
    g31_selection(Selection,SelectedUsername,Authority),
    g31_identity(Identity,Candidate,Transport,Candidates),
    include(g31_username_is(SelectedUsername),Candidates,Matches),
    Matches=[Selected],get_dict(id,Selected,Id0),get_dict(username,Selected,Username0),
    g31_id(Id0,PrincipalId),g31_text(Username0,SelectedUsername),
    g31_hash_text(SelectedUsername,UsernameHash),
    g31_hash_text(PrincipalId,PrincipalHash),
    atomic_list_concat(['/Users/claritymiter/miter/config/local/g31/',
                        'p6-principal-binding.json'],PrivatePath),
    atomic_list_concat([Root,'/principal-binding-redacted.json'],PublicPath),
    atomic_list_concat([Root,'/principal-binding-observation.json'],ObservationPath),
    Private=_{schema:'miter-g31-private-principal-binding-v1',
      source_identity_sha256:ExpectedIdentityHash,
      candidate_hash:Candidate,transport_hash:Transport,
      authority:Authority,selected_human:_{username:SelectedUsername,id:PrincipalId},
      live_effect_approval:unresolved},
    Public=_{schema:'miter-g31-redacted-principal-binding-v1',
      source_identity_sha256:ExpectedIdentityHash,
      candidate_hash:Candidate,transport_hash:Transport,
      authority:Authority,selection_supplied:true,match_count:1,
      username_sha256:UsernameHash,principal_id_sha256:PrincipalHash,
      actual_identity_public:false,live_effect_approval:unresolved,
      network_requests:0,credential_lookups:0,post_content_reads:0,
      message_reads:0,message_writes:0,api_mutations:0,
      private_binding_sha256:pending},
    g31_private_write(PrivatePath,Private,PrivateHash),
    put_dict(private_binding_sha256,Public,PrivateHash,PublicFinal),
    g31_public_write(PublicPath,PublicFinal,PublicHash),
    Result=['g31-principal-binding-observation',Candidate,Transport,
      ExpectedIdentityHash,true,1,UsernameHash,PrincipalHash,Authority,
      unresolved,false,0,0,0,true],
    g31_public_write(ObservationPath,
      _{native:Result,public_sha256:PublicHash,private_sha256:PrivateHash},_).

g31_selection(Dict,Username,'berton-explicit') :-
    is_dict(Dict),get_dict(schema,Dict,Schema),
    g31_text(Schema,"miter-g31-principal-selection-v1"),
    get_dict(selected_username,Dict,Username0),g31_text(Username0,Username),
    get_dict(authority,Dict,Authority),g31_text(Authority,"berton-explicit"),
    get_dict(live_effect_approval,Dict,Approval),g31_text(Approval,"unresolved").

g31_identity(Dict,Candidate,Transport,Candidates) :-
    is_dict(Dict),get_dict(schema,Dict,Schema),
    g31_same_text(Schema,"miter-g31-private-identity-resolution-v1"),
    get_dict(candidate_hash,Dict,C0),g31_same_text(C0,Candidate),
    get_dict(transport_hash,Dict,T0),g31_same_text(T0,Transport),
    get_dict(selected_human,Dict,Selected),g31_same_text(Selected,"unresolved"),
    get_dict(human_candidates,Dict,Candidates),is_list(Candidates).

g31_username_is(Expected,Dict) :-
    is_dict(Dict),get_dict(username,Dict,Value),g31_text(Value,Expected).

g31_read_json(Path,Dict) :-
    setup_call_cleanup(open(Path,read,In,[encoding(utf8)]),
      json_read_dict(In,Dict),close(In)).

g31_private_write(Path,Dict,Hash) :-
    file_directory_name(Path,Directory),make_directory_path(Directory),
    chmod(Directory,0o700),g31_write_json(Path,Dict,0o600,Hash).
g31_public_write(Path,Dict,Hash) :- g31_write_json(Path,Dict,0o644,Hash).

g31_write_json(Path,Dict,Mode,Hash) :-
    \+exists_file(Path),with_output_to(string(Rendered),
      (json_write_dict(current_output,Dict,[width(0)]),nl)),
    file_directory_name(Path,Directory),make_directory_path(Directory),
    atom_concat(Path,'.tmp',Temporary),\+exists_file(Temporary),
    setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
      (chmod(Temporary,Mode),write(Stream,Rendered),flush_output(Stream),
       miter_store_ensure_extension(
        '/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
       miter_store_fsync_stream(Stream)),close(Stream)),
    rename_file(Temporary,Path),g31_file_hash(Path,Hash).

g31_file_hash(Path,Hash) :-
    crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]).
g31_hash_text(Text,Hash) :-
    crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]).
g31_file_mode(Path,Expected) :-
    exists_file(Path),\+read_link(Path,_,_),
    size_file(Path,Size),Size>0,Size=<65536,
    access_file(Path,read),catch(set_prolog_flag(fileerrors,true),_,true),
    exists_file(Path),g31_mode(Path,Mode),Mode=:=Expected.
g31_mode(Path,Mode) :-
    process_create('/usr/bin/stat',['-f','%Lp',Path],
      [stdout(pipe(Out)),stderr(null),process(Pid)]),
    read_string(Out,32,Raw),close(Out),process_wait(Pid,exit(0)),
    normalize_space(string(Text),Raw),number_string(Decimal,Text),
    atom_concat('0o',Text,OctalAtom),atom_number(OctalAtom,Mode),Decimal>=0.

g31_text(Value,Text) :-
    (string(Value)->Text=Value;atom(Value)->atom_string(Value,Text)),
    string_length(Text,N),N>0,N=<512.
g31_same_text(A,B) :- g31_text(A,AT),g31_text(B,BT),AT==BT.
g31_sha256(Value) :- atom(Value),atom_length(Value,64),
    re_match('^[a-f0-9]{64}$',Value).
g31_id(Value,Text) :- g31_text(Value,Text),string_length(Text,26),
    re_match('^[a-z0-9]{26}$',Text).
g31_atom(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)),
    atom_length(Atom,N),N>0.
g31_root(Root) :-
    re_match('^/Users/claritymiter/miter/evidence/G31/p6-[0-9]{3}$',Root),
    exists_directory(Root),\+read_link(Root,_,_).
g31_bind_error(Error,['g31-principal-binding-failure',Text]) :-
    term_string(Error,Text,[quoted(true)]).
