% G31 fixed read-only acceptance probe for resolving a proposed live grant.
% It is not the Mattermost adapter. It cannot read posts or issue write methods.

:- module(miter_mattermost_identity_probe_v1,[g31_identity_probe/10]).

:- ensure_loaded('miter_store.pl').
:- use_module(library(crypto)).
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(process)).
:- use_module(library(readutil)).

g31_identity_probe(Root0,Candidate0,Transport0,Origin0,Team0,Allow0,
                   Denied0,Bot0,Service0,Result) :-
    catch((g31_identity_probe_checked(Root0,Candidate0,Transport0,Origin0,
                                     Team0,Allow0,Denied0,Bot0,Service0,Result0)
          -> true
          ; Result0=['g31-identity-probe-failure','contract-failed']),
          Error,g31_probe_error(Error,Result0)),
    Result=Result0,!.

g31_identity_probe_checked(Root0,Candidate0,Transport0,Origin0,Team0,Allow0,
                           Denied0,Bot0,Service0,Result) :-
    maplist(g31_atom,[Root0,Candidate0,Transport0,Origin0,Team0,Allow0,
                      Denied0,Bot0,Service0],
                     [Root,Candidate,Transport,Origin,Team,Allow,
                      Denied,Bot,Service]),
    g31_root(Root),
    Origin=='http://127.0.0.1:8065',
    Team==clarityclaw,Allow=='miter-g31-canary',
    Denied=='miter-g31-denied',Bot==miter,
    Service=='ai.bgi.miter.mattermost',
    g31_sha256(Candidate),g31_sha256(Transport),
    g31_keychain(Service,Key),
    g31_get(Key,Origin,'/api/v4/users/me',MeStatus,Me),
    MeStatus=:=200,g31_exact_named_id(Me,Bot,BotId),
    format(atom(TeamPath),'/api/v4/teams/name/~w',[Team]),
    g31_get(Key,Origin,TeamPath,TeamStatus,TeamJson),
    TeamStatus=:=200,g31_exact_named_id(TeamJson,Team,TeamId),
    format(atom(AllowPath),'/api/v4/teams/~w/channels/name/~w',[TeamId,Allow]),
    g31_get(Key,Origin,AllowPath,AllowStatus,AllowJson),
    AllowStatus=:=200,g31_exact_channel(AllowJson,Allow,TeamId,AllowId),
    g31_membership(Key,Origin,AllowId,BotId,AllowMemberStatus,AllowBotMember),
    format(atom(UsersPath),'/api/v4/users?in_channel=~w&page=0&per_page=200',[AllowId]),
    g31_get(Key,Origin,UsersPath,UsersStatus,Users),
    UsersStatus=:=200,is_list(Users),
    g31_human_candidates(Users,BotId,HumanCandidates),
    length(HumanCandidates,HumanCount),
    format(atom(DeniedPath),'/api/v4/teams/~w/channels/name/~w',[TeamId,Denied]),
    g31_get(Key,Origin,DeniedPath,DeniedStatus,DeniedJson),
    g31_optional_channel(DeniedStatus,DeniedJson,Denied,TeamId,
                         DeniedPresent,DeniedId),
    g31_optional_membership(DeniedPresent,Key,Origin,DeniedId,BotId,
                            DeniedMemberStatus,DeniedBotMember,DeniedRequests),
    g31_get(Key,Origin,'/api/v4/config/client?format=old',ConfigStatus,Config),
    g31_server_id(ConfigStatus,Config,ServerId,ServerPresent),
    Requests is 7+DeniedRequests,
    g31_hash_text(ServerId,ServerHash),g31_hash_text(TeamId,TeamHash),
    g31_hash_text(AllowId,AllowHash),g31_hash_text(DeniedId,DeniedHash),
    g31_hash_text(BotId,BotHash),
    atomic_list_concat([Root,'/identity-redacted.json'],PublicPath),
    atomic_list_concat([Root,'/identity-observation.json'],ObservationPath),
    atomic_list_concat(['/Users/claritymiter/miter/config/local/g31/',
                        'p5-identity-resolution.json'],PrivatePath),
    Private=_{schema:'miter-g31-private-identity-resolution-v1',
      server:_{url:Origin,id:ServerId},
      team:_{name:Team,id:TeamId},
      allowlisted_channel:_{name:Allow,id:AllowId,bot_member:AllowBotMember},
      denied_control_channel:_{name:Denied,id:DeniedId,present:DeniedPresent,
                               bot_member:DeniedBotMember},
      bot:_{username:Bot,id:BotId},human_candidates:HumanCandidates,
      selected_human:unresolved,
      credential_reference:_{source:'macos-keychain',account:bcb,service:Service},
      credential_value:null,candidate_hash:Candidate,transport_hash:Transport},
    Public=_{schema:'miter-g31-redacted-identity-resolution-v1',
      candidate_hash:Candidate,transport_hash:Transport,origin:Origin,
      team_slug:Team,allowlisted_channel_slug:Allow,
      denied_control_channel_slug:Denied,bot_username:Bot,
      credential_reference:'macos-keychain:bcb:ai.bgi.miter.mattermost',
      credential_value_returned:false,actual_ids_public:false,get_only:true,
      request_count:Requests,post_content_reads:0,message_writes:0,api_mutations:0,
      statuses:_{me:MeStatus,team:TeamStatus,allow_channel:AllowStatus,
                 allow_membership:AllowMemberStatus,users:UsersStatus,
                 denied_channel:DeniedStatus,denied_membership:DeniedMemberStatus,
                 client_config:ConfigStatus},
      resolved:_{server_id:ServerPresent,team:true,allow_channel:true,
                 allow_bot_member:AllowBotMember,denied_channel:DeniedPresent,
                 denied_bot_member:DeniedBotMember},
      identity_sha256:_{server:ServerHash,team:TeamHash,allow_channel:AllowHash,
                        denied_channel:DeniedHash,bot:BotHash},
      human_candidate_count:HumanCount,human_principal:unresolved,
      private_record_sha256:pending},
    g31_private_write(PrivatePath,Private,Key,PrivateHash),
    put_dict(private_record_sha256,Public,PrivateHash,PublicFinal),
    g31_public_write(PublicPath,PublicFinal,Key,PublicHash),
    EvidenceComplete=true,
    Result=['g31-identity-resolution-observation',Candidate,Transport,true,true,
      false,false,ServerPresent,true,true,AllowBotMember,DeniedPresent,
      DeniedBotMember,HumanCount,0,0,0,true,EvidenceComplete,unresolved],
    g31_public_write(ObservationPath,_{native:Result,public_sha256:PublicHash,
                                      private_sha256:PrivateHash},Key,_).

g31_get(Key,Origin,Path,Status,Json) :-
    atom_concat(Origin,Path,Url),string_concat("Bearer ",Key,Authorization),
    setup_call_cleanup(
      http_open(Url,In,[method(get),status_code(Status),timeout(15),
        redirect(false),request_header('Authorization'=Authorization),
        request_header('Accept'='application/json')]),
      json_read_dict(In,Json),close(In)).

g31_membership(Key,Origin,ChannelId,UserId,Status,Member) :-
    format(atom(Path),'/api/v4/channels/~w/members/~w',[ChannelId,UserId]),
    g31_get(Key,Origin,Path,Status,Json),
    (Status=:=200,Json.channel_id==ChannelId,Json.user_id==UserId
      -> Member=true ; Member=false).

g31_optional_membership(true,Key,Origin,ChannelId,UserId,Status,Member,1) :- !,
    g31_membership(Key,Origin,ChannelId,UserId,Status,Member).
g31_optional_membership(false,_,_,_,_,0,false,0).

g31_exact_named_id(Dict,Expected,Id) :-
    is_dict(Dict),get_dict(name,Dict,Name),g31_same_text(Name,Expected),
    get_dict(id,Dict,Id0),g31_id(Id0,Id),!.
g31_exact_named_id(Dict,Expected,Id) :-
    is_dict(Dict),get_dict(username,Dict,Username),
    g31_same_text(Username,Expected),get_dict(id,Dict,Id0),g31_id(Id0,Id).

g31_exact_channel(Dict,Expected,TeamId,Id) :-
    is_dict(Dict),get_dict(name,Dict,Name),get_dict(team_id,Dict,ChannelTeam),
    get_dict(id,Dict,Id0),g31_same_text(Name,Expected),
    g31_same_text(ChannelTeam,TeamId),g31_id(Id0,Id).

g31_optional_channel(200,Dict,Expected,TeamId,true,Id) :- !,
    g31_exact_channel(Dict,Expected,TeamId,Id).
g31_optional_channel(404,_,_,_,false,unresolved) :- !.
g31_optional_channel(_,_,_,_,false,unresolved).

g31_human_candidates(Users,BotId,Candidates) :-
    findall(_{id:Id,username:Username},
      (member(User,Users),is_dict(User),get_dict(id,User,Id0),
       get_dict(username,User,Username0),g31_id(Id0,Id),
       \+g31_same_text(Id,BotId),g31_nonempty_text(Username0,Username)),
      Candidates).

g31_server_id(200,Config,ServerId,true) :-
    is_dict(Config),get_dict('DiagnosticId',Config,Value),
    g31_nonempty_text(Value,ServerId),!.
g31_server_id(_,_,unresolved,false).

g31_keychain(Service,Key) :-
    process_create('/usr/bin/security',
      ['find-generic-password','-a',bcb,'-s',Service,'-w'],
      [stdin(null),stdout(pipe(Out)),stderr(null),process(Pid)]),
    read_string(Out,1024,Raw),close(Out),
    process_wait(Pid,exit(0),[timeout(15)]),normalize_space(string(Key),Raw),
    string_length(Key,N),N>=16,N=<512,re_match('^[A-Za-z0-9._-]+$',Key).

g31_private_write(Path,Dict,Key,Hash) :-
    file_directory_name(Path,Directory),make_directory_path(Directory),
    chmod(Directory,0o700),g31_write_json(Path,Dict,0o600,Key,Hash).
g31_public_write(Path,Dict,Key,Hash) :- g31_write_json(Path,Dict,0o644,Key,Hash).

g31_write_json(Path,Dict,Mode,Key,Hash) :-
    \+exists_file(Path),with_output_to(string(Rendered),
      (json_write_dict(current_output,Dict,[width(0)]),nl)),
    \+sub_string(Rendered,_,_,_,Key),
    file_directory_name(Path,Directory),make_directory_path(Directory),
    atom_concat(Path,'.tmp',Temporary),\+exists_file(Temporary),
    setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
      (chmod(Temporary,Mode),write(Stream,Rendered),flush_output(Stream),
       miter_store_ensure_extension(
        '/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
       miter_store_fsync_stream(Stream)),close(Stream)),
    rename_file(Temporary,Path),
    crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]).

g31_hash_text(unresolved,unresolved) :- !.
g31_hash_text(Value,Hash) :- g31_nonempty_text(Value,Text),
    crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]).
g31_sha256(Value) :- atom(Value),atom_length(Value,64),
    re_match('^[a-f0-9]{64}$',Value).
g31_id(Value,Text) :- g31_nonempty_text(Value,Text),
    string_length(Text,26),re_match('^[a-z0-9]{26}$',Text).
g31_nonempty_text(Value,Text) :-
    (string(Value)->Text=Value;atom(Value)->atom_string(Value,Text)),
    string_length(Text,N),N>0,N=<512.
g31_same_text(A,B) :- g31_nonempty_text(A,AT),g31_nonempty_text(B,BT),AT==BT.
g31_atom(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)),
    atom_length(Atom,N),N>0.
g31_root(Root) :-
    re_match('^/Users/claritymiter/miter/evidence/G31/p5-[0-9]{3}$',Root),
    exists_directory(Root),\+read_link(Root,_,_).
g31_probe_error(Error,['g31-identity-probe-failure',Text]) :-
    term_string(Error,Text,[quoted(true)]).
