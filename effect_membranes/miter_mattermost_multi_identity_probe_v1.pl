% AMA-1.2 R2 read-only stable identity probe.
% It resolves one exact Berton/Haley/Miter group without reading post content.

:- module(miter_mattermost_multi_identity_probe_v1,
          [ama12_identity_probe/8,ama12_group_visibility/4]).

:- ensure_loaded('miter_store.pl').
:- use_module(library(crypto)).
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(process)).
:- use_module(library(readutil)).

ama12_identity_probe(Root0,Candidate0,Transport0,Origin0,Team0,
                     Denied0,Service0,Result) :-
    catch((ama12_identity_probe_checked(Root0,Candidate0,Transport0,Origin0,
                                        Team0,Denied0,Service0,Result0)
          -> true
          ; Result0=['ama12-identity-probe-failure','contract-failed']),
          Error,ama12_probe_error(Error,Result0)),
    Result=Result0,!.

% A redacted preliminary diagnostic. It reports only statuses and counts so an
% absent or duplicate group can close as typed evidence without exposing IDs.
ama12_group_visibility(Origin0,Team0,Service0,Result) :-
    maplist(ama12_atom,[Origin0,Team0,Service0],[Origin,Team,Service]),
    Origin=='http://127.0.0.1:8065',Team==clarityclaw,
    Service=='ai.bgi.miter.mattermost',
    ama12_keychain(Service,Key),
    ama12_get(Key,Origin,'/api/v4/users/me',MeStatus,Me),
    MeStatus=:=200,ama12_exact_username(Me,miter,BotId),
    ama12_user(Key,Origin,berton_c,BertonStatus,BertonId),
    ama12_user(Key,Origin,haley,HaleyStatus,HaleyId),
    format(atom(TeamPath),'/api/v4/teams/name/~w',[Team]),
    ama12_get(Key,Origin,TeamPath,TeamStatus,TeamJson),
    TeamStatus=:=200,ama12_exact_name(TeamJson,Team,TeamId),
    ama12_channel_listing(Key,Origin,BotId,TeamId,ChannelsStatus,Channels,
                          ListingRequests),
    ChannelsStatus=:=200,is_list(Channels),ama12_group_ids(Channels,GroupIds),
    length(Channels,ChannelCount),length(GroupIds,VisibleGroupCount),
    sort([BotId,BertonId,HaleyId],ExpectedMembers),
    ama12_group_matches(GroupIds,ExpectedMembers,Key,Origin,Matches,GroupRequests),
    length(Matches,ExactGroupCount),Requests is 4+ListingRequests+GroupRequests,
    Result=_{schema:'miter-ama12-redacted-group-visibility-v1',
      statuses:_{me:MeStatus,berton:BertonStatus,haley:HaleyStatus,
                 team:TeamStatus,channels:ChannelsStatus},
      visible_channel_count:ChannelCount,visible_group_count:VisibleGroupCount,
      exact_berton_haley_miter_group_count:ExactGroupCount,
      request_count:Requests,credential_lookups:1,credential_values_returned:false,
      post_content_reads:0,message_reads:0,message_writes:0,api_mutations:0}.

ama12_identity_probe_checked(Root0,Candidate0,Transport0,Origin0,Team0,
                             Denied0,Service0,Result) :-
    maplist(ama12_atom,[Root0,Candidate0,Transport0,Origin0,Team0,Denied0,Service0],
                      [Root,Candidate,Transport,Origin,Team,Denied,Service]),
    ama12_root(Root),
    Origin=='http://127.0.0.1:8065',Team==clarityclaw,
    Denied=='miter-g31-denied',Service=='ai.bgi.miter.mattermost',
    ama12_sha256(Candidate),ama12_sha256(Transport),
    ama12_keychain(Service,Key),
    ama12_get(Key,Origin,'/api/v4/users/me',MeStatus,Me),
    MeStatus=:=200,ama12_exact_username(Me,miter,BotId),
    ama12_user(Key,Origin,berton_c,BertonStatus,BertonId),BertonStatus=:=200,
    ama12_user(Key,Origin,haley,HaleyStatus,HaleyId),HaleyStatus=:=200,
    format(atom(TeamPath),'/api/v4/teams/name/~w',[Team]),
    ama12_get(Key,Origin,TeamPath,TeamStatus,TeamJson),
    TeamStatus=:=200,ama12_exact_name(TeamJson,Team,TeamId),
    ama12_channel_listing(Key,Origin,BotId,TeamId,ChannelsStatus,Channels,
                          ListingRequests),
    ChannelsStatus=:=200,is_list(Channels),
    ama12_group_ids(Channels,GroupIds),
    sort([BotId,BertonId,HaleyId],ExpectedMembers),
    ama12_group_matches(GroupIds,ExpectedMembers,Key,Origin,Matches,GroupRequests),
    Matches=[GroupId],length(Matches,1),
    format(atom(DeniedPath),'/api/v4/teams/~w/channels/name/~w',[TeamId,Denied]),
    ama12_get(Key,Origin,DeniedPath,DeniedStatus,DeniedJson),
    DeniedStatus=:=200,ama12_exact_channel(DeniedJson,Denied,TeamId,DeniedId),
    ama12_get(Key,Origin,'/api/v4/config/client?format=old',ConfigStatus,Config),
    ama12_server_id(ConfigStatus,Config,ServerId),
    Requests is 7+ListingRequests+GroupRequests,
    maplist(ama12_hash_text,
      [ServerId,TeamId,GroupId,DeniedId,BotId,BertonId,HaleyId],
      [ServerHash,TeamHash,GroupHash,DeniedHash,BotHash,BertonHash,HaleyHash]),
    atomic_list_concat(['/Users/claritymiter/miter/config/local/ama1_2/',
                        'multi-principal-binding-v1.json'],PrivatePath),
    atomic_list_concat([Root,'/identity-redacted.json'],PublicPath),
    atomic_list_concat([Root,'/identity-observation.json'],ObservationPath),
    Private=_{schema:'miter-ama12-private-multi-principal-binding-v1',
      server:_{url:Origin,id:ServerId},team:_{slug:Team,id:TeamId},
      carrier:_{kind:'mattermost-group',id:GroupId,
                exact_members:[BertonId,HaleyId,BotId]},
      denied_control:_{slug:Denied,id:DeniedId},
      principals:_{berton:_{username:berton_c,id:BertonId},
                   haley:_{username:haley,id:HaleyId},
                   bot:_{username:miter,id:BotId}},
      project:_{id:'miter-evaluation-v1',audience:'berton-haley-shared-local'},
      disclosure:_{berton:'affirmed-by-ratification',haley:unresolved},
      credential_reference:_{source:'macos-keychain',account:bcb,service:Service},
      credential_value:null,candidate_hash:Candidate,transport_hash:Transport,
      payload_cognition:held,memory_admission:held,model_use:held,egress:held},
    Public0=_{schema:'miter-ama12-redacted-multi-principal-binding-v1',
      candidate_hash:Candidate,transport_hash:Transport,origin:Origin,
      team_slug:Team,carrier_kind:'mattermost-group',
      expected_principals:[berton_c,haley,miter],
      denied_control_slug:Denied,
      credential_reference:'macos-keychain:bcb:ai.bgi.miter.mattermost',
      credential_value_returned:false,actual_ids_public:false,get_only:true,
      request_count:Requests,post_content_reads:0,message_writes:0,api_mutations:0,
      statuses:_{me:MeStatus,berton:BertonStatus,haley:HaleyStatus,
                 team:TeamStatus,channel_listing:ChannelsStatus,
                 denied_control:DeniedStatus,client_config:ConfigStatus},
      resolved:_{server:true,team:true,group:true,exact_three_members:true,
                 bot:true,berton:true,haley:true,denied_control:true,
                 unique_group_count:1},
      identity_sha256:_{server:ServerHash,team:TeamHash,group:GroupHash,
        denied_control:DeniedHash,bot:BotHash,berton:BertonHash,haley:HaleyHash},
      consent:_{berton:affirmed,haley:unresolved},
      payload_cognition:held,memory_admission:held,model_use:held,egress:held,
      private_record_sha256:pending},
    ama12_private_write(PrivatePath,Private,Key,PrivateHash),
    put_dict(private_record_sha256,Public0,PrivateHash,Public),
    ama12_public_write(PublicPath,Public,Key,PublicHash),
    Result=['ama12-identity-observation',Candidate,Transport,
      'server-resolved','team-resolved','group-resolved','exact-three-members',
      'bot-resolved','berton-resolved','haley-resolved','denied-control-resolved',
      'unique-group-count',1,'post-content-reads',0,'message-writes',0,
      'api-mutations',0],
    ama12_public_write(ObservationPath,
      _{native:Result,public_sha256:PublicHash,private_sha256:PrivateHash},Key,_).

ama12_user(Key,Origin,Username,Status,Id) :-
    format(atom(Path),'/api/v4/users/username/~w',[Username]),
    ama12_get(Key,Origin,Path,Status,Json),
    (Status=:=200 -> ama12_exact_username(Json,Username,Id) ; Id=unresolved).

ama12_channel_listing(Key,Origin,UserId,TeamId,Status,Channels,Requests) :-
    format(atom(Path),'/api/v4/users/~w/channels',[UserId]),
    ama12_get(Key,Origin,Path,Status0,Channels0),
    (Status0=:=200,is_list(Channels0)
      -> Status=Status0,Channels=Channels0,Requests=1
      ; format(atom(Fallback),'/api/v4/users/~w/teams/~w/channels',[UserId,TeamId]),
        ama12_get(Key,Origin,Fallback,Status,Channels),Requests=2).

ama12_group_ids(Channels,Ids) :-
    findall(Id,(member(Channel,Channels),is_dict(Channel),
      get_dict(type,Channel,Type),ama12_same_text(Type,"G"),
      get_dict(id,Channel,Id0),ama12_id(Id0,Id)),Ids).

ama12_group_matches([],_,_,_,[],0).
ama12_group_matches([Id|Ids],Expected,Key,Origin,Matches,Requests) :-
    format(atom(Path),'/api/v4/channels/~w/members',[Id]),
    ama12_get(Key,Origin,Path,Status,Json),
    ama12_group_matches(Ids,Expected,Key,Origin,Tail,TailRequests),
    Requests is TailRequests+1,
    (Status=:=200,is_list(Json),ama12_member_ids(Json,Members),Members==Expected
      -> Matches=[Id|Tail] ; Matches=Tail).

ama12_member_ids(Members,Ids) :-
    findall(Id,(member(Member,Members),is_dict(Member),
      get_dict(user_id,Member,Id0),ama12_id(Id0,Id)),Raw),sort(Raw,Ids).

ama12_get(Key,Origin,Path,Status,Json) :-
    atom_concat(Origin,Path,Url),string_concat("Bearer ",Key,Authorization),
    setup_call_cleanup(
      http_open(Url,In,[method(get),status_code(Status),timeout(15),
        redirect(false),request_header('Authorization'=Authorization),
        request_header('Accept'='application/json')]),
      json_read_dict(In,Json),close(In)).

ama12_exact_username(Dict,Expected,Id) :-
    is_dict(Dict),get_dict(username,Dict,Name),ama12_same_text(Name,Expected),
    get_dict(id,Dict,Id0),ama12_id(Id0,Id).
ama12_exact_name(Dict,Expected,Id) :-
    is_dict(Dict),get_dict(name,Dict,Name),ama12_same_text(Name,Expected),
    get_dict(id,Dict,Id0),ama12_id(Id0,Id).
ama12_exact_channel(Dict,Expected,TeamId,Id) :-
    is_dict(Dict),get_dict(name,Dict,Name),get_dict(team_id,Dict,ChannelTeam),
    ama12_same_text(Name,Expected),ama12_same_text(ChannelTeam,TeamId),
    get_dict(id,Dict,Id0),ama12_id(Id0,Id).
ama12_server_id(200,Config,ServerId) :-
    is_dict(Config),get_dict('DiagnosticId',Config,Value),
    ama12_nonempty_text(Value,ServerId).

ama12_keychain(Service,Key) :-
    process_create('/usr/bin/security',
      ['find-generic-password','-a',bcb,'-s',Service,'-w'],
      [stdin(null),stdout(pipe(Out)),stderr(null),process(Pid)]),
    read_string(Out,1024,Raw),close(Out),
    process_wait(Pid,exit(0),[timeout(15)]),normalize_space(string(Key),Raw),
    string_length(Key,N),N>=16,N=<512,re_match('^[A-Za-z0-9._-]+$',Key).

ama12_private_write(Path,Dict,Key,Hash) :-
    file_directory_name(Path,Directory),make_directory_path(Directory),
    chmod(Directory,0o700),ama12_write_json(Path,Dict,0o600,Key,Hash).
ama12_public_write(Path,Dict,Key,Hash) :-
    ama12_write_json(Path,Dict,0o644,Key,Hash).

ama12_write_json(Path,Dict,Mode,Key,Hash) :-
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

ama12_hash_text(Value,Hash) :- ama12_nonempty_text(Value,Text),
    crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]).
ama12_sha256(Value) :- atom(Value),atom_length(Value,64),
    re_match('^[a-f0-9]{64}$',Value).
ama12_id(Value,Text) :- ama12_nonempty_text(Value,Text),
    string_length(Text,26),re_match('^[a-z0-9]{26}$',Text).
ama12_nonempty_text(Value,Text) :-
    (string(Value)->Text=Value;atom(Value)->atom_string(Value,Text)),
    string_length(Text,N),N>0,N=<512.
ama12_same_text(A,B) :-
    ama12_nonempty_text(A,AT),ama12_nonempty_text(B,BT),AT==BT.
ama12_atom(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)),
    atom_length(Atom,N),N>0.
ama12_root(Root) :-
    re_match('^/Users/claritymiter/miter/evidence/AMA-1\\.2/R2/identity-[0-9]{3}$',Root),
    exists_directory(Root),\+read_link(Root,_,_).
ama12_probe_error(Error,['ama12-identity-probe-failure',Text]) :-
    term_string(Error,Text,[quoted(true)]).
