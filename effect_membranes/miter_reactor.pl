% Files, clocks, ledger append and checkpoint serialization only. Native MeTTa
% owns eligibility, RNA transcription/loci, ready-set choice and quiescence.
:- ensure_loaded('miter_store.pl').
:- use_module(library(pcre)).
:- dynamic miter_reactor_seen/2, miter_reactor_serial/2.
miter_reactor_path(Root,File,P) :- directory_file_path(Root,File,P).
miter_reactor_input(Root,Events) :-
 catch((directory_file_path(Root,inbox,D),directory_files(D,Fs),sort(Fs,Sorted),
  findall([event,Id,Kind,Prov,Ob,Steps],
   (member(F,Sorted),file_name_extension(_,json,F),\+miter_reactor_seen(Root,F),
    directory_file_path(D,F,P),miter_store_read_json(P,Q),
    Q.schema=="miter-reactor-input-v1",atom_string(Id,Q.id),
    re_match('^[a-z][a-z0-9-]{0,63}$',Id),atom_string(Kind,Q.kind),
    atom_string(Prov,Q.provenance),atom_string(Ob,Q.obligation),
    Steps=Q.steps,integer(Steps),Steps>=1,Steps=<32,
    assertz(miter_reactor_seen(Root,F))),Events)),_,Events=[]),!.
miter_reactor_obligation(Root,Id,Result) :-
 catch((directory_file_path(Root,'obligations.json',P),miter_store_read_json(P,D),
  member(O,D.obligations),atom_string(Id,O.id),O.allowed_effect=="internal-hash-checkpoint",
  get_time(Now),O.due_at=<Now->Result='obligation-verified';Result='obligation-missing'),
  _,Result='obligation-missing'),!.
miter_reactor_config(Key,Value) :-
 miter_store_read_json('config/reactor-profile.json',D),D.schema=="miter-reactor-profile-v1",
 get_dict(Key,D,Value),number(Value),Value>0.
miter_reactor_record(Root,Kind,Data,Result) :-
 catch((with_mutex(miter_reactor_serial,
   ((retract(miter_reactor_serial(Root,Old))->true;Old=0),N is Old+1,assertz(miter_reactor_serial(Root,N)))),
  get_time(Now),stamp_date_time(Now,Date,'UTC'),format_time(string(T),'%FT%TZ',Date),
  format(string(Id),'reactor-~w-~d',[Kind,N]),
  D=_{schema:"miter-event-intent-v1",event_id:Id,event_kind:Kind,
    occurred_at:T,recorded_at:T,source_surface:"native-reactor",source_principal:"miter:reactor",
    audience_scope:"scope:reactor-local",project_scope:"reactor-fixture",
    provenance_kind:"native-control",parent_event_ids:[],correlation_id:"reactor",
    payload:_{data:Data,wall_time:Now}},
  format(atom(F),'intents/~d.json',[N]),directory_file_path(Root,F,P),
  miter_store_write_json_atomic(P,D),directory_file_path(Root,store,S),
  miter_store_append_event(S,'runtime/g07/libmiter_store_posix.dylib',P,R),R=='event-appended',
  directory_file_path(Root,'trace.jsonl',Trace),
  setup_call_cleanup(open(Trace,append,Out),
   (json_write_dict(Out,_{kind:Kind,data:Data,wall_time:Now},[width(0)]),nl(Out)),close(Out))
  ->Result='reactor-recorded';Result='reactor-store-failed'),_,Result='reactor-store-failed'),!.
miter_reactor_checkpoint(Root,Id,Species,Locus,Budget,Status,Result) :-
 catch((D=_{rna_id:Id,species:Species,source_event:Id,current_locus:Locus,
    scope:"scope:reactor-local",budget:Budget,provenance:"verified-local-ingress",
    dependencies:[],authority:"internal-hash-checkpoint-only",status:Status,
    termination_condition:"finite-step-budget-or-human-stop"},
   format(atom(F),'rna/~w.json',[Id]),directory_file_path(Root,F,P),
   miter_store_write_json_atomic(P,D),
   miter_reactor_record(Root,'RNA-state',D,Result)),_,Result='reactor-store-failed'),!.
miter_reactor_step(Root,Id,Result) :-
 catch((directory_file_path(Root,'fixture-work-profile.json',WP),
  (exists_file(WP)->miter_store_read_json(WP,W),number(W.step_delay_seconds),
    W.step_delay_seconds>=0,W.step_delay_seconds=<0.25,sleep(W.step_delay_seconds);true),
  directory_file_path(Root,'store/trajectory.jsonl',P),
  crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)]),
  miter_reactor_record(Root,'step-witness',[Id,H],R),R=='reactor-recorded'
  ->Result='step-witnessed';Result='step-failed'),_,Result='step-failed'),!.
miter_reactor_wait(Root,Seconds,Result) :-
 number(Seconds),Seconds>0,Seconds=<1,get_time(T),End is T+Seconds,
 miter_reactor_wait_until(Root,End,Result).
miter_reactor_wait_until(Root,End,Result) :-
 directory_file_path(Root,inbox,D),directory_files(D,Fs),
 (member(F,Fs),file_name_extension(_,json,F),\+miter_reactor_seen(Root,F)
  ->Result='input-ready'
 ;get_time(T),(T>=End->Result='idle-timeout';sleep(0.01),miter_reactor_wait_until(Root,End,Result))).
