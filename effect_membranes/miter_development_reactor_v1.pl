% G33 R10 mechanics only. Typed JSON ingress, canonical hashing, write-once
% native-product persistence and RNA checkpoint persistence. MeTTa owns every
% audit, opportunity, undertaking, lifecycle disposition and effect decision.
:- ensure_loaded('miter_reactor.pl').
:- use_module(library(pcre)).

dr_root(Root0,Root) :-
 miter_store_nonempty_atom(Root0,Root),
 \+sub_atom(Root,_,_,_,'..'),
 \+sub_atom(Root,_,_,_,'//'),
 dr_qualified_root_prefix(Prefix),
 sub_atom(Root,0,_,_,Prefix),
 atom_length(Root,RootLength),atom_length(Prefix,PrefixLength),
 RootLength>PrefixLength,!.
dr_qualified_root_prefix('/Users/claritymiter/miter/evidence/G33/').
dr_qualified_root_prefix('/Users/claritymiter/miter/runtime/').
dr_path(Root0,Relative,Path) :-
 dr_root(Root0,Root),atom(Relative),\+sub_atom(Relative,_,_,_,'..'),
 \+sub_atom(Relative,0,_,_,'/'),directory_file_path(Root,Relative,Path).
dr_decode(X,Y) :-
 (string(X)->atom_string(Y,X)
 ;is_list(X)->maplist(dr_decode,X,Y)
 ;is_dict(X)->dict_pairs(X,T,Pairs),maplist(dr_pair,Pairs,Decoded),dict_pairs(Y,T,Decoded)
 ;Y=X).
dr_pair(K-X,K-Y) :- dr_decode(X,Y).
dr_hash(Value,Hash) :-
 miter_store_canonical_json(Value,Text),
 crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]).
dr_exact_keys(Dict,Keys) :- dict_pairs(Dict,_,Pairs),pairs_keys(Pairs,Keys).
dr_bounded_string(Value,Atom) :-
 miter_store_nonempty_atom(Value,Atom),atom_length(Atom,N),N=<256.
dr_contact(Dict,['raw-contact',Id,Kind,Frame,Clauses]) :-
 dr_exact_keys(Dict,[clauses,contact_id,frame,source_kind]),
 dr_bounded_string(Dict.contact_id,Id),
 re_match('^[a-z][a-z0-9-]{0,63}$',Id),
 dr_bounded_string(Dict.source_kind,Kind),
 is_list(Dict.frame),is_list(Dict.clauses),length(Dict.clauses,N),N>0,N=<64,
 maplist(string,Dict.clauses),dr_decode(Dict.frame,Frame),dr_decode(Dict.clauses,Clauses).

dr_contact_set(Root,Result) :-
 catch((dr_path(Root,'development-contact.json',Path),
   (exists_file(Path)->miter_store_read_json(Path,D);throw(error(contact_unavailable,Path))),
   dr_exact_keys(D,[contacts,grant,schema,scope,surfaces,undertaking_id]),
   D.schema=="miter-development-contact-set-v1",
   dr_bounded_string(D.undertaking_id,Id),re_match('^[a-z][a-z0-9-]{0,63}$',Id),
   is_list(D.scope),is_list(D.contacts),length(D.contacts,Count),Count>0,Count=<16,
   is_list(D.surfaces),length(D.surfaces,SurfaceCount),SurfaceCount=<16,
   maplist(dr_contact,D.contacts,Contacts),
   dr_decode(D.scope,Scope),dr_decode(D.surfaces,Surfaces),dr_decode(D.grant,Grant),
   dr_hash(D,Fingerprint),
   Result=['development-contact-set',Id,Scope,Contacts,Surfaces,Grant,Fingerprint]),
  Error,dr_contact_error(Error,Result)),!.
dr_contact_error(error(contact_unavailable,_),no-development-contact) :- !.
dr_contact_error(_,malformed-development-contact).

dr_native_document(Schema,Native,_{schema:Schema,native:Native}).
dr_same_document(Path,Document) :-
 miter_store_read_json(Path,Old),
 miter_store_canonical_json(Old,Text),miter_store_canonical_json(Document,Text).
dr_once(Path,Document) :-
 (exists_file(Path)->dr_same_document(Path,Document);miter_store_write_json_atomic(Path,Document)).
dr_development_path(Root,Id,Name,Path) :-
 dr_root(Root,_),atom(Id),re_match('^[a-z][a-z0-9-]{0,63}$',Id),
 atom(Name),\+sub_atom(Name,_,_,_,'/'),\+sub_atom(Name,_,_,_,'..'),
 atomic_list_concat(['development',Id,Name], '/', Relative),dr_path(Root,Relative,Path).

dr_store_turn(Root,Id,Bundle,Observation,Step,Result) :-
 catch((Step=['cycle-step',State,Effects,Reason],ground(Step),is_list(Effects),
   dr_development_path(Root,Id,'contact.json',ContactPath),
   dr_development_path(Root,Id,'observation.json',ObservationPath),
   dr_development_path(Root,Id,'cycle-step.json',StepPath),
   dr_development_path(Root,Id,'state.json',StatePath),
   dr_development_path(Root,Id,'effect-request.json',EffectPath),
   dr_native_document("miter-development-contact-native-v1",Bundle,ContactDoc),
   dr_native_document("miter-development-observation-native-v1",Observation,ObservationDoc),
   dr_native_document("miter-development-cycle-step-native-v1",Step,StepDoc),
   dr_native_document("miter-development-state-native-v1",State,StateDoc),
   dr_native_document("miter-development-effect-request-native-v1",
     ['unapplied-effects',Effects,'authority-awaiting-separate-authorization'],EffectDoc),
   maplist(call,[dr_once(ContactPath,ContactDoc),dr_once(ObservationPath,ObservationDoc),
     dr_once(StepPath,StepDoc),dr_once(StatePath,StateDoc),dr_once(EffectPath,EffectDoc)]),
   dr_hash(Step,StepHash),
   miter_reactor_record(Root,'development-orientation',
     [Id,Reason,['cycle-step-sha256',StepHash]],Recorded),
   Recorded=='reactor-recorded'->Result='development-turn-stored';Result='development-turn-storage-failed'),
  _,Result='development-turn-storage-failed'),!.

dr_state(Root,Id,State) :-
 catch((dr_development_path(Root,Id,'state.json',Path),exists_file(Path),
   miter_store_read_json(Path,D),D.schema=="miter-development-state-native-v1",
   dr_decode(D.native,State)),_,fail),!.
dr_state(_,_,none).
dr_rna_status(Root,Id,Status) :-
 catch((dr_development_path(Root,Id,'rna.json',Path),exists_file(Path),
   miter_store_read_json(Path,D),D.schema=="miter-development-rna-checkpoint-v1",
   dr_decode(D.status,Status)),_,fail),!.
dr_rna_status(_,_,no-rna-checkpoint).
dr_rna_checkpoint(Root,Id,Status,State,Result) :-
 catch((ground(State),memberchk(Status,[ready,'awaiting-authorized-generation']),
   dr_development_path(Root,Id,'rna.json',Path),
   dr_native_document("miter-development-rna-checkpoint-v1",State,Base),
   put_dict(_{rna_id:Id,species:"SourceGroundedDevelopRNA",status:Status,
     authority:"no-effect-executed",termination_condition:"authorized-generation-or-revalidation"},
     Base,Document),
   miter_store_write_json_atomic(Path,Document),dr_hash(State,StateHash),
   miter_reactor_record(Root,'development-rna-state',
     [Id,Status,['state-sha256',StateHash]],Recorded),
   Recorded=='reactor-recorded'->Result='development-rna-checkpoint-stored';Result='development-rna-checkpoint-failed'),
  _,Result='development-rna-checkpoint-failed'),!.
