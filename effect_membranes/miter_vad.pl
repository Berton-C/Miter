% Local licensed-asset mechanics: checksum, tokenization, longest exact lookup,
% optional morphology after exact miss, and diagnostic serialization.
% Native src/vad.metta owns aggregation, interpretation, routing and limits.
% No lexicon rows/scores are written; in-process scalar getters are not an API.
:- ensure_loaded('miter_store.pl').
:- use_module(library(pcre)).
:- dynamic miter_vad_lex/4, miter_vad_loaded/1, miter_vad_clause/4,
           miter_vad_match/10, miter_vad_session/3.
miter_vad_prepare(Path,Separators0,Excluded0,Mode,Result) :-
 miter_vad_prepare_source(Path,Separators0,Excluded0,Mode,'direct-contact',Result).
miter_vad_prepare_source(Path,Separators0,Excluded0,Mode,Expected,Result) :-
 catch((miter_store_read_json(Path,Q),string_length(Q.text,N),N=<4096,
        miter_store_read_json('config/vad-profile.json',Profile),
        forall(member(Key,[coverage_prior,trajectory_delta_prior,register_band_prior]),
          (get_dict(Key,Profile,Prior),number(Prior),Prior>=0,Prior=<1)),
        miter_vad_source(Q,Expected),
        maplist(miter_store_nonempty_atom,Separators0,Separators),
        maplist(miter_store_nonempty_atom,Excluded0,Excluded),
        memberchk(Mode,[exact_then_morphology,exact_only,lexicon_off]),
        (Mode==lexicon_off -> true; miter_vad_load_asset),
        miter_vad_tokens(Q.text,Tokens),
        miter_vad_split(Tokens,Separators,[],[],Clauses),
        Clauses=[_|_],length(Clauses,Count),Count=<32,
        miter_store_nonempty_atom(Q.cue_id,Id),
        retractall(miter_vad_clause(Id,_,_,_)),
        retractall(miter_vad_match(Id,_,_,_,_,_,_,_,_,_)),
        retractall(miter_vad_session(Id,_,_)),
        miter_vad_index_clauses(Clauses,Id,0,Excluded,Mode),
        miter_store_nonempty_atom(Expected,ExpectedAtom),atom_string(ExpectedAtom,Provenance),
        Observed=Q.put(source_provenance,Provenance),
        assertz(miter_vad_session(Id,Observed,Tokens))
        -> Result='vad-lookup-ready'; Result='vad-lookup-error'),
       _,Result='vad-lookup-error'),!.
miter_vad_source(Q,Expected) :-
 miter_store_load_ledger(Q.store_root,Lines),
 miter_store_analyze(Q.store_root,Lines,A,Events),A.status==valid,
 member(E,Events), E.event_id==Q.source_event_id,
 miter_store_nonempty_atom(Expected,Kind),atom_string(Kind,E.provenance_kind),
 miter_store_payload_path(Q.store_root,E.payload_hash,Path),
 miter_store_read_json(Path,P),P.text==Q.text.
miter_vad_load_asset :-
 miter_store_read_json('config/local/vad-asset.json',Local),
 miter_store_read_json('config/vad-profile.json',Profile),
 crypto_file_hash(Local.path,Hash,[algorithm(sha256),encoding(octet)]),
 atom_string(Hash,Profile.asset_sha256),
 (miter_vad_loaded(Hash) -> true
 ; retractall(miter_vad_lex(_,_,_,_)),retractall(miter_vad_loaded(_)),
   setup_call_cleanup(open(Local.path,read,S,[encoding(utf8)]),
      (read_line_to_string(S,"term\tvalence\tarousal\tdominance"),miter_vad_rows(S)),close(S)),
   assertz(miter_vad_loaded(Hash))).
miter_vad_rows(S) :-
 read_line_to_string(S,Line),
 (Line==end_of_file -> true
 ; split_string(Line,"\t","\r",[Term,VS,AS,DS]),
   maplist(number_string,[V,A,D],[VS,AS,DS]),
   forall(member(X,[V,A,D]),(X>= -1,X=<1)),
   atom_string(T,Term), \+ miter_vad_lex(T,_,_,_),
   assertz(miter_vad_lex(T,V,A,D)),miter_vad_rows(S)).
miter_vad_tokens(Text,Tokens) :-
 string_lower(Text,Lower),
 re_foldl(miter_vad_collect,"[^\\s,;.!?]+|[,;.!?]",Lower,[],Rev,[]),
 reverse(Rev,Tokens).
miter_vad_collect(M,In,[T|In]) :- get_dict(0,M,S),atom_string(T,S).
miter_vad_split([],_,Current,Acc,Out) :-
 reverse(Current,C),(C==[]->Out=Acc;append(Acc,[C],Out)).
miter_vad_split([T|Ts],Seps,Current,Acc,Out) :-
 ( (memberchk(T,Seps);memberchk(T,[',',';','.','!','?'])) ->
   reverse(Current,C),(C==[]->Next=Acc;append(Acc,[C],Next)),
   miter_vad_split(Ts,Seps,[],Next,Out)
 ; miter_vad_split(Ts,Seps,[T|Current],Acc,Out)).
miter_vad_index_clauses([],_,_,_,_).
miter_vad_index_clauses([C|Cs],Id,I,Excluded,Mode) :-
 miter_vad_scan(C,Excluded,Mode,Matches,Unknown),
 assertz(miter_vad_clause(Id,I,C,Unknown)),
 forall(nth0(J,Matches,m(T,V,A,D,N,Method)),
   (crypto_data_hash(T,H,[algorithm(sha256),encoding(utf8)]),
    assertz(miter_vad_match(Id,I,J,T,V,A,D,N,H,Method)))),
 Next is I+1,miter_vad_index_clauses(Cs,Id,Next,Excluded,Mode).
miter_vad_scan([],_,_,[],[]).
miter_vad_scan([T|Ts],Excluded,Mode,Ms,Unknown) :-
 (Mode\==lexicon_off,\+memberchk(T,Excluded),
  miter_vad_longest([T|Ts],Excluded,Term,V,A,D,N,Rest) ->
    Ms=[m(Term,V,A,D,N,exact)|More], Unknown=U
 ; Mode==exact_then_morphology,\+memberchk(T,Excluded),
   miter_vad_morph(T,Term),miter_vad_lex(Term,V,A,D) ->
    Ms=[m(Term,V,A,D,1,morphology)|More],Unknown=U,Rest=Ts
 ; Ms=More,Unknown=[T|U],Rest=Ts),
 miter_vad_scan(Rest,Excluded,Mode,More,U).
miter_vad_longest(Tokens,Excluded,Term,V,A,D,N,Rest) :-
 length(Tokens,L),between(1,L,K),N is L-K+1,
 length(Prefix,N),append(Prefix,Rest,Tokens),
 \+ (member(T,Prefix),memberchk(T,Excluded)),
 atomic_list_concat(Prefix,' ',Term),miter_vad_lex(Term,V,A,D),!.
miter_vad_morph(T,Stem) :-
 member(Suffix,[ing,ed,s]),atom_concat(Base,Suffix,T),atom_length(Base,N),N>=3,
 (Stem=Base;atom_concat(Base,e,Stem)),miter_vad_lex(Stem,_,_,_),!.
miter_vad_metric(Id0,Clause,Key,Value) :-
 catch((miter_store_nonempty_atom(Id0,Id),
        miter_vad_metric_(Id,Clause,Key,V)->Value=V;Value= -1),_,Value= -1),!.
miter_vad_metric_(Id,_,clause_count,V) :- findall(I,miter_vad_clause(Id,I,_,_),Is),length(Is,V),V>0.
miter_vad_metric_(Id,I,token_count,V) :- miter_vad_clause(Id,I,Ts,_),length(Ts,V).
miter_vad_metric_(Id,I,match_count,V) :- miter_vad_clause(Id,I,_,_),findall(J,miter_vad_match(Id,I,J,_,_,_,_,_,_,_),Js),length(Js,V).
miter_vad_metric_(Id,I,covered_tokens,V) :- miter_vad_clause(Id,I,_,_),findall(N,miter_vad_match(Id,I,_,_,_,_,_,N,_,_),Ns),sum_list(Ns,V).
miter_vad_prior(Key,Value) :-
 catch((miter_store_read_json('config/vad-profile.json',P),
        get_dict(Key,P,V),number(V),V>=0,V=<1->Value=V;Value=invalid_vad_prior),
       _,Value=invalid_vad_prior),!.
miter_vad_number(Id0,I,J,Axis,Value) :-
 catch((miter_store_nonempty_atom(Id0,Id),
        miter_vad_match(Id,I,J,_,V,A,D,_,_,_),
        nth0(Axis,[V,A,D],Number)->Value=Number;Value=missing_lexical_value),
       _,Value=missing_lexical_value),!.
miter_vad_contains(Id0,Phrase0,Value) :-
 catch((miter_store_nonempty_atom(Id0,Id),
        miter_vad_session(Id,_,Tokens),miter_vad_tokens(Phrase0,Phrase),
        append(_,Tail,Tokens),append(Phrase,_,Tail)->Value=true;Value=false),_,Value=false),!.
miter_vad_clause_contains(Id0,I,Phrase0,Value) :-
 catch((miter_store_nonempty_atom(Id0,Id),miter_vad_clause(Id,I,Tokens,_),
        miter_vad_tokens(Phrase0,Phrase),
        append(_,Tail,Tokens),append(Phrase,_,Tail)->Value=true;Value=false),_,Value=false),!.
miter_vad_finish(Id0,Product,Path,Result) :-
 catch((miter_store_nonempty_atom(Id0,Id),
        miter_vad_session(Id,Q,_),
        Product=['affect-cue'|Fields],maplist(miter_vad_pair,Fields,Pairs),
        dict_create(Native,cue,Pairs),
        findall(H,miter_vad_match(Id,_,_,_,_,_,_,_,H,_),Hs),sort(Hs,Hashes),
        findall(T,(miter_vad_clause(Id,_,_,U),member(T,U)),Unknown),
        findall(Method,miter_vad_match(Id,_,_,_,_,_,_,_,_,Method),Methods),
        include(==(morphology),Methods,Morphs),length(Morphs,MorphCount),
        findall(Width,miter_vad_match(Id,_,_,_,_,_,_,Width,_,exact),Widths),
        include(miter_vad_multi,Widths,MWEs),length(MWEs,MWECount),
        D=Native.put(_{cue_id:Q.cue_id,source_event_id:Q.source_event_id,source_provenance:Q.source_provenance,
           text:Q.text,matched_term_ids:Hashes,unknown_terms:Unknown,
           morphology_matches:MorphCount,multiword_matches:MWECount,
           asset_version:"NRC-VAD-2.1",asset_sha256:"42c718817fc91d5c133581b24b0bb31d2b14a0b16edb19bc6ce6ab70343e5a45"}),
        \+exists_file(Path),miter_store_write_json_atomic(Path,D)
        ->Result='affect-cue-stored';Result='affect-cue-error'),
       _,Result='affect-cue-error'),!.
miter_vad_multi(N) :- N>1.
miter_vad_pair([Name,Value],Name-Value) :- atom(Name),ground(Value).
