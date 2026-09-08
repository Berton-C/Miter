% Local Mattermost carrier for the one continuously cycling Miter runtime.
%
% The existing PeTTa reactor calls as_mattermost_poll/2 from its ordinary input
% read.  This module has no timer, worker, cognition, or response policy.  It
% resolves stable identities, admits new bounded bytes, persists exact source
% material, and later carries only separately certified effects.

:- use_module(library(crypto)).
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pcre)).
:- use_module(library(process)).
:- use_module(library(readutil)).

as_mattermost_prepare(Root0, Standing) :-
    catch((as_mattermost_root(Root0, Root),
           as_mattermost_config(Root, Config),
           ( Config.enabled == true ->
               as_mattermost_resolve_live(Root, Config, _), Standing=ready
           ; Standing=disabled )), _, Standing=held), !.

as_mattermost_poll(Root0, Inputs) :-
    catch((as_mattermost_root(Root0, Root),
           as_mattermost_config(Root, Config),
           ( Config.enabled == true,
             as_mattermost_due(Root, Config.inbound.poll_seconds) ->
               as_mattermost_binding_local(Root, Config, Binding),
               ( as_evaluation_group_active(Root,Config,Binding,_) ->
                   as_mattermost_poll_ready(Root, Config, Binding, Inputs0),
                   Inputs=Inputs0
               ; Inputs=[] )
           ; Inputs=[] )), _, Inputs=[]), !.

as_mattermost_root(Root0, Root) :-
    miter_store_nonempty_atom(Root0, Root), is_absolute_file_name(Root),
    exists_directory(Root).

as_mattermost_config(Root, Config) :-
    directory_file_path(Root, 'mattermost.json', Path),
    miter_store_read_json(Path, Config), is_dict(Config),
    as_mattermost_exact_keys(Config,
      [authorized_humans,bot_username,credential_reference,enabled,
       human_editable,inbound,operator_notes,origin,origin_policy,outbound,
       required_group_members,schema,scope,team_slug]),
    Config.schema == "miter-mattermost-surface-v1",
    Config.human_editable == true,
    memberchk(Config.enabled,[true,false]),
    Config.origin_policy == "loopback-only",
    as_mattermost_loopback_origin(Config.origin),
    as_mattermost_name(Config.team_slug),
    as_mattermost_name(Config.bot_username),
    maplist(as_mattermost_name,Config.authorized_humans),
    sort(Config.authorized_humans,Authorized), Authorized=Config.authorized_humans,
    Authorized=[_,_],
    maplist(as_mattermost_name,Config.required_group_members),
    sort(Config.required_group_members,Required), Required=Config.required_group_members,
    Required=[_,_,_], memberchk(Config.bot_username,Required),
    forall(member(Human,Authorized),memberchk(Human,Required)),
    as_mattermost_name(Config.scope.audience),
    as_mattermost_name(Config.scope.project),
    as_mattermost_exact_keys(Config.scope,[audience,project]),
    as_mattermost_exact_keys(Config.credential_reference,[account,service,source]),
    as_mattermost_exact_keys(Config.inbound,
      [bot_posts_are_contact,history_backfill,max_event_bytes,new_events_only,
       poll_seconds]),
    as_mattermost_exact_keys(Config.outbound,
      [certificate,destination,enabled,unknown_outcome]),
    Config.credential_reference.source == "macos-keychain",
    as_mattermost_name(Config.credential_reference.account),
    as_mattermost_name(Config.credential_reference.service),
    Config.inbound.new_events_only == true,
    Config.inbound.history_backfill == false,
    Config.inbound.bot_posts_are_contact == false,
    integer(Config.inbound.max_event_bytes),
    Config.inbound.max_event_bytes >= 1024,
    Config.inbound.max_event_bytes =< 1048576,
    number(Config.inbound.poll_seconds),
    Config.inbound.poll_seconds >= 0.25,
    Config.inbound.poll_seconds =< 60,
    memberchk(Config.outbound.enabled,[true,false]),
    Config.outbound.certificate == "VoiceRNA-required",
    Config.outbound.destination == "resolved-exact-group-only",
    Config.outbound.unknown_outcome == "hold-and-reconcile-never-blind-resend",
    is_list(Config.operator_notes),
    maplist(string,Config.operator_notes),
    as_mattermost_secret_free(Config).

as_mattermost_secret_free(Dict) :-
    is_dict(Dict), !, dict_pairs(Dict,_,Pairs),
    forall(member(Key-Value,Pairs),
      ( \+ memberchk(Key,[api_key,authorization,password,secret,token]),
        as_mattermost_secret_free(Value) )).
as_mattermost_secret_free(List) :-
    is_list(List), !, maplist(as_mattermost_secret_free,List).
as_mattermost_secret_free(_).

as_mattermost_loopback_origin(Value) :-
    miter_store_nonempty_atom(Value, Origin),
    re_match('^http://(127\\.0\\.0\\.1|localhost)(:[0-9]{1,5})?$',Origin).

as_mattermost_name(Value) :-
    miter_store_nonempty_atom(Value, Atom),
    re_match('^[A-Za-z][A-Za-z0-9_.:-]{0,127}$',Atom).

as_mattermost_exact_keys(Dict, Expected) :-
    dict_keys(Dict, Keys), sort(Keys, Sorted), sort(Expected, Sorted).

as_mattermost_resolve_live(Root, Config, Binding) :-
    directory_file_path(Root, 'surface/mattermost-binding.json', Path),
    ( exists_file(Path), miter_store_read_json(Path, Candidate),
      as_mattermost_binding_live(Config,Candidate) -> Binding=Candidate
    ; as_mattermost_resolve_fresh(Config, Fresh),
      as_write_json_durable(Path,Fresh), Binding=Fresh ),
    as_mattermost_cursor_initialize(Root).

as_mattermost_binding_local(Root,Config,Binding) :-
    directory_file_path(Root,'surface/mattermost-binding.json',Path),
    miter_store_read_json(Path,Binding),
    as_mattermost_binding_matches_config(Config,Binding).

as_mattermost_binding_matches_config(Config,Binding) :-
    is_dict(Binding), Binding.schema=="miter-mattermost-private-binding-v1",
    Binding.origin==Config.origin, Binding.team_slug==Config.team_slug,
    Binding.channel_type=="G", Binding.audience==Config.scope.audience,
    Binding.project==Config.scope.project,
    Binding.required_group_members==Config.required_group_members,
    as_mattermost_id(Binding.team_id,_),
    as_mattermost_id(Binding.channel_id,_), as_mattermost_id(Binding.bot_id,_),
    is_list(Binding.principals), length(Binding.principals,3).

as_mattermost_resolve_fresh(Config, Binding) :-
    as_mattermost_token(Config, Token),
    as_mattermost_get(Config,Token,'/api/v4/users/me',Me,200),
    as_mattermost_id(Me.id,BotId),
    Me.username == Config.bot_username,
    miter_store_nonempty_atom(Config.team_slug,TeamSlug),
    format(atom(TeamPath),'/api/v4/teams/name/~w',[TeamSlug]),
    as_mattermost_get(Config,Token,TeamPath,Team,200),
    as_mattermost_id(Team.id,TeamId),
    maplist(as_mattermost_resolve_user(Config,Token),
      Config.required_group_members,PrincipalRows),
    member(BotRow,PrincipalRows), BotRow.username==Config.bot_username,
    BotRow.id==BotId,
    as_mattermost_group_channel(Config,Token,BotId,TeamId,PrincipalRows,Channel),
    get_time(Now),
    Binding=_{schema:"miter-mattermost-private-binding-v1",
      origin:Config.origin,team_slug:Config.team_slug,team_id:TeamId,
      channel_id:Channel.id,channel_type:"G",bot_id:BotId,
      principals:PrincipalRows,required_group_members:Config.required_group_members,
      audience:Config.scope.audience,project:Config.scope.project,
      resolved_at_epoch:Now,standing:"stable-ids-resolved-exact-group"}.

as_mattermost_resolve_user(Config,Token,Username,Row) :-
    miter_store_nonempty_atom(Username,UsernameAtom),
    format(atom(Path),'/api/v4/users/username/~w',[UsernameAtom]),
    as_mattermost_get(Config,Token,Path,User,200),
    as_mattermost_id(User.id,Id), User.username==Username,
    Row=_{username:Username,id:Id}.

as_mattermost_group_channel(Config,Token,BotId,TeamId,Principals,Channel) :-
    miter_store_nonempty_atom(BotId,BotIdAtom),
    miter_store_nonempty_atom(TeamId,TeamIdAtom),
    format(atom(Path),'/api/v4/users/~w/teams/~w/channels',[BotIdAtom,TeamIdAtom]),
    as_mattermost_get(Config,Token,Path,Channels,200), is_list(Channels),
    findall(C,(member(C,Channels),is_dict(C),C.type=="G",
      as_mattermost_channel_exact_members(Config,Token,C.id,Principals)),Matches),
    Matches=[Channel].

as_mattermost_channel_exact_members(Config,Token,ChannelId,Principals) :-
    miter_store_nonempty_atom(ChannelId,ChannelIdAtom),
    format(atom(Path),'/api/v4/channels/~w/members',[ChannelIdAtom]),
    as_mattermost_get(Config,Token,Path,Members,200), is_list(Members),
    findall(Id,(member(M,Members),as_mattermost_id(M.user_id,Id)),MemberIds0),
    sort(MemberIds0,MemberIds),
    findall(Id,(member(P,Principals),as_mattermost_id(P.id,Id)),RequiredIds0),
    sort(RequiredIds0,RequiredIds), MemberIds==RequiredIds.

as_mattermost_binding_live(Config, Binding) :-
    as_mattermost_binding_matches_config(Config,Binding),
    as_mattermost_token(Config,Token),
    as_mattermost_get(Config,Token,'/api/v4/users/me',Me,200),
    as_mattermost_id(Me.id,MeId), as_mattermost_id(Binding.bot_id,BindingBotId),
    MeId==BindingBotId, Me.username==Config.bot_username,
    as_mattermost_channel_exact_members(Config,Token,Binding.channel_id,
      Binding.principals).

as_mattermost_token(Config, Token) :-
    atom_string(Account,Config.credential_reference.account),
    atom_string(Service,Config.credential_reference.service),
    setup_call_cleanup(
      process_create('/usr/bin/security',
        ['find-generic-password','-w','-a',Account,'-s',Service],
        [stdin(null),stdout(pipe(Stream)),stderr(null),process(Pid)]),
      read_string(Stream,65536,Raw),
      close(Stream)),
    process_wait(Pid,exit(0)), normalize_space(string(Token),Raw),
    string_length(Token,Length), Length>=16, Length=<8192.

as_mattermost_auth(Token, Header) :- format(string(Header),'Bearer ~s',[Token]).

as_mattermost_get(Config,Token,Path,Reply,Expected) :-
    miter_store_nonempty_atom(Config.origin,Origin), atom_concat(Origin,Path,Url),
    as_mattermost_auth(Token,Authorization),
    setup_call_cleanup(http_open(Url,Stream,
      [request_header('Authorization'=Authorization),status_code(Status),
       timeout(10),encoding(utf8)]),json_read_dict(Stream,Reply),close(Stream)),
    Status==Expected.

% Commit one already-certified response to the exact resolved group.  The
% effect state is durable before transmission.  A transmission whose outcome
% cannot be proven is reconciled against the remote group and is never blindly
% repeated.  No language interpretation or movement selection occurs here.
as_mattermost_commit_post(Root0, EffectId0, Scope, ReplyContact0, Utterance,
    CertificateHash0, ProofHash0, Result) :-
    catch(as_mattermost_commit_post_checked(Root0,EffectId0,Scope,
      ReplyContact0,Utterance,CertificateHash0,ProofHash0,Result0),_,
      Result0=['mattermost-effect-held',EffectId0,'mechanical-boundary']),
    Result=Result0, !.

as_mattermost_commit_post_checked(Root0, EffectId0, _Scope, _ReplyContact0,
    _Utterance, _CertificateHash0, _ProofHash0,
    ['mattermost-effect-held',EffectId,'outbound-disabled']) :-
    as_mattermost_root(Root0,Root), as_symbol(EffectId0,EffectId),
    as_mattermost_config(Root,Config),
    ( Config.enabled \== true ; Config.outbound.enabled \== true ), !.
as_mattermost_commit_post_checked(Root0, EffectId0, _Scope, _ReplyContact0,
    _Utterance, _CertificateHash0, _ProofHash0,
    ['mattermost-effect-held',EffectId,'evaluation-grant-inactive']) :-
    as_mattermost_root(Root0,Root), as_symbol(EffectId0,EffectId),
    as_mattermost_config(Root,Config),
    as_mattermost_binding_local(Root,Config,Binding),
    \+ as_evaluation_effect_available(Root,Config,Binding,EffectId,_), !.
as_mattermost_commit_post_checked(Root0, EffectId0, Scope, ReplyContact0,
    Utterance, CertificateHash0, ProofHash0, Result) :-
    as_mattermost_root(Root0,Root), as_symbol(EffectId0,EffectId),
    as_symbol(ReplyContact0,ReplyContact),
    atom_concat(mm_,SourcePostId,ReplyContact),
    as_mattermost_id(SourcePostId,_),
    string(Utterance), string_length(Utterance,UtteranceLength),
    UtteranceLength>=1, UtteranceLength=<3000,
    as_sha256(CertificateHash0,CertificateHash),
    as_sha256(ProofHash0,ProofHash),
    as_mattermost_effect_context(Root,Scope,SourcePostId,EffectId,Config,Binding,
      Token,ChannelId,BotId,RootPostId,GrantId),
    crypto_data_hash(Utterance,MessageHash,
      [algorithm(sha256),encoding(utf8)]),
    as_mattermost_effect_path(Root,EffectId,Path),
    ( exists_file(Path) ->
        miter_store_read_json(Path,State),
        as_mattermost_effect_state_matches(State,EffectId,Scope,SourcePostId,
          ChannelId,BotId,RootPostId,Utterance,MessageHash,CertificateHash,
          ProofHash,GrantId),
        as_mattermost_resume_effect(Path,State,Config,Binding,Token,Result)
    ; as_mattermost_prepare_effect(Path,EffectId,Scope,SourcePostId,ChannelId,
        BotId,RootPostId,Utterance,MessageHash,CertificateHash,ProofHash,GrantId,
        State),
      as_mattermost_transmit_effect(Path,State,Config,Binding,Token,Result)
    ).

as_mattermost_effect_context(Root,Scope,SourcePostId,EffectId,Config,Binding,Token,
    ChannelId,BotId,RootPostId,GrantId) :-
    as_mattermost_config(Root,Config), Config.enabled==true,
    Config.outbound.enabled==true,
    as_mattermost_binding_local(Root,Config,Binding),
    as_mattermost_binding_live(Config,Binding),
    as_evaluation_effect_available(Root,Config,Binding,EffectId,GrantId),
    as_mattermost_token(Config,Token),
    as_mattermost_id(Binding.channel_id,ChannelId),
    as_mattermost_id(Binding.bot_id,BotId),
    format(atom(SourcePath),'/api/v4/posts/~w',[SourcePostId]),
    as_mattermost_get(Config,Token,SourcePath,Post,200),
    as_mattermost_source_post_valid(Config,Binding,Scope,SourcePostId,Post,
      ChannelId,RootPostId).

as_mattermost_source_post_valid(Config,Binding,
    [scope,Principal0,Audience0,Project0],SourcePostId,Post,ChannelId,
    RootPostId) :-
    is_dict(Post), as_mattermost_id(Post.id,SourcePostId),
    as_mattermost_id(Post.channel_id,ChannelId),
    as_mattermost_id(Post.user_id,UserId),
    member(Principal,Binding.principals),
    as_mattermost_id(Principal.id,UserId),
    memberchk(Principal.username,Config.authorized_humans),
    miter_store_nonempty_atom(Principal.username,PrincipalName),
    miter_store_nonempty_atom(Config.scope.audience,Audience),
    miter_store_nonempty_atom(Config.scope.project,Project),
    miter_store_nonempty_atom(Principal0,PrincipalName),
    miter_store_nonempty_atom(Audience0,Audience),
    miter_store_nonempty_atom(Project0,Project),
    ( Post.root_id=="" -> RootPostId=SourcePostId
    ; as_mattermost_id(Post.root_id,RootPostId) ).

as_mattermost_effect_path(Root,EffectId,Path) :-
    format(atom(Relative),'surface/effects/~w.json',[EffectId]),
    directory_file_path(Root,Relative,Path).

as_mattermost_prepare_effect(Path,EffectId,Scope,SourcePostId,ChannelId,BotId,
    RootPostId,Utterance,MessageHash,CertificateHash,ProofHash,GrantId,State) :-
    get_time(Now),
    term_string(Scope,ScopeText,[quoted(true),ignore_ops(true)]),
    State=_{schema:"miter-mattermost-effect-v1",effect_id:EffectId,
      idempotency_key:EffectId,scope:ScopeText,source_post_id:SourcePostId,
      channel_id:ChannelId,bot_id:BotId,root_post_id:RootPostId,
      message:Utterance,message_sha256:MessageHash,
      certificate_sha256:CertificateHash,native_proof_sha256:ProofHash,
      grant_id:GrantId,
      pending_post_id:EffectId,response_post_id:"",prepared_at_epoch:Now,
      transmission_started_at_epoch:0,observed_at_epoch:Now,
      standing:"prepared-before-transmission"},
    as_write_json_durable(Path,State).

as_mattermost_effect_state_matches(State,EffectId,Scope,SourcePostId,ChannelId,
    BotId,RootPostId,Utterance,MessageHash,CertificateHash,ProofHash,GrantId) :-
    is_dict(State), State.schema=="miter-mattermost-effect-v1",
    miter_store_nonempty_atom(State.effect_id,EffectId),
    miter_store_nonempty_atom(State.idempotency_key,EffectId),
    term_string(Scope,ScopeText,[quoted(true),ignore_ops(true)]),
    State.scope==ScopeText,
    as_mattermost_id(State.source_post_id,SourcePostId),
    as_mattermost_id(State.channel_id,ChannelId),
    as_mattermost_id(State.bot_id,BotId),
    as_mattermost_id(State.root_post_id,RootPostId),
    State.message==Utterance,
    as_sha256(State.message_sha256,MessageHash),
    as_sha256(State.certificate_sha256,CertificateHash),
    as_sha256(State.native_proof_sha256,ProofHash),
    miter_store_nonempty_atom(State.grant_id,GrantId),
    miter_store_nonempty_atom(State.pending_post_id,EffectId),
    number(State.prepared_at_epoch), State.prepared_at_epoch>0,
    number(State.transmission_started_at_epoch),
    number(State.observed_at_epoch), string(State.standing).

as_mattermost_resume_effect(_Path,State,Config,_Binding,Token,Result) :-
    State.standing=="delivered-and-verified", !,
    as_mattermost_verify_stored_delivery(Config,Token,State),
    as_mattermost_effect_result(State,'mattermost-effect-duplicate',Result).
as_mattermost_resume_effect(Path,State,Config,Binding,Token,Result) :-
    memberchk(State.standing,
      ["transmission-started-outcome-unknown","outcome-unknown-held"]), !,
    as_mattermost_reconcile_effect(Path,State,Config,Binding,Token,Result).
as_mattermost_resume_effect(Path,State,Config,Binding,Token,Result) :-
    memberchk(State.standing,
      ["prepared-before-transmission","confirmed-not-delivered"]), !,
    as_mattermost_transmit_effect(Path,State,Config,Binding,Token,Result).
as_mattermost_resume_effect(_Path,State,_Config,_Binding,_Token,
    ['mattermost-effect-held',State.effect_id,'unrecognized-effect-standing']).

as_mattermost_transmit_effect(Path,State,Config,Binding,Token,Result) :-
    get_time(Now),
    put_dict(_{standing:"transmission-started-outcome-unknown",
      transmission_started_at_epoch:Now,observed_at_epoch:Now},State,Started),
    as_write_json_durable(Path,Started),
    as_mattermost_post_outcome(Config,Token,Started,Outcome),
    as_mattermost_finish_transmission(Path,Started,Config,Binding,Token,Outcome,
      Result).

as_mattermost_post_outcome(Config,Token,State,Outcome) :-
    Body=_{channel_id:State.channel_id,root_id:State.root_post_id,
      message:State.message,pending_post_id:State.pending_post_id},
    catch(as_mattermost_post_json(Config,Token,'/api/v4/posts',Body,Status,Reply),
      _, Outcome=unknown),
    ( var(Outcome) -> Outcome=['http-result',Status,Reply] ; true ).

as_mattermost_post_json(Config,Token,Path,Body,Status,Reply) :-
    miter_store_nonempty_atom(Config.origin,Origin), atom_concat(Origin,Path,Url),
    as_mattermost_auth(Token,Authorization),
    setup_call_cleanup(http_open(Url,Stream,
      [method(post),post(json(Body)),status_code(Status),timeout(20),
       redirect(false),encoding(utf8),
       request_header('Authorization'=Authorization),
       request_header('Content-Type'='application/json'),
       request_header('Accept'='application/json')]),
      read_string(Stream,262145,Raw),close(Stream)),
    string_length(Raw,Length), Length=<262144,
    catch(atom_json_dict(Raw,Reply,[]),_,Reply=_{raw:"unparseable"}).

as_mattermost_finish_transmission(Path,State,Config,_Binding,Token,
    ['http-result',201,Reply],Result) :-
    as_mattermost_delivered_post_valid(State,Reply), !,
    as_mattermost_mark_delivered(Path,State,Reply.id,Delivered),
    as_mattermost_verify_stored_delivery(Config,Token,Delivered),
    as_mattermost_effect_receipt(Path,Delivered,delivered),
    as_mattermost_effect_result(State,'mattermost-effect-delivered',Result).
as_mattermost_finish_transmission(Path,State,_Config,_Binding,_Token,
    ['http-result',Status,_],
    ['mattermost-effect-held',State.effect_id,'remote-rejected-no-delivery']) :-
    integer(Status), Status=\=201, !,
    get_time(Now), put_dict(_{standing:"confirmed-not-delivered",
      observed_at_epoch:Now},State,Held), as_write_json_durable(Path,Held).
as_mattermost_finish_transmission(Path,State,Config,Binding,Token,_Outcome,
    Result) :-
    get_time(Now), put_dict(_{standing:"outcome-unknown-held",
      observed_at_epoch:Now},State,Unknown), as_write_json_durable(Path,Unknown),
    as_mattermost_reconcile_effect(Path,Unknown,Config,Binding,Token,Result).

as_mattermost_mark_delivered(Path,State,ResponsePostId0,Delivered) :-
    as_mattermost_id(ResponsePostId0,ResponsePostId), get_time(Now),
    put_dict(_{response_post_id:ResponsePostId,
      standing:"delivered-and-verified",observed_at_epoch:Now},State,Delivered),
    as_write_json_durable(Path,Delivered).

as_mattermost_delivered_post_valid(State,Post) :-
    is_dict(Post), as_mattermost_id(Post.id,_),
    as_mattermost_id(Post.channel_id,ChannelId),
    as_mattermost_id(State.channel_id,ChannelId),
    as_mattermost_id(Post.user_id,BotId), as_mattermost_id(State.bot_id,BotId),
    Post.message==State.message,
    as_mattermost_id(Post.root_id,RootPostId),
    as_mattermost_id(State.root_post_id,RootPostId),
    miter_store_nonempty_atom(Post.pending_post_id,PendingPostId),
    miter_store_nonempty_atom(State.pending_post_id,PendingPostId).

as_mattermost_verify_stored_delivery(Config,Token,State) :-
    as_mattermost_id(State.response_post_id,ResponsePostId),
    format(atom(Path),'/api/v4/posts/~w',[ResponsePostId]),
    as_mattermost_get(Config,Token,Path,Post,200),
    as_mattermost_delivered_post_valid(State,Post).

as_mattermost_reconcile_effect(Path,State,Config,_Binding,Token,Result) :-
    Since0 is floor(State.prepared_at_epoch*1000)-5000,
    Since is max(0,Since0),
    as_mattermost_id(State.channel_id,ChannelId),
    format(atom(PostsPath),'/api/v4/channels/~w/posts?since=~d&per_page=200',
      [ChannelId,Since]),
    ( catch(as_mattermost_get(Config,Token,PostsPath,Reply,200),_,fail),
      as_mattermost_posts(Reply,Posts),
      findall(Post,(member(Post,Posts),
        as_mattermost_delivered_post_valid(State,Post)),Matches),
      Matches=[Only] ->
        as_mattermost_mark_delivered(Path,State,Only.id,Delivered),
        as_mattermost_effect_receipt(Path,Delivered,reconciled),
        as_mattermost_effect_result(State,'mattermost-effect-duplicate',Result)
    ; get_time(Now), put_dict(_{standing:"outcome-unknown-held",
        observed_at_epoch:Now},State,Held), as_write_json_durable(Path,Held),
      Result=['mattermost-effect-held',State.effect_id,
        'outcome-unknown-no-blind-resend'] ).

as_mattermost_effect_result(State,Kind,Result) :-
    miter_store_nonempty_atom(State.effect_id,EffectId),
    as_sha256(State.certificate_sha256,CertificateHash),
    as_sha256(State.native_proof_sha256,ProofHash),
    Result=[Kind,EffectId,CertificateHash,ProofHash].

as_mattermost_effect_receipt(EffectPath,State,Standing) :-
    file_directory_name(EffectPath,EffectsDirectory),
    file_directory_name(EffectsDirectory,SurfaceDirectory),
    file_directory_name(SurfaceDirectory,Root),
    format(atom(Relative),'receipts/effect-~w.json',[State.effect_id]),
    directory_file_path(Root,Relative,ReceiptPath), get_time(Now),
    as_write_json_durable(ReceiptPath,
      _{schema:"miter-assistant-effect-receipt-v3",
        effect_id:State.effect_id,idempotency_key:State.effect_id,
        certificate_sha256:State.certificate_sha256,
        native_proof_sha256:State.native_proof_sha256,
        grant_id:State.grant_id,
        capability:"mattermost-create-post",standing:Standing,
        network_access:true,external_effect:true,
        response_post_id:State.response_post_id,observed_at_epoch:Now}).

as_mattermost_id(Value, Id) :-
    miter_store_nonempty_atom(Value,Id), atom_length(Id,26),
    re_match('^[a-z0-9]{26}$',Id).

as_mattermost_cursor_initialize(Root) :-
    directory_file_path(Root,'surface/mattermost-cursor.json',Path),
    ( exists_file(Path) -> true
    ; get_time(Now), Since is floor(Now*1000),
      as_write_json_durable(Path,_{schema:"miter-mattermost-cursor-v1",
        since_ms:Since,standing:"new-events-only-no-backfill"}) ).

as_mattermost_due(Root, PollSeconds) :-
    directory_file_path(Root,'surface/mattermost-poll.json',Path), get_time(Now),
    ( exists_file(Path), catch(miter_store_read_json(Path,Prior),_,fail),
      number(Prior.observed_at_epoch), Now-Prior.observed_at_epoch<PollSeconds ->
        fail
    ; as_write_json_durable(Path,_{schema:"miter-mattermost-poll-v1",
        observed_at_epoch:Now}), true ).

as_mattermost_poll_ready(Root,Config,Binding,Inputs) :-
    directory_file_path(Root,'surface/mattermost-cursor.json',CursorPath),
    miter_store_read_json(CursorPath,Cursor), Since=Cursor.since_ms,
    as_mattermost_token(Config,Token),
    miter_store_nonempty_atom(Binding.channel_id,ChannelId),
    format(atom(Path),'/api/v4/channels/~w/posts?since=~d&per_page=200',
      [ChannelId,Since]),
    as_mattermost_get(Config,Token,Path,Reply,200),
    as_mattermost_posts(Reply,Posts0),
    predsort(as_mattermost_post_order,Posts0,Posts),
    as_mattermost_posts_to_inputs(Root,Config,Binding,Since,Posts,Inputs),
    as_mattermost_max_version(Posts,Since,NextSince),
    as_write_json_durable(CursorPath,_{schema:"miter-mattermost-cursor-v1",
      since_ms:NextSince,standing:"new-events-only-no-backfill"}).

as_mattermost_posts(Reply, Posts) :-
    is_dict(Reply), get_dict(posts,Reply,PostDict), is_dict(PostDict),
    dict_pairs(PostDict,_,Pairs), pairs_values(Pairs,Posts).

as_mattermost_post_version(Post, Version) :-
    Create=Post.create_at, Update=Post.update_at,
    Version is max(Create,Update).

as_mattermost_post_order(Order,A,B) :-
    as_mattermost_post_version(A,AV), as_mattermost_post_version(B,BV),
    compare(Order,AV,BV).

as_mattermost_max_version([],Since,Since).
as_mattermost_max_version([Post|Rest],Since,Max) :-
    as_mattermost_post_version(Post,Version), Next is max(Since,Version),
    as_mattermost_max_version(Rest,Next,Max).

as_mattermost_posts_to_inputs(_,_,_,_,[],[]).
as_mattermost_posts_to_inputs(Root,Config,Binding,Since,[Post|Rest],Inputs) :-
    as_mattermost_posts_to_inputs(Root,Config,Binding,Since,Rest,Tail),
    ( as_mattermost_post_input(Root,Config,Binding,Since,Post,Input) ->
        Inputs=[Input|Tail]
    ; Inputs=Tail ).

as_mattermost_post_input(Root,Config,Binding,Since,Post,Input) :-
    as_mattermost_id(Post.id,PostId),
    as_mattermost_id(Post.channel_id,PostChannelId),
    as_mattermost_id(Binding.channel_id,BindingChannelId),
    PostChannelId==BindingChannelId,
    as_mattermost_id(Post.user_id,UserId),
    as_mattermost_id(Binding.bot_id,BotId), UserId \== BotId,
    member(Principal,Binding.principals), as_mattermost_id(Principal.id,UserId),
    memberchk(Principal.username,Config.authorized_humans),
    as_evaluation_principal_active(Root,Config,Binding,Principal.username,_),
    as_mattermost_post_version(Post,Version), Version>Since,
    string(Post.message), string_codes(Post.message,Codes),
    length(Codes,ByteApprox), ByteApprox=<Config.inbound.max_event_bytes,
    as_mattermost_event_name(PostId,Version,Name),
    directory_file_path(Root,'surface/events',EventDirectory),
    directory_file_path(EventDirectory,Name,EventPath), \+ exists_file(EventPath),
    crypto_data_hash(Post.message,ContentHash,[algorithm(sha256),encoding(utf8)]),
    as_mattermost_raw_post(Root,PostId,Version,Post.message,ContentHash,RawRef),
    as_mattermost_returned_effect(Root,Binding,Post,ReturnedEffect),
    as_mattermost_contact_dict(Config,Binding,Principal,Post,PostId,Version,
      ContentHash,RawRef,ReturnedEffect,Dict),
    as_input_dict_v3(Root,Dict,Input,_),
    as_write_json_durable(EventPath,_{schema:"miter-mattermost-ingress-v1",
      post_id:PostId,event_version:Version,content_sha256:ContentHash,
      raw_ref:RawRef,standing:"admitted-after-stable-id-scope-binding"}).

as_mattermost_event_name(PostId,Version,Name) :-
    format(atom(Name),'~w-~d.json',[PostId,Version]).

as_mattermost_raw_post(Root,PostId,Version,Text,ContentHash,RawRef) :-
    format(atom(Relative),'surface/raw/~w-~d.json',[PostId,Version]),
    directory_file_path(Root,Relative,Path),
    ( exists_file(Path) -> true
    ; as_write_json_durable(Path,_{schema:"miter-mattermost-raw-contact-v1",
        post_id:PostId,event_version:Version,content_sha256:ContentHash,text:Text}) ),
    atom_string(RawRef,Relative).

as_mattermost_prefixed(Id, Prefixed) :- atom_concat(mm_,Id,Prefixed).
as_mattermost_version_symbol(Version, Symbol) :- format(atom(Symbol),'v~d',[Version]).

% A reply becomes returned-contact material only when it follows exactly one
% durable, delivered Miter effect in the same resolved group thread.  This is
% carrier chronology, not an interpretation of what the reply means.  Native
% MeTTa must still join the carrier witness to the matching persisted
% VoiceRNA/effect proof before the relation can affect movement.
as_mattermost_returned_effect(Root,Binding,Post,Returned) :-
    ( Post.root_id=="" -> Returned=no_returned_effect
    ; as_mattermost_id(Post.root_id,RootPostId),
      as_mattermost_id(Post.channel_id,ChannelId),
      as_mattermost_post_version(Post,PostVersion),
      directory_file_path(Root,'surface/effects',EffectsDirectory),
      ( exists_directory(EffectsDirectory) ->
          directory_files(EffectsDirectory,Names),
          findall(Observed-State,
            ( member(Name,Names), file_name_extension(_,json,Name),
              directory_file_path(EffectsDirectory,Name,Path),
              catch(miter_store_read_json(Path,State),_,fail),
              as_mattermost_returned_effect_state(State,Binding,ChannelId,
                RootPostId,PostVersion,Observed) ),
            Candidates),
          as_mattermost_unique_latest_effect(Candidates,Returned)
      ; Returned=no_returned_effect )
    ), !.

as_mattermost_returned_effect_state(State,Binding,ChannelId,RootPostId,
    PostVersion,Observed) :-
    is_dict(State), State.schema=="miter-mattermost-effect-v1",
    State.standing=="delivered-and-verified",
    as_mattermost_id(State.channel_id,ChannelId),
    as_mattermost_id(Binding.channel_id,ChannelId),
    as_mattermost_id(State.root_post_id,RootPostId),
    as_mattermost_id(State.source_post_id,_),
    as_mattermost_id(State.response_post_id,_),
    miter_store_nonempty_atom(State.effect_id,_),
    number(State.observed_at_epoch), Observed=State.observed_at_epoch,
    Observed*1000=<PostVersion.

as_mattermost_unique_latest_effect([],no_returned_effect).
as_mattermost_unique_latest_effect(Candidates,Returned) :-
    Candidates=[_|_], pairs_keys(Candidates,ObservedValues),
    max_list(ObservedValues,Latest),
    findall(State,member(Latest-State,Candidates),LatestStates),
    ( LatestStates=[Only] -> Returned=Only
    ; Returned=ambiguous_returned_effect ), !.

as_mattermost_contact_dict(Config,Binding,Principal,Post,PostId,Version,
    ContentHash,RawRef,ReturnedEffect,Dict) :-
    as_mattermost_prefixed(PostId,ContactId),
    as_mattermost_prefixed(Binding.team_id,TeamId),
    as_mattermost_prefixed(Binding.channel_id,ChannelId),
    as_mattermost_prefixed(Principal.id,PrincipalId),
    as_mattermost_version_symbol(Version,VersionId),
    ( Post.root_id=="" -> ThreadRaw=PostId ; as_mattermost_id(Post.root_id,ThreadRaw) ),
    as_mattermost_prefixed(ThreadRaw,ThreadId),
    format(atom(InputId),'~w_~w',[ContactId,VersionId]),
    format(atom(Occurrence),'mm_occurrence_~w',[PostId]),
    format(atom(Material),'mm_material_~w',[PostId]),
    format(atom(Whole),'mm_whole_~w',[PostId]),
    format(atom(Fact),'mm_fact9_~w',[PostId]),
    format(atom(Weave),'mm_thread_~w',[ThreadRaw]),
    atom_string(ContentHashString,ContentHash), atom_string(RawRefString,RawRef),
    Roles=["Balance"],
    as_mattermost_returned_contact_material(ReturnedEffect,PostId,Relations0,
      Parents,ReturnedParticipants,FlourishingStanding,FlourishingEvidence),
    append([_{id:Material,kind:"surface-contact",standing:"support",
      evidence:"exact-payload-preserved"}],Relations0,Relations),
    as_mattermost_flourishing_views(Whole,FlourishingStanding,
      FlourishingEvidence,Flourishings),
    append([_{id:ContactId,kind:"human",
      lineage:["mattermost",ContactId,VersionId],
      claim:_{kind:"text",content_sha256:ContentHashString,
        text:Post.message,raw_ref:RawRefString},standing:"candidate",
      authority:"no-contact-no-movement-authority"}],ReturnedParticipants,
      Participants),
    format(atom(PayloadRef),'sha256_~w',[ContentHash]),
    Dict=_{schema:"miter-assistant-input-v3",input_id:InputId,
      input_kind:"surface-contact",
      surface:_{carrier_kind:"mattermost",server_id:"mattermost_local",
        team_id:TeamId,channel_id:ChannelId,principal_id:PrincipalId,
        post_id:ContactId,thread_id:ThreadId,event_version:VersionId},
      contact:_{id:ContactId,source_kind:"human-contact",
        principal:Principal.username,audience:Config.scope.audience,
        project:Config.scope.project,occurrence:Occurrence,
        proto:"mattermost_unfamiliar_contact",payload_ref:PayloadRef,
        parents:Parents,configuration:_{
          d_relations:Relations,
          d_distinctions:[_{id:"contact-meaning-vs-carrier-bytes",
            standing:"available",evidence:"membrane-noninterpretation"}],
          omega_relations:[_{id:Whole,roles:Roles,standing:"support",
            evidence:"contact-participates-in-one-unity"}],
          interfaces:[_{id:"mattermost-conversation",standing:"open",
            evidence:"authorized-stable-id-route"}],
          weave:[_{id:Weave,standing:"open",evidence:"mattermost-thread"}],
          soul_relations:[_{id:"constitutive-soul-participation",
            standing:"support",evidence:"read-only-genome-and-living-expression"}],
          present:_{context:"mattermost-present",evidence:"event-version"},
          fact_views:[_{id:Fact,support:Roles,relation_ids:[Whole],
            recognition:"recognized",evidence:"finite-balance-contact-expression"}],
          flourishing_views:Flourishings,possibilities:[],
          participants:Participants}}}.

as_mattermost_returned_contact_material(no_returned_effect,_PostId,[],[],[],
    "unresolved","contact-relative-standing-not-yet-formed").
as_mattermost_returned_contact_material(ambiguous_returned_effect,_PostId,[],
    [],[],"unresolved","ambiguous-prior-effect-held-for-native-inquiry").
as_mattermost_returned_contact_material(State,PostId,[Relation],Parents,
    [Participant],"unknown","verified-return-reopens-flourishing-inquiry") :-
    is_dict(State), miter_store_nonempty_atom(State.effect_id,EffectId),
    as_mattermost_id(State.source_post_id,SourcePostId),
    as_mattermost_id(State.response_post_id,ResponsePostId),
    as_mattermost_prefixed(SourcePostId,SourceContactId),
    as_mattermost_prefixed(ResponsePostId,ResponseContactId),
    as_mattermost_prefixed(PostId,CurrentContactId),
    format(atom(ParticipantId),'returned_~w_~w',[EffectId,CurrentContactId]),
    atom_string(EffectIdString,EffectId),
    atom_string(ParticipantIdString,ParticipantId),
    atom_string(SourceContactString,SourceContactId),
    atom_string(ResponseContactString,ResponseContactId),
    atom_string(CurrentContactString,CurrentContactId),
    Parents=[SourceContactString,ResponseContactString],
    Relation=_{id:EffectIdString,kind:"returned-mattermost-effect",
      standing:"support",evidence:"verified-delivered-response-in-same-thread"},
    Participant=_{id:ParticipantIdString,kind:"tool",
      lineage:["mattermost-return",EffectIdString,CurrentContactString],
      claim:_{kind:"relation",target:EffectIdString,
        proposed_standing:"support",
        evidence:"verified-delivered-response-in-same-thread"},
      standing:"supported",authority:"no-contact-no-movement-authority"}.

as_mattermost_flourishing_views(Whole,Standing,Evidence,Views) :-
    atom_string(WholeString,Whole),
    findall(_{value:Value,relation_id:WholeString,standing:Standing,
      evidence:Evidence},
      member(Value,["AgencyBalance","AttentionStewardship","CognitiveResilience",
        "ConnectionDepth","CreativeTranscendence","PurposeBeyondUtility",
        "SharedUnderstanding","TimeCoherence","WonderPreservation"]),Views).

% Stable binding is rechecked from the private runtime record before payload
% cognition.  The public configuration names the scope; stable IDs never enter
% Git and never acquire semantic authority.
miter_mattermost_scope_bind(Root,Surface,DeclaredScope,Result) :-
    catch((as_mattermost_config(Root,Config),
      as_mattermost_binding_local(Root,Config,Binding),
      as_mattermost_surface_matches(Config,Surface,Binding,Principal),
      miter_assistant_declared_scope(DeclaredScope,Scope),
      miter_store_nonempty_atom(Principal.username,PrincipalName),
      as_evaluation_principal_active(Root,Config,Binding,PrincipalName,_),
      miter_store_nonempty_atom(Config.scope.audience,Audience),
      miter_store_nonempty_atom(Config.scope.project,Project),
      Scope=[scope,PrincipalName,Audience,Project],
      miter_store_nonempty_atom(Surface.server_id,ServerId),
      miter_store_nonempty_atom(Surface.team_id,TeamId),
      miter_store_nonempty_atom(Surface.channel_id,ChannelId),
      miter_store_nonempty_atom(Surface.principal_id,PrincipalId),
      miter_store_nonempty_atom(Surface.post_id,PostId),
      miter_store_nonempty_atom(Surface.thread_id,ThreadId),
      miter_store_nonempty_atom(Surface.event_version,EventVersion),
      Route=['surface-route',mattermost,
        ServerId,TeamId,ChannelId,PrincipalId],
      Event=['surface-event',PostId,ThreadId,EventVersion],
      Result=['scope-binding-v1',Route,Scope,Event,
        'authorized-before-payload-cognition',
        ['binding-record','mattermost-runtime-binding',mattermost]]),_,
      Result=['scope-binding-rejected','stable-identity-or-scope-not-authorized']), !.

as_mattermost_surface_matches(Config,Surface,Binding,Principal) :-
    is_dict(Surface), Surface.carrier_kind=="mattermost",
    Surface.server_id=="mattermost_local",
    miter_store_nonempty_atom(Binding.team_id,TeamId),
    miter_store_nonempty_atom(Binding.channel_id,ChannelId),
    as_mattermost_prefixed(TeamId,ExpectedTeam),
    as_mattermost_prefixed(ChannelId,ExpectedChannel),
    atom_string(ExpectedTeam,Surface.team_id),
    atom_string(ExpectedChannel,Surface.channel_id),
    member(Principal,Binding.principals),
    as_mattermost_id(Principal.id,PrincipalId),
    as_mattermost_prefixed(PrincipalId,ExpectedPrincipal),
    atom_string(ExpectedPrincipal,Surface.principal_id),
    memberchk(Principal.username,Config.authorized_humans).

% AMA-1.2 is a mechanical reach boundary.  It can admit a principal or effect
% only while the separately witnessed evaluation segment is active.  It never
% interprets contact, chooses a model, forms movement, or decides what to say.
as_evaluation_group_active(Root,Config,Binding,GrantId) :-
    as_evaluation_grant(Root,Config,Binding,GrantId,Grant),
    memberchk("mattermost-new-event",Grant.capabilities),
    as_evaluation_event_available(Root,Grant).

as_evaluation_principal_active(Root,Config,Binding,Principal0,GrantId) :-
    miter_store_nonempty_atom(Principal0,Principal),
    atom_string(Principal,PrincipalString),
    as_evaluation_grant(Root,Config,Binding,GrantId,Grant),
    memberchk(PrincipalString,Grant.principals),
    memberchk("mattermost-new-event",Grant.capabilities),
    as_evaluation_event_available(Root,Grant).

as_evaluation_effect_available(Root,Config,Binding,EffectId0,GrantId) :-
    miter_store_nonempty_atom(EffectId0,EffectId),
    as_evaluation_grant(Root,Config,Binding,GrantId,Grant),
    memberchk("mattermost-create-post",Grant.capabilities),
    as_evaluation_effect_counts(Root,Grant,Total,Recent),
    Total<Grant.limits.outbound_posts,
    Recent<Grant.limits.outbound_per_hour,
    \+ as_evaluation_other_pending_effect(Root,EffectId).

as_evaluation_grant(Root,Config,Binding,GrantId,Grant) :-
    as_mattermost_binding_matches_config(Config,Binding),
    directory_file_path(Root,'evaluation-grants.json',Path),
    miter_store_read_json(Path,Document),is_dict(Document),
    Document.schema=="miter-evaluation-grants-v1",
    Document.standing=="active-explicit-grants",
    Document.authority=="AMA-1.2-ratified-by-berton",
    get_dict(grants,Document,[Grant]),is_dict(Grant),
    Grant.standing=="active",
    miter_store_nonempty_atom(Grant.id,GrantId),GrantId=='ama-1.2',
    Grant.scope==Config.scope,
    Grant.principals==Config.authorized_humans,
    Grant.required_group_members==Config.required_group_members,
    as_mattermost_binding_sha256(Root,BindingHash),
    as_sha256(Grant.binding_sha256,BindingHash),
    number(Grant.activated_at_epoch),number(Grant.segment_expires_at_epoch),
    number(Grant.maximum_expires_at_epoch),get_time(Now),
    Now>=Grant.activated_at_epoch,Now=<Grant.segment_expires_at_epoch,
    Now=<Grant.maximum_expires_at_epoch,
    as_evaluation_control_allows(Root),
    as_evaluation_limits_valid(Grant.limits).

as_evaluation_limits_valid(Limits) :-
    is_dict(Limits),
    Limits.admitted_events==1000,
    Limits.outbound_posts==500,
    Limits.outbound_per_hour==60,
    Limits.remote_calls==50.

as_evaluation_control_allows(Root) :-
    directory_file_path(Root,'control.json',Path),
    miter_store_read_json(Path,Control),is_dict(Control),
    Control.schema=="miter-assistant-control-v1",
    Control.command=="continue".

as_mattermost_binding_sha256(Root,Hash) :-
    directory_file_path(Root,'surface/mattermost-binding.json',Path),
    crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]).

as_evaluation_event_available(Root,Grant) :-
    as_evaluation_json_count(Root,'surface/events',Count),
    Count<Grant.limits.admitted_events.

as_evaluation_json_count(Root,Relative,Count) :-
    directory_file_path(Root,Relative,Directory),directory_files(Directory,Names),
    include(as_mattermost_json_name,Names,JsonNames),length(JsonNames,Count).

as_mattermost_json_name(Name) :- file_name_extension(_,json,Name).

as_evaluation_effect_counts(Root,_Grant,Total,Recent) :-
    directory_file_path(Root,'surface/effects',Directory),directory_files(Directory,Names),
    get_time(Now),Threshold is Now-3600,
    findall(Started,
      (member(Name,Names),as_mattermost_json_name(Name),
       directory_file_path(Directory,Name,Path),
       catch(miter_store_read_json(Path,State),_,fail),is_dict(State),
       State.schema=="miter-mattermost-effect-v1",
       number(State.transmission_started_at_epoch),
       State.transmission_started_at_epoch>0,
       Started=State.transmission_started_at_epoch),StartedTimes),
    length(StartedTimes,Total),include(as_evaluation_since(Threshold),StartedTimes,RecentTimes),
    length(RecentTimes,Recent).

as_evaluation_since(Threshold,Value) :- Value>=Threshold.

as_evaluation_other_pending_effect(Root,EffectId) :-
    directory_file_path(Root,'surface/effects',Directory),directory_files(Directory,Names),
    member(Name,Names),as_mattermost_json_name(Name),
    directory_file_path(Directory,Name,Path),
    catch(miter_store_read_json(Path,State),_,fail),is_dict(State),
    State.schema=="miter-mattermost-effect-v1",
    miter_store_nonempty_atom(State.effect_id,Other),Other\==EffectId,
    memberchk(State.standing,
      ["transmission-started-outcome-unknown","outcome-unknown-held"]),!.
