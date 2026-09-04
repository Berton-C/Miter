% G31 P9 bounded live Mattermost mechanics.
% Meaning and certification remain native MeTTa; this membrane owns only exact
% private joins, Keychain/HTTP/process mechanics, hashing and durable journals.

:- module(miter_mattermost_live_canary_v1,[
    g31_live_preflight/2,
    g31_live_activate/2,
    g31_live_wait_allow/3,
    g31_live_recover_allow/3,
    g31_live_restart/2,
    g31_live_wait_denied/2,
    g31_live_panic/2,
    g31_live_revoke/2,
    g31_live_status/2,
    g31_native_certificate_store/4
]).

:- ensure_loaded('miter_store.pl').
:- use_module(library(crypto)).
:- use_module(library(http/http_open)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(process)).
:- use_module(library(readutil)).

g31_plan_commit('4f81d42e53ce8985238a2a56927778689e9628f4').
g31_candidate('/Users/claritymiter/miter/evidence/G31/p3-351/candidate/extension/mattermost_bridge.pl',
              'cf771e7bdfa571f695a3949177cb33ed6fb04431999e88401163b21a328efca3').
g31_transport('/Users/claritymiter/miter/effect_membranes/miter_surface_transport_lab_v1.pl',
              '81d2ee5d219e2cdadeb231202d698f0a5cf10a6f50a633cbcf7ccd21e40da4d6').
g31_private_grant('/Users/claritymiter/miter/config/local/g31/p7-inactive-live-grant-v3.json',
                  'afc96d0e1705779f6f1a2eb084b5e6d3c8d77e66b7706a248389ea906d2deb6c').
g31_private_approval('/Users/claritymiter/miter/config/local/g31/p8-live-effect-approval-v1.json',
                     'ad51106cbc657fabd8e15d1d3caadd8a9e728245a551149befadb7243b5ff02f').
g31_approval_record_hash('85e16a0ea44a5bc98762612ede5b33f961d9a1d036e601a76b9796a5fe98ee72').
g31_proposal_hash('bd1147f9d25e1e5ead6907e347f27a587866699237b614951b6176525a71bdc1').
g31_p7_closure_hash('dab4a3483ad4fb36d67ecd2c1e95cafe6ceade56cca21cdc3033a9dc5c7b363f').
g31_canary_text("Miter G31 bounded live canary").
g31_canary_utterance("Miter received this bounded G31 canary contact. This response is certified only for the current test; it grants no ongoing access and used no history, Chroma, or prior memory.").
g31_keychain_account(bcb).
g31_keychain_service('ai.bgi.miter.mattermost').
g31_state_path('/Users/claritymiter/miter/config/local/g31/p9-live-state-v1.json').
g31_private_root('/Users/claritymiter/miter/config/local/g31/p9-live').
g31_petta_main('/private/tmp/miter-g06-petta-ae66fa8/src/main.pl').

g31_live_preflight(Root0,Result) :-
    g31_guarded(g31_preflight_checked(Root0),Result),!.
g31_live_activate(Root0,Result) :-
    g31_guarded(g31_activate_checked(Root0),Result),!.
g31_live_wait_allow(Root0,Slot0,Result) :-
    g31_guarded(g31_wait_allow_checked(Root0,Slot0),Result),!.
g31_live_recover_allow(Root0,Slot0,Result) :-
    g31_guarded(g31_recover_allow_checked(Root0,Slot0),Result),!.
g31_live_restart(Root0,Result) :-
    g31_guarded(g31_restart_checked(Root0),Result),!.
g31_live_wait_denied(Root0,Result) :-
    g31_guarded(g31_wait_denied_checked(Root0),Result),!.
g31_live_panic(Root0,Result) :-
    g31_guarded(g31_panic_checked(Root0),Result),!.
g31_live_revoke(Root0,Result) :-
    g31_guarded(g31_revoke_checked(Root0),Result),!.
g31_live_status(Root0,Result) :-
    g31_guarded(g31_status_checked(Root0),Result),!.

g31_guarded(Goal,Result) :-
    catch((call(Goal,Result0)->Result=Result0;Result=['g31-live-failure','contract-failed']),
          _,Result=['g31-live-failure','typed-mechanical-failure']).

g31_preflight_checked(Root0,Result) :-
    g31_root(Root0,Root),g31_authority(Data),g31_load_candidate(Module),
    State0=_{cursor:0,seen:[],effects:[],panic:false},
    Config=_{server_id:s1,team_id:t1,channel_id:c1,user_id:u1,auth_ref:a1},
    Frame=_{server_id:s1,team_id:t1,channel_id:c1,user_id:u1,event:posted,
            data:_{id:p1,root_id:'',create_at:1},seq:1},
    call(Module:surface_ingest(Config,State0,Frame,State1,Inbound)),
    Inbound.status==accepted,
    Denied=_{server_id:s1,team_id:t1,channel_id:denied,user_id:u1,event:posted,
             data:_{content_must_not_be_read:sentinel},seq:2},
    call(Module:surface_ingest(Config,State1,Denied,State1,DeniedOutcome)),
    DeniedOutcome.status==rejected,DeniedOutcome.reason==unauthorized,
    Effect=_{schema:'miter-surface-effect-v1',id:e1,idempotency_key:k1,
             channel_id:c1,message:"preflight"},
    call(Module:surface_effect(Config,State1,Effect,State2,EffectOutcome)),
    EffectOutcome.status==accepted,
    call(Module:surface_panic(State2,PanicState)),
    call(Module:surface_effect(Config,PanicState,Effect,PanicState,PanicOutcome)),
    PanicOutcome.status==rejected,PanicOutcome.reason==panic_active,
    g31_hash_text("synthetic-server",ServerHash),
    g31_hash_text("synthetic-team",TeamHash),
    g31_hash_text("synthetic-channel",ChannelHash),
    g31_hash_text("synthetic-principal",PrincipalHash),
    g31_hash_text("synthetic-post",PostHash),
    g31_hash_text("synthetic-version",VersionHash),
    g31_canary_text(Canary),g31_hash_text(Canary,ContentHash),
    g31_canary_utterance(Utterance),g31_hash_text(Utterance,_UtteranceHash),
    g31_hash_text("synthetic-effect",EffectHash),
    g31_native_certificate(Root,preflight,ServerHash,TeamHash,ChannelHash,
      PrincipalHash,PostHash,VersionHash,ContentHash,EffectHash,Certificate),
    Certificate.standing=="certified-utterance",
    g31_evidence_path(Root,'preflight-redacted.json',Path),
    Public=_{schema:'miter-g31-live-preflight-v1',status:'PASS-BOUNDED',
      plan_commit:Data.plan_commit,candidate_sha256:Data.candidate_hash,
      transport_sha256:Data.transport_hash,
      private_grant_sha256:Data.private_grant_hash,
      private_approval_sha256:Data.private_approval_hash,
      candidate_ingest:true,candidate_denied_before_payload:true,
      candidate_effect:true,candidate_panic:true,native_certificate:true,
      credential_lookups:0,network_requests:0,post_content_reads:0,
      message_reads:0,message_writes:0,api_mutations:0,active:false},
    g31_public_once(Path,Public),
    Result=['g31-live-preflight-pass',Data.candidate_hash,Data.private_approval_hash].

g31_activate_checked(Root0,Result) :-
    g31_root(Root0,Root),g31_authority(Data),g31_preflight_ready(Root),
    g31_state_path(StatePath),\+exists_file(StatePath),
    g31_keychain_token(Token),
    get_time(Now),StartedMs is floor(Now*1000),ExpiresMs is StartedMs+1800000,
    catch(g31_bot_identity(Data,Token),_,fail),
    InitialCandidate=_{cursor:StartedMs,seen:[],effects:[],panic:false},
    State=_{schema:'miter-g31-live-activation-v1',plan_commit:Data.plan_commit,
      evidence_root:Root,private_grant_sha256:Data.private_grant_hash,
      private_approval_sha256:Data.private_approval_hash,
      candidate_hash:Data.candidate_hash,transport_hash:Data.transport_hash,
      activated_at_ms:StartedMs,expires_at_ms:ExpiresMs,active:true,
      network_allowed:true,phase:'awaiting-allow-1',bridge_generation:1,
      allowlisted_inputs:0,denied_inputs:0,outbound_effects:0,restarts:0,
      allow_cursor:StartedMs,denied_cursor:StartedMs,candidate_state:InitialCandidate,
      panic:false,revoked:false,network_requests:1,credential_lookups:1,
      post_content_reads:0,native_invocations:0},
    g31_private_replace(StatePath,State),
    g31_evidence_path(Root,'activation-redacted.json',PublicPath),
    g31_public_once(PublicPath,_{schema:'miter-g31-live-activation-redacted-v1',
      status:active,plan_commit:Data.plan_commit,activated_at_ms:StartedMs,
      expires_at_ms:ExpiresMs,max_duration_minutes:30,bridge_generation:1,
      phase:'awaiting-allow-1',candidate_sha256:Data.candidate_hash,
      transport_sha256:Data.transport_hash,
      private_grant_sha256:Data.private_grant_hash,
      private_approval_sha256:Data.private_approval_hash,
      allowed_network:'exact-loopback-mattermost-only',history_access:false,
      chroma_access:false,prior_memory_access:false,credential_value_returned:false,
      network_requests:1,credential_lookups:1,message_writes:0}),
    Result=['g31-live-activated',StartedMs,ExpiresMs,'awaiting-allow-1'].

g31_wait_allow_checked(Root0,Slot0,Result) :-
    g31_root(Root0,Root),g31_slot(Slot0,Slot),g31_authority(Data),
    g31_state(State0),g31_same_text(State0.evidence_root,Root),g31_allow_phase(Slot,State0.phase),
    g31_live_state_ready(State0),State0.allowlisted_inputs<2,State0.outbound_effects<2,
    g31_keychain_token(Token),
    g31_wait_for_post(Data,Token,allow,State0.allow_cursor,State0.expires_at_ms,
                      State0.network_requests,Post,Cursor,Requests),
    g31_load_candidate(Module),g31_candidate_state(State0.candidate_state,Candidate0),
    g31_allow_frame(Data,Post,Frame),
    call(Module:surface_ingest(Data.candidate_config,Candidate0,Frame,Candidate1,Inbound)),
    Inbound.status==accepted,
    get_dict(message,Post,Message0),g31_text(Message0,Message),
    g31_canary_text(Canary),Message==Canary,
    g31_event_hashes(Data,Post,PostHash,VersionHash,ContentHash),
    g31_pending_id(Post.id,PendingId),g31_hash_text(PendingId,EffectHash),
    g31_native_certificate(Root,Slot,Data.server_hash,Data.team_hash,
      Data.allow_channel_hash,Data.principal_hash,PostHash,VersionHash,
      ContentHash,EffectHash,Certificate),
    Certificate.standing=="certified-utterance",
    g31_canary_utterance(Utterance),g31_hash_text(Utterance,ObservedUtteranceHash),
    g31_same_text(Certificate.utterance_sha256,ObservedUtteranceHash),
    g31_same_text(Certificate.effect_id_sha256,EffectHash),
    Effect=_{schema:'miter-surface-effect-v1',id:PendingId,idempotency_key:PendingId,
      channel_id:Data.allow_channel_id,message:Utterance},
    call(Module:surface_effect(Data.candidate_config,Candidate1,Effect,Candidate2,EffectOutcome)),
    EffectOutcome.status==accepted,Descriptor=EffectOutcome.descriptor,
    g31_private_effect_path(Slot,EffectPath),
    get_time(PreparedAt),PreparedMs is floor(PreparedAt*1000),
    Pending=_{schema:'miter-g31-private-effect-v1',slot:Slot,status:pending,
      source_post_id:Post.id,source_post_sha256:PostHash,
      source_version_sha256:VersionHash,content_sha256:ContentHash,
      effect_id:PendingId,effect_id_sha256:EffectHash,descriptor:Descriptor,
      certificate_sha256:Certificate.certificate_payload_sha256,prepared_at_ms:PreparedMs,
      receipt:null,outcome:'not-attempted'},
    g31_private_once(EffectPath,Pending),
    g31_evidence_slot_path(Root,Slot,'prepare',PreparePublic),
    g31_public_once(PreparePublic,_{schema:'miter-g31-effect-prepare-redacted-v1',
      slot:Slot,status:pending,source_post_sha256:PostHash,
      source_version_sha256:VersionHash,content_sha256:ContentHash,
      effect_id_sha256:EffectHash,certificate_sha256:Certificate.certificate_payload_sha256,
      pending_durable_before_send:true,prepared_at_ms:PreparedMs}),
    g31_commit_effect(Data,Token,Descriptor,Pending,EffectPath,Confirmed,CommitRequests),
    Confirmed.status==confirmed,
    g31_candidate_state_json(Candidate2,CandidateJson),
    AllowCount is State0.allowlisted_inputs+1,
    EffectCount is State0.outbound_effects+1,
    g31_after_allow_phase(Slot,NextPhase),
    TotalRequests is Requests+CommitRequests,
    CredentialLookups is State0.credential_lookups+1,
    ContentReads is State0.post_content_reads+1,
    NativeInvocations is State0.native_invocations+1,
    State1=State0.put(_{phase:NextPhase,allowlisted_inputs:AllowCount,
      outbound_effects:EffectCount,allow_cursor:Cursor,candidate_state:CandidateJson,
      network_requests:TotalRequests,credential_lookups:CredentialLookups,
      post_content_reads:ContentReads,native_invocations:NativeInvocations}),
    g31_state_path(StatePath),g31_private_replace(StatePath,State1),
    g31_evidence_slot_path(Root,Slot,'event',EventPublic),
    g31_public_once(EventPublic,_{schema:'miter-g31-event-redacted-v1',slot:Slot,
      status:accepted,source_post_sha256:PostHash,version_sha256:VersionHash,
      content_sha256:ContentHash,identity_authorized_before_content:true,
      memory_scope:'current-canary-contact-only',history_access:false,
      chroma_access:false,prior_memory_access:false}),
    g31_evidence_slot_path(Root,Slot,'witness',WitnessPublic),
    g31_public_once(WitnessPublic,_{schema:'miter-g31-effect-witness-redacted-v1',
      slot:Slot,status:confirmed,effect_id_sha256:EffectHash,
      external_receipt_sha256:Confirmed.receipt_sha256,
      certificate_sha256:Certificate.certificate_payload_sha256,
      prepare_commit_witness:true,next_phase:NextPhase}),
    Result=['g31-live-allow-complete',Slot,PostHash,EffectHash,NextPhase].

g31_recover_allow_checked(Root0,Slot0,Result) :-
    g31_root(Root0,Root),g31_slot(Slot0,Slot),g31_authority(Data),
    g31_state(State0),g31_same_text(State0.evidence_root,Root),
    g31_allow_phase(Slot,State0.phase),g31_live_state_ready(State0),
    State0.allowlisted_inputs<2,State0.outbound_effects<2,
    g31_private_effect_path(Slot,EffectPath),g31_private_read(EffectPath,EffectRecord),
    EffectRecord.status=="confirmed",g31_keychain_token(Token),
    format(atom(SourcePath),'/api/v4/posts/~w',[EffectRecord.source_post_id]),
    g31_http_json(get,Data.server_url,SourcePath,Token,none,Post,Status),Status=:=200,
    g31_same_text(Post.id,EffectRecord.source_post_id),
    g31_same_text(Post.channel_id,Data.allow_channel_id),
    g31_same_text(Post.user_id,Data.principal_id),
    get_dict(message,Post,Message0),g31_text(Message0,Message),
    g31_canary_text(Canary),Message==Canary,
    g31_event_hashes(Data,Post,PostHash,VersionHash,ContentHash),
    g31_same_text(EffectRecord.source_post_sha256,PostHash),
    g31_same_text(EffectRecord.source_version_sha256,VersionHash),
    g31_same_text(EffectRecord.content_sha256,ContentHash),
    g31_load_candidate(Module),g31_candidate_state(State0.candidate_state,Candidate0),
    g31_allow_frame(Data,Post,Frame),
    call(Module:surface_ingest(Data.candidate_config,Candidate0,Frame,Candidate1,Inbound)),
    Inbound.status==accepted,
    Descriptor=EffectRecord.descriptor,
    Effect=_{schema:'miter-surface-effect-v1',id:EffectRecord.effect_id,
      idempotency_key:EffectRecord.effect_id,channel_id:Data.allow_channel_id,
      message:Descriptor.body.message},
    call(Module:surface_effect(Data.candidate_config,Candidate1,Effect,Candidate2,EffectOutcome)),
    EffectOutcome.status==accepted,g31_descriptor_matches(EffectOutcome.descriptor,Descriptor),
    g31_certificate_path(Root,Slot,CertificatePath),g31_private_read(CertificatePath,Certificate),
    Certificate.standing=="certified-utterance",
    g31_same_text(Certificate.source_post_sha256,PostHash),
    g31_same_text(Certificate.source_version_sha256,VersionHash),
    g31_same_text(Certificate.content_sha256,ContentHash),
    g31_same_text(Certificate.effect_id_sha256,EffectRecord.effect_id_sha256),
    del_dict(certificate_payload_sha256,Certificate,PayloadHash,CertificatePayload),
    g31_json_hash(CertificatePayload,ObservedPayloadHash),
    g31_same_text(PayloadHash,ObservedPayloadHash),
    g31_candidate_state_json(Candidate2,CandidateJson),
    AllowCount is State0.allowlisted_inputs+1,EffectCount is State0.outbound_effects+1,
    NetworkRequests is State0.network_requests+1,
    CredentialLookups is State0.credential_lookups+1,
    ContentReads is State0.post_content_reads+1,
    NativeInvocations is State0.native_invocations+1,
    g31_after_allow_phase(Slot,NextPhase),
    State1=State0.put(_{phase:NextPhase,allowlisted_inputs:AllowCount,
      outbound_effects:EffectCount,allow_cursor:Post.create_at,candidate_state:CandidateJson,
      network_requests:NetworkRequests,credential_lookups:CredentialLookups,
      post_content_reads:ContentReads,native_invocations:NativeInvocations}),
    g31_state_path(StatePath),g31_private_replace(StatePath,State1),
    g31_evidence_slot_path(Root,Slot,'event',EventPublic),
    g31_public_once(EventPublic,_{schema:'miter-g31-event-redacted-v1',slot:Slot,
      status:accepted,source_post_sha256:PostHash,version_sha256:VersionHash,
      content_sha256:ContentHash,identity_authorized_before_content:true,
      memory_scope:'current-canary-contact-only',history_access:false,
      chroma_access:false,prior_memory_access:false,recovered_after_confirmed_commit:true}),
    g31_evidence_slot_path(Root,Slot,'witness',WitnessPublic),
    g31_public_once(WitnessPublic,_{schema:'miter-g31-effect-witness-redacted-v1',
      slot:Slot,status:confirmed,effect_id_sha256:EffectRecord.effect_id_sha256,
      external_receipt_sha256:EffectRecord.receipt_sha256,
      certificate_sha256:Certificate.certificate_payload_sha256,
      prepare_commit_witness:true,recovered_without_post:true,
      recovery_get_requests:1,next_phase:NextPhase}),
    Result=['g31-live-allow-recovered',Slot,PostHash,
      EffectRecord.effect_id_sha256,NextPhase,'additional-posts-zero'].

g31_restart_checked(Root0,Result) :-
    g31_root(Root0,Root),g31_authority(Data),g31_state(State0),
    g31_same_text(State0.evidence_root,Root),State0.phase=="awaiting-restart",
    g31_live_state_ready(State0),g31_load_candidate(Module),
    g31_candidate_state(State0.candidate_state,CandidateState),
    call(Module:surface_reconnect(Data.candidate_config,CandidateState,
         State0.allow_cursor,Reconnect)),Reconnect.status==accepted,
    g31_private_effect_path(1,EffectPath),g31_private_read(EffectPath,EffectRecord),
    EffectRecord.status=="confirmed",
    Descriptor=EffectRecord.descriptor,
    Effect=_{schema:'miter-surface-effect-v1',id:EffectRecord.effect_id,
      idempotency_key:EffectRecord.effect_id,channel_id:Data.allow_channel_id,
      message:Descriptor.body.message},
    call(Module:surface_effect(Data.candidate_config,CandidateState,Effect,
         CandidateState,Duplicate)),
    Duplicate.status==suppressed,Duplicate.reason==duplicate_effect,
    g31_keychain_token(Token),g31_verify_receipt(Data,Token,EffectRecord,ReceiptHash),
    NetworkRequests is State0.network_requests+1,
    CredentialLookups is State0.credential_lookups+1,
    State1=State0.put(_{phase:'awaiting-allow-2',bridge_generation:2,
      restarts:1,network_requests:NetworkRequests,
      credential_lookups:CredentialLookups}),
    g31_state_path(StatePath),g31_private_replace(StatePath,State1),
    g31_evidence_path(Root,'restart-redacted.json',PublicPath),
    g31_public_once(PublicPath,_{schema:'miter-g31-restart-redacted-v1',
      status:resumed,prior_generation:1,bridge_generation:2,
      cursor_readback:true,effect_readback:true,reconnect_accepted:true,
      old_effect_candidate_standing:'duplicate-suppressed',
      old_effect_replay_requests:0,old_effect_replay_writes:0,
      external_receipt_sha256:ReceiptHash,next_phase:'awaiting-allow-2'}),
    Result=['g31-live-restarted',2,'old-effect-replay-zero','awaiting-allow-2'].

g31_wait_denied_checked(Root0,Result) :-
    g31_root(Root0,Root),g31_authority(Data),g31_state(State0),
    g31_same_text(State0.evidence_root,Root),State0.phase=="awaiting-denied",
    g31_live_state_ready(State0),State0.denied_inputs<1,g31_keychain_token(Token),
    g31_wait_for_post(Data,Token,denied,State0.denied_cursor,State0.expires_at_ms,
                      State0.network_requests,Post,Cursor,Requests),
    g31_load_candidate(Module),g31_candidate_state(State0.candidate_state,CandidateState),
    g31_denied_frame(Data,Post,Frame),
    call(Module:surface_ingest(Data.candidate_config,CandidateState,Frame,
         CandidateState,Outcome)),
    Outcome.status==rejected,Outcome.reason==unauthorized,
    g31_hash_text(Post.id,PostHash),
    CredentialLookups is State0.credential_lookups+1,
    State1=State0.put(_{phase:'ready-for-panic',denied_inputs:1,
      denied_cursor:Cursor,network_requests:Requests,
      credential_lookups:CredentialLookups}),
    g31_state_path(StatePath),g31_private_replace(StatePath,State1),
    g31_evidence_path(Root,'denied-redacted.json',PublicPath),
    g31_public_once(PublicPath,_{schema:'miter-g31-denied-redacted-v1',
      status:'rejected-before-cognition',source_post_sha256:PostHash,
      identity_checked_first:true,content_read:false,content_persisted:false,
      native_invocations:0,cognition_invocations:0,response_effects:0,
      next_phase:'ready-for-panic'}),
    Result=['g31-live-denied-complete',PostHash,'cognition-zero','effects-zero'].

g31_panic_checked(Root0,Result) :-
    g31_root(Root0,Root),g31_authority(Data),g31_state(State0),
    g31_same_text(State0.evidence_root,Root),State0.phase=="ready-for-panic",
    g31_load_candidate(Module),g31_candidate_state(State0.candidate_state,Candidate0),
    call(Module:surface_panic(Candidate0,PanicState)),
    Hypothetical=_{schema:'miter-surface-effect-v1',id:panic_probe,
      idempotency_key:panic_probe,channel_id:Data.allow_channel_id,message:"blocked"},
    call(Module:surface_effect(Data.candidate_config,PanicState,Hypothetical,
         PanicState,PanicOutcome)),
    PanicOutcome.status==rejected,PanicOutcome.reason==panic_active,
    g31_candidate_state_json(PanicState,CandidateJson),get_time(Now),EndedMs is floor(Now*1000),
    State1=State0.put(_{active:false,network_allowed:false,phase:'terminal-panic',
      panic:true,candidate_state:CandidateJson,ended_at_ms:EndedMs}),
    g31_state_path(StatePath),g31_private_replace(StatePath,State1),
    g31_evidence_path(Root,'panic-redacted.json',PublicPath),
    g31_public_once(PublicPath,_{schema:'miter-g31-panic-redacted-v1',
      status:'terminal-panic',ended_at_ms:EndedMs,new_effects_after_panic:0,
      hypothetical_effect_standing:'panic-active-rejected',active:false,
      network_allowed:false,automatic_stop:true,state_preserved:true}),
    Result=['g31-live-panic-complete','terminal-panic','new-effects-zero'].

g31_revoke_checked(Root0,Result) :-
    g31_root(Root0,Root),g31_state(State0),g31_same_text(State0.evidence_root,Root),
    get_time(Now),EndedMs is floor(Now*1000),
    State1=State0.put(_{active:false,network_allowed:false,phase:'terminal-revoked',
      revoked:true,ended_at_ms:EndedMs}),
    g31_state_path(StatePath),g31_private_replace(StatePath,State1),
    g31_evidence_path(Root,'revocation-redacted.json',PublicPath),
    g31_public_once(PublicPath,_{schema:'miter-g31-revocation-redacted-v1',
      status:'terminal-revoked',ended_at_ms:EndedMs,active:false,
      network_allowed:false,future_effects_prohibited:true}),
    Result=['g31-live-revoked','future-effects-prohibited'].

g31_status_checked(Root0,Result) :-
    g31_root(Root0,Root),g31_state(State),g31_same_text(State.evidence_root,Root),
    Result=['g31-live-status',State.phase,State.active,State.network_allowed,
      State.bridge_generation,State.allowlisted_inputs,State.denied_inputs,
      State.outbound_effects,State.restarts,State.panic,State.revoked,
      State.activated_at_ms,State.expires_at_ms].

g31_wait_for_post(Data,Token,Kind,Cursor0,ExpiresMs,Requests0,
                   Post,Cursor,Requests) :-
    get_time(Now),NowMs is floor(Now*1000),
    ( NowMs>=ExpiresMs
    -> g31_expire,!,fail
    ; g31_channel_id(Kind,Data,ChannelId),
      catch(g31_posts_since(Data.server_url,ChannelId,Cursor0,Token,Reply),_,fail),
      Requests1 is Requests0+1,
      ( g31_earliest_human_post(Reply,Data.principal_id,Cursor0,Found,MaxCursor)
      -> Post=Found,Cursor=MaxCursor,Requests=Requests1
      ;  g31_reply_cursor(Reply,Cursor0,Cursor1),sleep(2),
         g31_wait_for_post(Data,Token,Kind,Cursor1,ExpiresMs,Requests1,
                           Post,Cursor,Requests)
      )
    ).

g31_posts_since(Server,ChannelId,Since,Token,Reply) :-
    format(atom(Path),'/api/v4/channels/~w/posts?since=~d',[ChannelId,Since]),
    g31_http_json(get,Server,Path,Token,none,Reply,Status),Status=:=200,
    is_dict(Reply),get_dict(order,Reply,Order),is_list(Order),get_dict(posts,Reply,Posts),is_dict(Posts).

g31_earliest_human_post(Reply,PrincipalId,Cursor,Post,MaxCursor) :-
    g31_posts(Reply,All),g31_reply_cursor_from_posts(All,Cursor,MaxCursor),
    include(g31_human_new(PrincipalId,Cursor),All,Human),Human\=[],
    predsort(g31_post_order,Human,[Post|_]).
g31_posts(Reply,Posts) :-
    findall(Post,(member(Id0,Reply.order),g31_atom(Id0,Id),get_dict(Id,Reply.posts,Post)),Posts).
g31_human_new(PrincipalId,Cursor,Post) :-
    g31_same_text(Post.user_id,PrincipalId),integer(Post.create_at),Post.create_at>Cursor,
    g31_id(Post.id),g31_id(Post.channel_id).
g31_post_order(Order,A,B) :- compare(Order,A.create_at,B.create_at).
g31_reply_cursor(Reply,Cursor,Max) :- g31_posts(Reply,Posts),g31_reply_cursor_from_posts(Posts,Cursor,Max).
g31_reply_cursor_from_posts(Posts,Cursor,Max) :-
    findall(T,(member(P,Posts),integer(P.create_at),T=P.create_at),Times),
    foldl(g31_max,Times,Cursor,Max).
g31_max(Value,Current,Maximum) :- Maximum is max(Value,Current).

g31_allow_frame(Data,Post,Frame) :-
    g31_root_id(Post,RootId),
    Frame=_{server_id:Data.server_id,team_id:Data.team_id,
      channel_id:Post.channel_id,user_id:Post.user_id,event:posted,
      data:_{id:Post.id,root_id:RootId,create_at:Post.create_at},seq:Post.create_at}.
g31_denied_frame(Data,Post,Frame) :-
    g31_root_id(Post,RootId),
    Frame=_{server_id:Data.server_id,team_id:Data.team_id,
      channel_id:Post.channel_id,user_id:Post.user_id,event:posted,
      data:_{id:Post.id,root_id:RootId,create_at:Post.create_at},seq:Post.create_at}.
g31_root_id(Post,RootId) :-
    (get_dict(root_id,Post,Value)->g31_atom_allow_empty(Value,RootId);RootId='').

g31_event_hashes(_Data,Post,PostHash,VersionHash,ContentHash) :-
    g31_hash_text(Post.id,PostHash),
    format(string(Version),'~w:~d',[Post.id,Post.create_at]),g31_hash_text(Version,VersionHash),
    g31_canary_text(Canary),g31_hash_text(Canary,ContentHash).

g31_commit_effect(Data,Token,Descriptor,Pending,EffectPath,Confirmed,Requests) :-
    get_time(Before),AttemptMs is floor(Before*1000),
    Attempted=Pending.put(_{outcome:'request-started',attempted_at_ms:AttemptMs}),
    g31_private_replace(EffectPath,Attempted),
    ( catch(g31_http_json(post,Data.server_url,Descriptor.path,Token,
                          Descriptor.body,Reply,Status),_,fail),memberchk(Status,[200,201]),
      g31_id(Reply.id),g31_same_text(Reply.channel_id,Data.allow_channel_id),
      g31_same_text(Reply.user_id,Data.bot_id)
    -> g31_hash_text(Reply.id,ReceiptHash),get_time(After),CommittedMs is floor(After*1000),
       Confirmed=Attempted.put(_{status:confirmed,outcome:'receipt-observed',
         receipt:Reply.id,receipt_sha256:ReceiptHash,committed_at_ms:CommittedMs}),
       g31_private_replace(EffectPath,Confirmed),Requests=1
    ;  Unknown=Attempted.put(_{status:unknown,outcome:'transport-outcome-unknown'}),
       g31_private_replace(EffectPath,Unknown),!,fail
    ).

g31_descriptor_matches(A,B) :-
    g31_same_text(A.method,B.method),g31_same_text(A.path,B.path),
    g31_same_text(A.idempotency_key,B.idempotency_key),
    g31_same_text(A.body.channel_id,B.body.channel_id),
    g31_same_text(A.body.message,B.body.message),
    g31_same_text(A.body.pending_post_id,B.body.pending_post_id).

g31_verify_receipt(Data,Token,EffectRecord,ReceiptHash) :-
    g31_id(EffectRecord.receipt),
    format(atom(Path),'/api/v4/posts/~w',[EffectRecord.receipt]),
    g31_http_json(get,Data.server_url,Path,Token,none,Reply,Status),Status=:=200,
    g31_same_text(Reply.id,EffectRecord.receipt),
    g31_same_text(Reply.channel_id,Data.allow_channel_id),
    g31_same_text(Reply.user_id,Data.bot_id),
    g31_text(Reply.message,Message),g31_hash_text(Message,MessageHash),
    g31_canary_utterance(Utterance),g31_hash_text(Utterance,MessageHash),
    g31_hash_text(Reply.id,ReceiptHash).

g31_http_json(Method,Server,Path,Token,Body,Reply,Status) :-
    atom_concat(Server,Path,URL),atom_concat('Bearer ',Token,Header),
    ( Method==get
    -> Options=[method(get),request_header('Authorization'=Header),
                status_code(Status),timeout(15),redirect(false)]
    ; Method==post
    -> Options=[method(post),post(json(Body)),request_header('Authorization'=Header),
                status_code(Status),timeout(15),redirect(false)]
    ),
    setup_call_cleanup(http_open(URL,In,Options),json_read_dict(In,Reply),close(In)).

g31_bot_identity(Data,Token) :-
    g31_http_json(get,Data.server_url,'/api/v4/users/me',Token,none,Reply,Status),
    Status=:=200,g31_same_text(Reply.id,Data.bot_id).

g31_keychain_token(Token) :-
    g31_keychain_account(Account),g31_keychain_service(Service),
    process_create('/usr/bin/security',
      ['find-generic-password','-a',Account,'-s',Service,'-w'],
      [stdin(null),stdout(pipe(Out)),stderr(null),process(Pid)]),
    read_string(Out,8192,Raw),close(Out),process_wait(Pid,exit(0)),
    normalize_space(string(TokenString),Raw),string_length(TokenString,N),N>=16,N=<4096,
    atom_string(Token,TokenString).

g31_native_certificate(Root,Slot,ServerHash,TeamHash,ChannelHash,PrincipalHash,
                       PostHash,VersionHash,ContentHash,EffectHash,Certificate) :-
    g31_approval_record_hash(ApprovalHash),g31_proposal_hash(ProposalHash),
    g31_p7_closure_hash(ClosureHash),g31_private_grant(_,GrantHash),
    g31_candidate(_,CandidateHash),g31_transport(_,TransportHash),
    g31_canary_utterance(Utterance),g31_hash_text(Utterance,UtteranceHash),
    maplist(g31_json_string,[ApprovalHash,ProposalHash,ClosureHash,GrantHash,
      CandidateHash,TransportHash,ServerHash,TeamHash,ChannelHash,PrincipalHash,
      PostHash,VersionHash,ContentHash,Utterance,UtteranceHash,EffectHash,Root,Slot],
      [A,P,C,G,CH,TH,SH,TEH,COH,PRH,POH,VH,CONH,U,UH,EH,R,S]),
    format(string(Script),
      '!(import! &self "/Users/claritymiter/miter/src/bootstrap_mattermost_live_canary_v1.metta")~n!(result stored (let* (($approval (G31LiveEffectApprovalV1 ~s ~s ~s ~s ~s ~s)) ($standing (G31LiveEffectApprovalStanding $approval ~s ~s ~s ~s ~s ~s)) ($contact (g31-live-canary-contact-v1 (server-sha256 ~s) (team-sha256 ~s) (channel-sha256 ~s) (principal-sha256 ~s) (post-sha256 ~s) (version-sha256 ~s) (content-sha256 ~s) (event-class posted) (contact-scope exact-current-event-only) (history-access false) (chroma-access false) (prior-memory-access false))) ($certificate (G31CanaryVoiceCertificate $standing $contact ~s ~s ~s ~s ~s ~s ~s ~s ~s ~s ~s ~s))) ($certificate (g31_native_certificate_store ~s ~s $certificate))))~n',
      [A,P,C,G,CH,TH,A,P,C,G,CH,TH,SH,TEH,COH,PRH,POH,VH,CONH,
       U,UH,UH,EH,EH,SH,TEH,COH,PRH,POH,VH,CONH,R,S]),
    g31_evidence_slot_path(Root,Slot,'native-request',ScriptPath),
    g31_text_once(ScriptPath,Script),g31_petta_main(PettaMain),
    process_create('/opt/homebrew/bin/swipl',
      ['--stack_limit=1g','-q','-s',PettaMain,'--',ScriptPath,silent],
      [stdin(null),stdout(pipe(Out)),stderr(pipe(Err)),process(Pid)]),
    read_string(Out,1048576,Stdout),close(Out),read_string(Err,1048576,Stderr),close(Err),
    process_wait(Pid,exit(0)),Stderr=="",sub_string(Stdout,_,_,_,"g31-native-certificate-stored"),
    g31_certificate_path(Root,Slot,CertificatePath),g31_private_read(CertificatePath,Certificate).

g31_native_certificate_store(Root0,Slot0,Certificate0,Result) :-
    catch((g31_root(Root0,Root),g31_slot_name(Slot0,Slot),
      g31_certificate_parts(Certificate0,PostHash,VersionHash,ContentHash,
        Intention,Utterance,UtteranceHash,EffectHash,ApprovalHash,GrantHash),
      term_string(Intention,IntentionTerm,[quoted(true),ignore_ops(true)]),
      Public0=_{schema:'miter-g31-native-certified-utterance-v1',
        standing:'certified-utterance',slot:Slot,surface:mattermost,
        source_post_sha256:PostHash,source_version_sha256:VersionHash,
        content_sha256:ContentHash,intention_term:IntentionTerm,
        utterance:Utterance,utterance_sha256:UtteranceHash,
        effect_id_sha256:EffectHash,approval_record_sha256:ApprovalHash,
        private_grant_sha256:GrantHash,voice:'VoiceRNA',raw_model_output:false,
        model_calls:0},
      g31_json_hash(Public0,PayloadHash),
      Public=Public0.put(certificate_payload_sha256,PayloadHash),
      g31_certificate_path(Root,Slot,Path),g31_public_once(Path,Public)
      ->Result='g31-native-certificate-stored';Result='g31-native-certificate-held'),
      _,Result='g31-native-certificate-held'),!.

g31_certificate_parts(Certificate,PostHash,VersionHash,ContentHash,
                      Intention,Utterance,UtteranceHash,EffectHash,ApprovalHash,GrantHash) :-
    Certificate=['CertifiedUtterance',[standing,'certified-utterance'],[surface,mattermost],
      ['source-contact',PostHash,VersionHash,ContentHash],[intention,Intention],
      [utterance,Utterance0],['utterance-sha256',UtteranceHash],
      ['effect-id-sha256',EffectHash],['approval-record',ApprovalHash],
      ['private-grant',GrantHash],[voice,'VoiceRNA'],['raw-model-output',prohibited]],
    g31_text(Utterance0,Utterance),g31_canary_utterance(Utterance),
    maplist(g31_sha256,[PostHash,VersionHash,ContentHash,UtteranceHash,EffectHash,
                        ApprovalHash,GrantHash]),
    g31_hash_text(Utterance,ObservedUtteranceHash),
    g31_same_text(UtteranceHash,ObservedUtteranceHash),
    g31_approval_record_hash(ExpectedApprovalHash),
    g31_same_text(ApprovalHash,ExpectedApprovalHash),
    g31_private_grant(_,ExpectedGrantHash),g31_same_text(GrantHash,ExpectedGrantHash).

g31_authority(Data) :-
    g31_plan_commit(PlanCommit),g31_candidate(CandidatePath,CandidateHash),
    g31_transport(TransportPath,TransportHash),
    g31_private_grant(GrantPath,GrantHash),g31_private_approval(ApprovalPath,ApprovalHash),
    g31_file_hash(CandidatePath,CandidateHash),g31_file_hash(TransportPath,TransportHash),
    g31_file_mode(GrantPath,0o600),g31_file_mode(ApprovalPath,0o600),
    g31_file_hash(GrantPath,GrantHash),g31_file_hash(ApprovalPath,ApprovalHash),
    g31_private_read(GrantPath,Grant),g31_private_read(ApprovalPath,Approval),
    Grant.active==false,Grant.network_allowed==false,
    g31_same_text(Grant.live_effect_approval,unresolved),
    Approval.active==false,Approval.network_allowed==false,
    g31_same_text(Approval.activation,unresolved),
    g31_same_text(Approval.plan_commit,'070e5ffbed1f82b5c19e6a625f40a501d3fdebc0'),
    g31_same_text(Approval.private_inactive_grant_sha256,GrantHash),
    g31_same_text(Approval.candidate_hash,CandidateHash),
    g31_same_text(Approval.transport_hash,TransportHash),
    B=Grant.identity_bindings,g31_server_url(B.server.url,ServerUrl),
    maplist(g31_id,[B.server.id,B.team.id,B.allowlisted_channel.id,
      B.denied_control_channel.id,B.human.id,B.bot.id]),
    g31_hash_text(B.server.id,ServerHash),g31_hash_text(B.team.id,TeamHash),
    g31_hash_text(B.allowlisted_channel.id,AllowHash),
    g31_hash_text(B.denied_control_channel.id,DeniedHash),
    g31_hash_text(B.human.id,PrincipalHash),g31_hash_text(B.bot.id,BotHash),
    Data=_{plan_commit:PlanCommit,candidate_path:CandidatePath,candidate_hash:CandidateHash,
      transport_path:TransportPath,transport_hash:TransportHash,
      private_grant_hash:GrantHash,private_approval_hash:ApprovalHash,
      server_url:ServerUrl,server_id:B.server.id,team_id:B.team.id,
      allow_channel_id:B.allowlisted_channel.id,
      denied_channel_id:B.denied_control_channel.id,
      principal_id:B.human.id,bot_id:B.bot.id,server_hash:ServerHash,
      team_hash:TeamHash,allow_channel_hash:AllowHash,denied_channel_hash:DeniedHash,
      principal_hash:PrincipalHash,bot_hash:BotHash,
      candidate_config:_{server_id:B.server.id,team_id:B.team.id,
        channel_id:B.allowlisted_channel.id,user_id:B.human.id,auth_ref:ApprovalHash}}.

g31_load_candidate(Module) :-
    g31_candidate(Path,Hash),g31_file_hash(Path,Hash),load_files(Path,[silent(true)]),
    module_property(Module,file(Path)),current_predicate(Module:surface_ingest/5),
    current_predicate(Module:surface_effect/5),current_predicate(Module:surface_reconnect/4),
    current_predicate(Module:surface_panic/2),!.

g31_preflight_ready(Root) :-
    g31_evidence_path(Root,'preflight-redacted.json',Path),g31_private_read(Path,Doc),
    g31_same_text(Doc.status,'PASS-BOUNDED'),Doc.active==false,
    Doc.network_requests=:=0,Doc.credential_lookups=:=0,Doc.native_certificate==true.

g31_state(State) :-
    g31_state_path(Path),g31_file_mode(Path,0o600),g31_private_read(Path,State),
    g31_same_text(State.schema,'miter-g31-live-activation-v1'),
    g31_plan_commit(Commit),g31_same_text(State.plan_commit,Commit),
    g31_private_grant(_,GrantHash),g31_same_text(State.private_grant_sha256,GrantHash),
    g31_private_approval(_,ApprovalHash),g31_same_text(State.private_approval_sha256,ApprovalHash).

g31_live_state_ready(State) :-
    State.active==true,State.network_allowed==true,State.panic==false,State.revoked==false,
    State.allowlisted_inputs=<2,State.denied_inputs=<1,State.outbound_effects=<2,
    get_time(Now),NowMs is floor(Now*1000),NowMs<State.expires_at_ms.

g31_expire :-
    g31_state(State0),get_time(Now),EndedMs is floor(Now*1000),
    State1=State0.put(_{active:false,network_allowed:false,phase:'terminal-expired',
      ended_at_ms:EndedMs}),g31_state_path(Path),g31_private_replace(Path,State1),
    g31_evidence_path(State0.evidence_root,'expiry-redacted.json',Public),
    (exists_file(Public)->true;g31_public_once(Public,_{schema:'miter-g31-expiry-redacted-v1',
      status:'terminal-expired',ended_at_ms:EndedMs,active:false,network_allowed:false,
      future_effects_prohibited:true})).

g31_candidate_state(Json,State) :-
    get_dict(seen,Json,SeenJson),get_dict(effects,Json,EffectJson),
    get_dict(cursor,Json,Cursor),get_dict(panic,Json,Panic),
    maplist(g31_seen_term,SeenJson,Seen),maplist(g31_effect_term,EffectJson,Effects),
    State=_{cursor:Cursor,seen:Seen,effects:Effects,panic:Panic}.
g31_candidate_state_json(State,Json) :-
    get_dict(seen,State,SeenTerms),get_dict(effects,State,EffectTerms),
    get_dict(cursor,State,Cursor),get_dict(panic,State,Panic),
    maplist(g31_seen_json,SeenTerms,Seen),maplist(g31_effect_json,EffectTerms,Effects),
    Json=_{cursor:Cursor,seen:Seen,effects:Effects,panic:Panic}.
g31_seen_term(D,Id-Version) :- Id=D.id,Version=D.version.
g31_effect_term(D,Id-Key) :- Id=D.id,Key=D.idempotency_key.
g31_seen_json(Id-Version,_{id:Id,version:Version}).
g31_effect_json(Id-Key,_{id:Id,idempotency_key:Key}).

g31_pending_id(PostId0,Pending) :-
    g31_atom(PostId0,PostId),g31_hash_text(PostId,Hash),sub_atom(Hash,0,22,_,Prefix),
    atom_concat(g31p,Prefix,Pending),atom_length(Pending,26).

g31_channel_id(allow,Data,ChannelId) :- get_dict(allow_channel_id,Data,ChannelId).
g31_channel_id(denied,Data,ChannelId) :- get_dict(denied_channel_id,Data,ChannelId).
g31_allow_phase(1,"awaiting-allow-1").
g31_allow_phase(2,"awaiting-allow-2").
g31_after_allow_phase(1,'awaiting-restart').
g31_after_allow_phase(2,'awaiting-denied').
g31_slot(Value,Slot) :- (integer(Value)->Slot=Value;g31_atom(Value,A),atom_number(A,Slot)),memberchk(Slot,[1,2]).
g31_slot_name(Value,Slot) :-
    (g31_same_text(Value,preflight)->Slot=preflight;g31_slot(Value,Slot)).

g31_private_effect_path(Slot,Path) :-
    g31_private_root(Root),make_directory_path(Root),chmod(Root,0o700),
    format(atom(Path),'~w/slot-~w-effect.json',[Root,Slot]).
g31_certificate_path(Root,Slot,Path) :-
    format(atom(Path),'~w/native-certificate-~w.json',[Root,Slot]).
g31_evidence_slot_path(Root,Slot,Kind,Path) :-
    format(atom(Name),'slot-~w-~w-redacted.json',[Slot,Kind]),g31_evidence_path(Root,Name,Path).
g31_evidence_path(Root,Name,Path) :- format(atom(Path),'~w/~w',[Root,Name]).

g31_private_once(Path,Dict) :- \+exists_file(Path),g31_write_json(Path,Dict,0o600,false).
g31_public_once(Path,Dict) :- \+exists_file(Path),g31_write_json(Path,Dict,0o644,false).
g31_private_replace(Path,Dict) :- g31_write_json(Path,Dict,0o600,true).
g31_write_json(Path,Dict,Mode,Replace) :-
    file_directory_name(Path,Directory),make_directory_path(Directory),
    (Mode=:=0o600->chmod(Directory,0o700);true),
    format(atom(Temporary),'~w.next',[Path]),\+exists_file(Temporary),
    setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
      (chmod(Temporary,Mode),json_write_dict(Stream,Dict,[width(0)]),nl(Stream),
       flush_output(Stream),miter_store_ensure_extension(
        '/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
       miter_store_fsync_stream(Stream)),close(Stream)),
    (Replace==true->true;\+exists_file(Path)),rename_file(Temporary,Path).
g31_text_once(Path,Text) :-
    \+exists_file(Path),setup_call_cleanup(open(Path,write,S,[encoding(utf8)]),
      (format(S,'~s',[Text]),flush_output(S)),close(S)).
g31_private_read(Path,Dict) :-
    setup_call_cleanup(open(Path,read,S,[encoding(utf8)]),json_read_dict(S,Dict),close(S)).

g31_json_string(Value,Encoded) :-
    (integer(Value)->format(string(Text),'~d',[Value]);g31_text(Value,Text)),
    with_output_to(string(Encoded),json_write(current_output,Text)).
g31_json_hash(Dict,Hash) :-
    with_output_to(string(Text),json_write_dict(current_output,Dict,[width(0)])),
    g31_hash_text(Text,Hash).
g31_hash_text(Text,Hash) :- crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]).
g31_file_hash(Path,Hash) :- exists_file(Path),crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]).
g31_file_mode(Path,Expected) :-
    exists_file(Path),\+read_link(Path,_,_),process_create('/usr/bin/stat',['-f','%Lp',Path],
      [stdout(pipe(Out)),stderr(null),process(Pid)]),read_string(Out,32,Raw),close(Out),
    process_wait(Pid,exit(0)),normalize_space(string(Text),Raw),atom_concat('0o',Text,Octal),
    atom_number(Octal,Mode),Mode=:=Expected.
g31_sha256(Value) :- g31_atom(Value,Atom),atom_length(Atom,64),re_match('^[a-f0-9]{64}$',Atom).
g31_id(Value) :- g31_text(Value,Text),string_length(Text,26),re_match('^[a-z0-9]{26}$',Text).
g31_text(Value,Text) :-
    (string(Value)->Text=Value;atom(Value)->atom_string(Value,Text)),
    string_length(Text,N),N>0,N=<8192.
g31_same_text(A,B) :- g31_text(A,AT),g31_text(B,BT),AT==BT.
g31_atom(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)),atom_length(Atom,N),N>0.
g31_atom_allow_empty(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)).
g31_server_url(Value,URL) :-
    g31_atom(Value,URL),re_match('^http://127\\.0\\.0\\.1:[0-9]{2,5}$',URL).
g31_root(Value,Root) :-
    g31_atom(Value,Root),re_match('^/Users/claritymiter/miter/evidence/G31/p9-[0-9]{3}$',Root),
    exists_directory(Root),\+read_link(Root,_,_).
