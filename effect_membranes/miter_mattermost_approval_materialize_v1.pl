% G31 P8 mechanical materialization of an already constructed approval overlay.
% This module has no HTTP, Keychain, model, message, or activation operation.

:- module(miter_mattermost_approval_materialize_v1,[g31_materialize_approval/10]).

:- ensure_loaded('miter_store.pl').
:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- use_module(library(process)).
:- use_module(library(readutil)).

g31_materialize_approval(Root0,RequestPath0,GrantPath0,GrantHash0,
                         ApprovalHash0,ProposalHash0,ClosureHash0,
                         Candidate0,Transport0,Result) :-
    catch((g31_materialize_checked(Root0,RequestPath0,GrantPath0,GrantHash0,
               ApprovalHash0,ProposalHash0,ClosureHash0,Candidate0,Transport0,Result0)
          -> true
          ; Result0=['g31-approval-materialization-failure','contract-failed']),
          Error,g31_materialize_error(Error,Result0)),
    Result=Result0,!.

g31_materialize_checked(Root0,RequestPath0,GrantPath0,GrantHash0,
                        ApprovalHash0,ProposalHash0,ClosureHash0,
                        Candidate0,Transport0,Result) :-
    maplist(g31_atom,[Root0,RequestPath0,GrantPath0,GrantHash0,ApprovalHash0,
                      ProposalHash0,ClosureHash0,Candidate0,Transport0],
                     [Root,RequestPath,GrantPath,GrantHash,ApprovalHash,
                      ProposalHash,ClosureHash,Candidate,Transport]),
    g31_root(Root),atomic_list_concat([Root,'/approval-materialization-request.json'],RequestPath),
    GrantPath=='/Users/claritymiter/miter/config/local/g31/p7-inactive-live-grant-v3.json',
    maplist(g31_sha256,[GrantHash,ApprovalHash,ProposalHash,ClosureHash,Candidate,Transport]),
    g31_file_mode(GrantPath,0o600),g31_file_hash(GrantPath,GrantHash),
    g31_read_json(RequestPath,Request),g31_read_json(GrantPath,Grant),
    g31_request(Request,GrantHash,ApprovalHash,ProposalHash,ClosureHash,
                Candidate,Transport,Overlay),
    g31_source_grant(Grant,Candidate,Transport),
    PrivatePath='/Users/claritymiter/miter/config/local/g31/p8-live-effect-approval-v1.json',
    atomic_list_concat([Root,'/approval-materialization-redacted.json'],PublicPath),
    atomic_list_concat([Root,'/approval-materialization-observation.json'],ObservationPath),
    Private=_{schema:'miter-g31-private-live-effect-approval-v1',
      plan_commit:'070e5ffbed1f82b5c19e6a625f40a501d3fdebc0',
      approval_record_sha256:ApprovalHash,p7_proposal_sha256:ProposalHash,
      p7_closure_sha256:ClosureHash,private_inactive_grant_sha256:GrantHash,
      candidate_hash:Candidate,transport_hash:Transport,approval:Overlay,
      source_private_grant:GrantPath,active:false,network_allowed:false,
      activation:unresolved,activation_started_at:null,expires_at:null},
    Public=_{schema:'miter-g31-redacted-live-effect-approval-v1',
      plan_commit:'070e5ffbed1f82b5c19e6a625f40a501d3fdebc0',
      approval_record_sha256:ApprovalHash,p7_proposal_sha256:ProposalHash,
      p7_closure_sha256:ClosureHash,private_inactive_grant_sha256:GrantHash,
      candidate_hash:Candidate,transport_hash:Transport,
      authority:'berton-explicit',actual_identities_public:false,
      credential_value_returned:false,active:false,network_allowed:false,
      activation:unresolved,network_requests:0,credential_lookups:0,
      post_content_reads:0,message_reads:0,message_writes:0,api_mutations:0,
      private_approval_sha256:pending},
    g31_private_materialize(PrivatePath,Private,PrivateHash),
    put_dict(private_approval_sha256,Public,PrivateHash,PublicFinal),
    g31_public_write(PublicPath,PublicFinal,PublicHash),
    Result=['g31-approval-materialization-observation',ApprovalHash,ProposalHash,
      ClosureHash,GrantHash,Candidate,Transport,true,false,false,unresolved,
      0,0,0,0,0,true],
    g31_public_write(ObservationPath,
      _{native:Result,public_sha256:PublicHash,private_sha256:PrivateHash},_).

g31_request(Dict,GrantHash,ApprovalHash,ProposalHash,ClosureHash,
            Candidate,Transport,Overlay) :-
    is_dict(Dict),g31_key_text(Dict,schema,"miter-g31-approval-materialization-request-v1"),
    g31_key_text(Dict,plan_commit,"070e5ffbed1f82b5c19e6a625f40a501d3fdebc0"),
    g31_key_text(Dict,private_inactive_grant_sha256,GrantHash),
    g31_key_text(Dict,approval_record_sha256,ApprovalHash),
    g31_key_text(Dict,p7_proposal_sha256,ProposalHash),
    g31_key_text(Dict,p7_closure_sha256,ClosureHash),
    g31_key_text(Dict,candidate_hash,Candidate),g31_key_text(Dict,transport_hash,Transport),
    get_dict(active,Dict,Active),Active==false,
    get_dict(network_allowed,Dict,Network),Network==false,
    get_dict(activation,Dict,Activation),g31_same_text(Activation,unresolved),
    get_dict(approval,Dict,Overlay),is_list(Overlay),length(Overlay,15),
    Overlay=[Head|_],g31_same_text(Head,'live-effect-approval-v1'),
    last(Overlay,Last),Last=[ActivationHead,Requirement,State],
    g31_same_text(ActivationHead,activation),
    g31_same_text(Requirement,'separate-record-required'),
    g31_same_text(State,unresolved).

g31_source_grant(Dict,Candidate,Transport) :-
    is_dict(Dict),g31_key_text(Dict,schema,"miter-g31-private-inactive-live-grant-v3"),
    g31_key_text(Dict,candidate_hash,Candidate),g31_key_text(Dict,transport_hash,Transport),
    get_dict(active,Dict,Active),Active==false,
    get_dict(network_allowed,Dict,Network),Network==false,
    get_dict(live_effect_approval,Dict,Approval),g31_same_text(Approval,unresolved),
    get_dict(credential_value,Dict,Credential),Credential==null,
    get_dict(grant,Dict,Grant),is_list(Grant),length(Grant,28),
    last(Grant,Last),Last=[ApprovalHead,ApprovalState],
    g31_same_text(ApprovalHead,'live-effect-approval'),
    g31_same_text(ApprovalState,unresolved).

g31_key_text(Dict,Key,Expected) :- get_dict(Key,Dict,Value),g31_same_text(Value,Expected).
g31_read_json(Path,Dict) :-
    setup_call_cleanup(open(Path,read,In,[encoding(utf8)]),json_read_dict(In,Dict),close(In)).
g31_private_write(Path,Dict,Hash) :-
    file_directory_name(Path,Directory),make_directory_path(Directory),
    chmod(Directory,0o700),g31_write_json(Path,Dict,0o600,Hash).
g31_private_materialize(Path,Dict,Hash) :-
    ( exists_file(Path)
    -> g31_file_mode(Path,0o600),g31_read_json(Path,_),
       g31_render_json(Dict,Rendered),
       crypto_data_hash(Rendered,ExpectedHash,[algorithm(sha256),encoding(utf8)]),
       g31_file_hash(Path,Hash),Hash==ExpectedHash
    ;  g31_private_write(Path,Dict,Hash)
    ).
g31_public_write(Path,Dict,Hash) :- g31_write_json(Path,Dict,0o644,Hash).
g31_write_json(Path,Dict,Mode,Hash) :-
    \+exists_file(Path),g31_render_json(Dict,Rendered),
    file_directory_name(Path,Directory),make_directory_path(Directory),
    atom_concat(Path,'.tmp',Temporary),\+exists_file(Temporary),
    setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
      (chmod(Temporary,Mode),write(Stream,Rendered),flush_output(Stream),
       miter_store_ensure_extension(
        '/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
       miter_store_fsync_stream(Stream)),close(Stream)),
    rename_file(Temporary,Path),g31_file_hash(Path,Hash).
g31_render_json(Dict,Rendered) :-
    with_output_to(string(Rendered),(json_write_dict(current_output,Dict,[width(0)]),nl)).

g31_file_hash(Path,Hash) :- crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]).
g31_file_mode(Path,Expected) :-
    exists_file(Path),\+read_link(Path,_,_),size_file(Path,Size),Size>0,Size=<1048576,
    process_create('/usr/bin/stat',['-f','%Lp',Path],
      [stdout(pipe(Out)),stderr(null),process(Pid)]),
    read_string(Out,32,Raw),close(Out),process_wait(Pid,exit(0)),
    normalize_space(string(Text),Raw),atom_concat('0o',Text,OctalAtom),
    atom_number(OctalAtom,Mode),Mode=:=Expected.
g31_text(Value,Text) :-
    (string(Value)->Text=Value;atom(Value)->atom_string(Value,Text)),
    string_length(Text,N),N>0,N=<4096.
g31_same_text(A,B) :- g31_text(A,AT),g31_text(B,BT),AT==BT.
g31_sha256(Value) :- atom(Value),atom_length(Value,64),re_match('^[a-f0-9]{64}$',Value).
g31_atom(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)),atom_length(Atom,N),N>0.
g31_root(Root) :-
    re_match('^/Users/claritymiter/miter/evidence/G31/p8-[0-9]{3}$',Root),
    exists_directory(Root),\+read_link(Root,_,_).
g31_materialize_error(Error,['g31-approval-materialization-failure',Text]) :-
    term_string(Error,Text,[quoted(true)]).
