% G33 R14 evidence projection and offline Mattermost mechanics.
% Native MeTTa owns every standing. This membrane verifies hashes, reads public
% committed evidence, invokes the exact candidate on synthetic dictionaries,
% and returns observations. It has no HTTP, Keychain, model, or Chroma surface.
:- ensure_loaded('miter_development_proof_v1.pl').
:- use_module(library(crypto)).
:- use_module(library(http/json)).

g33_r14_file_hash(Path0,Hash) :-
    g33_r14_atom(Path0,Path),crypto_file_hash(Path,H,[algorithm(sha256),encoding(octet)]),
    atom_string(H,Hash).

g33_r14_json_native(Path0,Native) :-
    catch((g33_r14_atom(Path0,Path),g33_r14_public_path(Path),
           setup_call_cleanup(open(Path,read,S,[encoding(utf8)]),json_read_dict(S,D),close(S)),
           dh_document_native(D,Native)),_,Native='evidence-native-unavailable'),!.

% Compact an already-computed current VoiceRNA product without asking MeTTa's
% product engine to reproduce its large proof graph.  This is an acceptance
% observation only: it does not choose wording, standing, or authority.
g33_r14_voice_projection(Result,Projection) :-
    catch((g33_r14_voice_projection_checked(Result,Projection0)->true;
           g33_r14_voice_held(Result,Projection0)),_,g33_r14_voice_held(Result,Projection0)),
    Projection=Projection0,!.

g33_r14_voice_projection_checked(Result,
    ['voice-observation',
     ['voice-proof','expression-certificate-v1','no-emission-authority',Hash],
     ['semantic-projection',Goals,Clauses,Standing,'no-emission-authority']]) :-
    Result=['voice-result',_,Certificate],
    Certificate=['expression-certificate-v1'|_],
    nth0(2,Certificate,['intention',Intention]),
    Intention=['voice-intention',_,_,_,Expected|_],
    findall(Goal,member(['expected',Goal|_],Expected),Goals),
    nth0(8,Certificate,['selected-expression',Selected]),
    Selected=['supported-expression',Clauses|_],
    nth0(9,Certificate,['fresh-audit',Audit]),nth0(3,Audit,Standing),
    last(Certificate,'no-emission-authority'),dh2_hash_native(Certificate,Hash).

g33_r14_voice_held(Result,['voice-held-observation',Head,Hash]) :-
    Result=['voice-result',_,Disposition],Disposition=[Head|_],!,dh2_hash_native(Result,Hash).
g33_r14_voice_held(Result,['voice-held-observation','unrecognized-voice-product',Hash]) :-
    dh2_hash_native(Result,Hash).

g33_r14_identity_probe(Candidate0,Expected0,Mode0,Result) :-
    catch((g33_r14_identity_checked(Candidate0,Expected0,Mode0,Result0)->true;
           Result0=['mattermost-identity-observation-unavailable','contract-failed']),
          Error,g33_r14_error(Error,Result0)),Result=Result0,!.

g33_r14_identity_checked(Candidate0,Expected0,Mode0,Result) :-
    maplist(g33_r14_atom,[Candidate0,Expected0,Mode0],[Candidate,Expected,Mode]),
    Candidate='/Users/claritymiter/miter/evidence/G31/p3-351/candidate/extension/mattermost_bridge.pl',
    crypto_file_hash(Candidate,Expected,[algorithm(sha256),encoding(octet)]),
    load_files(Candidate,[silent(true)]),
    Config=_{server_id:s1,team_id:t1,channel_id:c1,user_id:u1,auth_ref:a1},
    State0=_{cursor:0,seen:[],effects:[],panic:false},
    g33_r14_identity_frame(Mode,Frame),
    miter_mattermost_bridge:surface_ingest(Config,State0,Frame,State1,Outcome),
    g33_r14_identity_result(Mode,Expected,State0,State1,Outcome,Result).

g33_r14_identity_frame(canonical,_{server_id:s1,team_id:t1,channel_id:c1,user_id:u1,
    event:posted,data:_{id:p1,root_id:r1,create_at:100},seq:1}).
g33_r14_identity_frame(restored,_{server_id:s1,team_id:t1,channel_id:c1,user_id:u1,
    event:posted,data:_{id:p1,root_id:r1,create_at:100},seq:1}).
% Deliberately lacks event/data/seq. Unauthorized identity must decide first.
g33_r14_identity_frame(severed,_{server_id:s1,team_id:t1,
    channel_id:foreign_channel,user_id:foreign_user}).

g33_r14_identity_result(Mode,Hash,_State0,State1,Outcome,
    ['mattermost-identity-observation',Mode,Hash,accepted,'miter-surface-event-v1',100]) :-
    memberchk(Mode,[canonical,restored]),Outcome.status==accepted,
    Outcome.event.schema=='miter-surface-event-v1',State1.cursor=:=100,!.
g33_r14_identity_result(severed,Hash,State0,State1,Outcome,
    ['mattermost-identity-observation',severed,Hash,rejected,unauthorized,'body-uninspected']) :-
    Outcome.status==rejected,Outcome.reason==unauthorized,State1==State0,!.

g33_r14_panic_probe(Candidate0,Expected0,Result) :-
    catch((maplist(g33_r14_atom,[Candidate0,Expected0],[Candidate,Expected]),
      Candidate='/Users/claritymiter/miter/evidence/G31/p3-351/candidate/extension/mattermost_bridge.pl',
      crypto_file_hash(Candidate,Expected,[algorithm(sha256),encoding(octet)]),
      load_files(Candidate,[silent(true)]),
      Config=_{server_id:s1,team_id:t1,channel_id:c1,user_id:u1,auth_ref:a1},
      State0=_{cursor:0,seen:[],effects:[],panic:false},
      Effect=_{schema:'miter-surface-effect-v1',id:e1,idempotency_key:k1,
               channel_id:c1,message:'synthetic-not-emitted'},
      miter_mattermost_bridge:surface_effect(Config,State0,Effect,State1,Before),
      Before.status==accepted,
      miter_mattermost_bridge:surface_panic(State1,Panic),
      miter_mattermost_bridge:surface_effect(Config,Panic,Effect,Panic,After),
      After.status==rejected,After.reason==panic_active,
      Result=['mattermost-panic-observation',Expected,'descriptor-only-before-panic',
              'panic-active-rejected','network-zero','effects-zero']),_,
      Result=['mattermost-panic-observation-unavailable']),!.

g33_r14_prior_live_witness(Result) :-
    catch((g33_r14_prior_live_checked(Result0)->true;
           Result0=['prior-live-witness-unavailable','contract-failed']),
          Error,g33_r14_error(Error,Result0)),Result=Result0,!.

g33_r14_prior_live_checked(['prior-live-witness',ClosureHash,2,2,1,0,
    'terminal-panic',false,false,'prior-effect-not-replayed']) :-
    Closure='/Users/claritymiter/miter/docs/gates/G31/P9/R1/closure.json',
    crypto_file_hash(Closure,ClosureHash,[algorithm(sha256),encoding(octet)]),
    ClosureHash='0b02fd42e8f43506f1fb9736b6e4db80761cc1d61f9ec7c61f8e058395edd9c1',
    g33_r14_json(Closure,D),D.status=="PASS-BOUNDED",maplist(g33_r14_evidence_pin,D.evidence),
    Verdict='/Users/claritymiter/miter/evidence/G31/p9-916/run-verdict.json',
    g33_r14_json(Verdict,V),V.status=="PASS-BOUNDED-LIVE-CANARY",
    V.allowlisted_inputs=:=2,V.certified_voice_effects=:=2,V.confirmed_effect_posts=:=2,
    V.restart_count=:=1,V.old_effect_replay_writes=:=0,V.denied_inputs=:=1,
    V.denied_cognition_invocations=:=0,V.denied_response_effects=:=0,
    V.terminal_phase=="terminal-panic",V.active==false,V.network_allowed==false,
    V.history_access==false,V.chroma_access==false,V.prior_memory_access==false.

g33_r14_evidence_pin(E) :-
    atom_string(Rel,E.path),atom_concat('/Users/claritymiter/miter/',Rel,Path),
    crypto_file_hash(Path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,E.sha256).

g33_r14_public_path(Path) :-
    atom(Path),sub_atom(Path,0,_,_,'/Users/claritymiter/miter/evidence/'),
    \+sub_atom(Path,_,_,_,'..'),\+sub_atom(Path,_,_,_,'//'),exists_file(Path),\+read_link(Path,_,_).
g33_r14_json(Path,D) :-
    setup_call_cleanup(open(Path,read,S,[encoding(utf8)]),json_read_dict(S,D),close(S)).
g33_r14_atom(Value,Atom) :-
    (atom(Value)->Atom=Value;string(Value)->atom_string(Atom,Value)),atom_length(Atom,N),N>0.
g33_r14_error(Error,['g33-r14-mechanical-error',Text]) :- message_to_string(Error,Text).
