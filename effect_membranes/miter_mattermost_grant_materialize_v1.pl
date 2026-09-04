% G31 P7 mechanical private-ID materialization for an already constructed grant.
% No network, credential lookup, post read, message, approval, or activation.

:- module(miter_mattermost_grant_materialize_v1,[g31_materialize_grant/9]).

:- ensure_loaded('miter_store.pl').
:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- use_module(library(process)).
:- use_module(library(readutil)).

g31_materialize_grant(Root0,RequestPath0,IdentityPath0,BindingPath0,
                      IdentityHash0,BindingHash0,Candidate0,Transport0,Result) :-
    catch((g31_materialize_checked(Root0,RequestPath0,IdentityPath0,BindingPath0,
               IdentityHash0,BindingHash0,Candidate0,Transport0,Result0)
          -> true
          ; Result0=['g31-grant-materialization-failure','contract-failed']),
          Error,g31_materialize_error(Error,Result0)),
    Result=Result0,!.

g31_materialize_checked(Root0,RequestPath0,IdentityPath0,BindingPath0,
                        IdentityHash0,BindingHash0,Candidate0,Transport0,Result) :-
    maplist(g31_atom,[Root0,RequestPath0,IdentityPath0,BindingPath0,
                      IdentityHash0,BindingHash0,Candidate0,Transport0],
                     [Root,RequestPath,IdentityPath,BindingPath,
                      IdentityHash,BindingHash,Candidate,Transport]),
    g31_root(Root),atomic_list_concat([Root,'/grant-materialization-request.json'],RequestPath),
    IdentityPath=='/Users/claritymiter/miter/config/local/g31/p5-identity-resolution.json',
    BindingPath=='/Users/claritymiter/miter/config/local/g31/p6-principal-binding.json',
    maplist(g31_sha256,[IdentityHash,BindingHash,Candidate,Transport]),
    g31_file_mode(IdentityPath,0o600),g31_file_mode(BindingPath,0o600),
    g31_file_hash(IdentityPath,IdentityHash),g31_file_hash(BindingPath,BindingHash),
    g31_read_json(RequestPath,Request),g31_read_json(IdentityPath,Identity),
    g31_read_json(BindingPath,Binding),
    g31_request(Request,IdentityHash,BindingHash,Candidate,Transport,Grant,Hashes),
    g31_identity(Identity,Candidate,Transport,IdentityValues),
    g31_binding(Binding,IdentityHash,Candidate,Transport,HumanId,HumanUsername),
    g31_human_in_identity(Identity,HumanId,HumanUsername),
    g31_hashes_match(Hashes,IdentityValues,HumanId),
    atomic_list_concat(['/Users/claritymiter/miter/config/local/g31/',
                        'p7-inactive-live-grant-v3.json'],PrivatePath),
    atomic_list_concat([Root,'/grant-materialization-redacted.json'],PublicPath),
    atomic_list_concat([Root,'/grant-materialization-observation.json'],ObservationPath),
    IdentityValues=identity_values(ServerUrl,ServerId,TeamName,TeamId,
      AllowName,AllowId,DeniedName,DeniedId,BotUsername,BotId),
    Private=_{schema:'miter-g31-private-inactive-live-grant-v3',
      plan_commit:'0d13d64bebdb40524b1e7af9d0676c553167d889',
      candidate_hash:Candidate,transport_hash:Transport,
      source_identity_sha256:IdentityHash,source_binding_sha256:BindingHash,
      grant:Grant,
      identity_bindings:_{server:_{url:ServerUrl,id:ServerId},
        team:_{name:TeamName,id:TeamId},
        allowlisted_channel:_{name:AllowName,id:AllowId},
        denied_control_channel:_{name:DeniedName,id:DeniedId},
        human:_{username:HumanUsername,id:HumanId},
        bot:_{username:BotUsername,id:BotId}},
      credential_reference:_{source:'macos-keychain',account:bcb,
        service:'ai.bgi.miter.mattermost'},credential_value:null,
      active:false,network_allowed:false,live_effect_approval:unresolved},
    Public=_{schema:'miter-g31-redacted-grant-materialization-v1',
      plan_commit:'0d13d64bebdb40524b1e7af9d0676c553167d889',
      candidate_hash:Candidate,transport_hash:Transport,
      source_identity_sha256:IdentityHash,source_binding_sha256:BindingHash,
      identity_hashes:Hashes,exact_private_bindings:true,
      actual_identities_public:false,credential_value_returned:false,
      active:false,network_allowed:false,live_effect_approval:unresolved,
      network_requests:0,credential_lookups:0,post_content_reads:0,
      message_reads:0,message_writes:0,api_mutations:0,
      private_grant_sha256:pending},
    g31_private_materialize(PrivatePath,Private,PrivateHash),
    put_dict(private_grant_sha256,Public,PrivateHash,PublicFinal),
    g31_public_write(PublicPath,PublicFinal,PublicHash),
    Result=['g31-grant-materialization-observation',Candidate,Transport,
      IdentityHash,BindingHash,true,false,false,unresolved,0,0,0,0,true],
    g31_public_write(ObservationPath,
      _{native:Result,public_sha256:PublicHash,private_sha256:PrivateHash},_).

g31_request(Dict,IdentityHash,BindingHash,Candidate,Transport,Grant,Hashes) :-
    is_dict(Dict),g31_key_text(Dict,schema,"miter-g31-grant-materialization-request-v1"),
    g31_key_text(Dict,plan_commit,"0d13d64bebdb40524b1e7af9d0676c553167d889"),
    g31_key_text(Dict,candidate_hash,Candidate),g31_key_text(Dict,transport_hash,Transport),
    g31_key_text(Dict,source_identity_sha256,IdentityHash),
    g31_key_text(Dict,source_binding_sha256,BindingHash),
    get_dict(identity_hashes,Dict,Hashes),is_dict(Hashes),
    get_dict(live_effect_approval,Dict,Approval),g31_same_text(Approval,unresolved),
    get_dict(grant,Dict,Grant),is_list(Grant),length(Grant,28),
    Grant=[Head|_],g31_same_text(Head,'live-grant-v3'),
    last(Grant,Last),Last=[ApprovalHead,ApprovalValue],
    g31_same_text(ApprovalHead,'live-effect-approval'),
    g31_same_text(ApprovalValue,unresolved).

g31_identity(Dict,Candidate,Transport,
             identity_values(ServerUrl,ServerId,TeamName,TeamId,
               AllowName,AllowId,DeniedName,DeniedId,BotUsername,BotId)) :-
    is_dict(Dict),g31_key_text(Dict,schema,"miter-g31-private-identity-resolution-v1"),
    g31_key_text(Dict,candidate_hash,Candidate),g31_key_text(Dict,transport_hash,Transport),
    get_dict(server,Dict,Server),get_dict(url,Server,ServerUrl0),
    get_dict(id,Server,ServerId0),g31_text(ServerUrl0,ServerUrl),g31_id(ServerId0,ServerId),
    get_dict(team,Dict,Team),get_dict(name,Team,TeamName0),get_dict(id,Team,TeamId0),
    g31_text(TeamName0,TeamName),g31_id(TeamId0,TeamId),
    get_dict(allowlisted_channel,Dict,Allow),get_dict(name,Allow,AllowName0),
    get_dict(id,Allow,AllowId0),g31_text(AllowName0,AllowName),g31_id(AllowId0,AllowId),
    get_dict(denied_control_channel,Dict,Denied),get_dict(name,Denied,DeniedName0),
    get_dict(id,Denied,DeniedId0),g31_text(DeniedName0,DeniedName),g31_id(DeniedId0,DeniedId),
    get_dict(bot,Dict,Bot),get_dict(username,Bot,BotUsername0),get_dict(id,Bot,BotId0),
    g31_text(BotUsername0,BotUsername),g31_id(BotId0,BotId).

g31_binding(Dict,IdentityHash,Candidate,Transport,HumanId,HumanUsername) :-
    is_dict(Dict),g31_key_text(Dict,schema,"miter-g31-private-principal-binding-v1"),
    g31_key_text(Dict,source_identity_sha256,IdentityHash),
    g31_key_text(Dict,candidate_hash,Candidate),g31_key_text(Dict,transport_hash,Transport),
    g31_key_text(Dict,authority,"berton-explicit"),
    g31_key_text(Dict,live_effect_approval,"unresolved"),
    get_dict(selected_human,Dict,Human),get_dict(id,Human,HumanId0),
    get_dict(username,Human,HumanUsername0),g31_id(HumanId0,HumanId),
    g31_text(HumanUsername0,HumanUsername).

g31_human_in_identity(Identity,HumanId,HumanUsername) :-
    get_dict(human_candidates,Identity,Candidates),
    include(g31_human_is(HumanId,HumanUsername),Candidates,Matches),Matches=[_].
g31_human_is(Id,Username,Dict) :-
    is_dict(Dict),get_dict(id,Dict,Id0),get_dict(username,Dict,Username0),
    g31_same_text(Id0,Id),g31_same_text(Username0,Username).

g31_hashes_match(Hashes,Values,HumanId) :-
    Values=identity_values(_,ServerId,_,TeamId,_,AllowId,_,DeniedId,_,BotId),
    g31_hash_field(Hashes,server,ServerId),g31_hash_field(Hashes,team,TeamId),
    g31_hash_field(Hashes,allow_channel,AllowId),
    g31_hash_field(Hashes,denied_channel,DeniedId),
    g31_hash_field(Hashes,bot,BotId),g31_hash_field(Hashes,human_principal,HumanId).
g31_hash_field(Dict,Key,Value) :-
    get_dict(Key,Dict,Expected),g31_hash_text(Value,Actual),g31_same_text(Expected,Actual).

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
g31_hash_text(Text,Hash) :- crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]).
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
g31_id(Value,Text) :- g31_text(Value,Text),string_length(Text,26),
    re_match('^[a-z0-9]{26}$',Text).
g31_atom(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)),atom_length(Atom,N),N>0.
g31_root(Root) :-
    re_match('^/Users/claritymiter/miter/evidence/G31/p7-[0-9]{3}$',Root),
    exists_directory(Root),\+read_link(Root,_,_).
g31_materialize_error(Error,['g31-grant-materialization-failure',Text]) :-
    term_string(Error,Text,[quoted(true)]).
