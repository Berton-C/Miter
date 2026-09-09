% Mechanical lexical-association membrane for the private NRC VAD asset.
% It verifies source/asset identity, tokenizes, performs longest exact matching,
% and returns bounded clause aggregates.  It does not infer a person's state,
% classify SNS/PNS, select a presence style, form movement, or authorize action.

:- ensure_loaded('store.pl').
:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- use_module(library(pcre)).
:- use_module(library(readutil)).

:- dynamic vad_lex/4, vad_loaded/1.

as_vad(Root0,Descriptor,Observation) :-
    ( catch(as_vad_checked(Root0,Descriptor,Observation0),Error,
        vad_unavailable(Descriptor,Error,Observation0)) -> true
    ; vad_unavailable(Descriptor,'vad-unavailable',Observation0) ),
    Observation=Observation0, !.

as_vad_checked(Root0,Descriptor,Observation) :-
    vad_root(Root0,Root),
    vad_descriptor(Descriptor,CueId,Scope,ContactId,TextHash,Text,
      Version,ExpectedAssetHash,MaximumText,MaximumClauses,MaximumTokens,
      MaximumNgram),
    directory_file_path(Root,'vad.json',ConfigPath),
    miter_store_read_json(ConfigPath,Config),
    vad_config(Config,Version,ExpectedAssetHash,AssetPath,MaximumText,
      MaximumClauses,MaximumTokens,MaximumNgram),
    exists_file(AssetPath),\+ read_link(AssetPath,_,_),
    crypto_file_hash(AssetPath,ObservedAssetHash,
      [algorithm(sha256),encoding(octet)]),
    ObservedAssetHash==ExpectedAssetHash,
    vad_load_asset(AssetPath,ExpectedAssetHash),
    vad_tokens(Text,Tokens),length(Tokens,ScannedTokenCount),
    ScannedTokenCount=<MaximumTokens,
    vad_clauses(Tokens,Clauses),Clauses=[_|_],
    length(Clauses,ClauseCount),ClauseCount=<MaximumClauses,
    vad_measure_clauses(Clauses,MaximumNgram,0,Rows),
    vad_totals(Rows,TotalTokens,CoveredTokens,MatchedExpressions),
    Observation=['vad-mechanical-observation-v1',CueId,Scope,
      ['source-contact',ContactId,['text-sha256',TextHash]],
      [asset,Version,ExpectedAssetHash,'private-read-only-checksum-verified'],
      [clauses,Rows],
      [coverage,['token-count',TotalTokens],
        ['covered-token-count',CoveredTokens],
        ['matched-expression-count',MatchedExpressions]],
      [limitations,'lexical-association-only','no-person-state-claim',
        'no-sns-pns-classification','no-permission-effect',
        'exact-matching-only','negation-irony-and-context-unresolved'],
      'mechanical-cue-no-meaning-movement-or-effect-authority'].

vad_descriptor(Descriptor,
    CueId,Scope,ContactId,TextHash,Text,Version,ExpectedAssetHash,
    MaximumText,MaximumClauses,MaximumTokens,MaximumNgram) :-
    Descriptor=['vad-language-request-v1',CueId0,Scope,
      ['source-contact',ContactId0],
      ['exact-contact-text',TextHash0,Text],
      [asset,Version0,ExpectedAssetHash0],
      [limits,['maximum-text-characters',MaximumText],
        ['maximum-clauses',MaximumClauses],
        ['maximum-tokens',MaximumTokens],
        ['maximum-ngram-tokens',MaximumNgram]],
      'lexical-cue-request-no-person-state-or-movement-authority'],
    vad_symbol(CueId0,CueId),vad_scope(Scope),
    vad_symbol(ContactId0,ContactId),vad_sha256(TextHash0,TextHash),
    string(Text),string_length(Text,TextLength),TextLength>=1,
    integer(MaximumText),TextLength=<MaximumText,MaximumText=:=32768,
    integer(MaximumClauses),MaximumClauses=:=32,
    integer(MaximumTokens),MaximumTokens=:=4096,
    integer(MaximumNgram),MaximumNgram=:=3,
    vad_symbol(Version0,Version),Version=='NRC-VAD-2.1',
    vad_sha256(ExpectedAssetHash0,ExpectedAssetHash),
    crypto_data_hash(Text,ObservedTextHash,
      [algorithm(sha256),encoding(utf8)]),
    ObservedTextHash==TextHash,
    vad_native_id('c4-vad-cue',
      ['vad-language-cue-v1',ContactId,TextHash,ExpectedAssetHash],CueId),
    ground(Scope),ground(Descriptor),acyclic_term(Descriptor).

vad_config(Config,Version,ExpectedAssetHash,AssetPath,MaximumText,
    MaximumClauses,MaximumTokens,MaximumNgram) :-
    is_dict(Config),Config.schema=="miter-vad-language-cue-config-v1",
    Config.enabled==true,Config.human_editable==true,
    Config.matching=="longest-exact-only",
    Asset=Config.asset,is_dict(Asset),
    atom_string(Version,Asset.version),atom_string(ExpectedAssetHash,Asset.sha256),
    Asset.source=="private-runtime-file",
    Asset.redistribution==
      "prohibited-no-lexicon-rows-in-public-repository",
    atom_string(AssetPath,Asset.path),is_absolute_file_name(AssetPath),
    Limits=Config.limits,is_dict(Limits),
    MaximumText=Limits.maximum_text_characters,
    MaximumClauses=Limits.maximum_clauses,
    MaximumTokens=Limits.maximum_tokens,
    MaximumNgram=Limits.maximum_ngram_tokens.

vad_load_asset(_Path,Hash) :- vad_loaded(Hash), !.
vad_load_asset(Path,Hash) :-
    retractall(vad_lex(_,_,_,_)),retractall(vad_loaded(_)),
    setup_call_cleanup(open(Path,read,Stream,[encoding(utf8)]),
      (read_line_to_string(Stream,"term\tvalence\tarousal\tdominance"),
       vad_load_rows(Stream)),close(Stream)),
    assertz(vad_loaded(Hash)).

vad_load_rows(Stream) :-
    read_line_to_string(Stream,Line),
    ( Line==end_of_file -> true
    ; split_string(Line,"\t","\r",[TermString,VString,AString,DString]),
      string_lower(TermString,Lower),atom_string(Term,Lower),
      maplist(number_string,[V,A,D],[VString,AString,DString]),
      maplist(vad_axis,[V,A,D]),\+ vad_lex(Term,_,_,_),
      assertz(vad_lex(Term,V,A,D)),vad_load_rows(Stream) ).

vad_axis(Value) :- number(Value),Value>= -1,Value=<1.

vad_tokens(Text,Tokens) :-
    string_lower(Text,Lower),
    re_foldl(vad_collect_token,"[\\p{L}\\p{N}'’-]+|[.!?;,]",
      Lower,[],Reversed,[]),reverse(Reversed,Tokens).

vad_collect_token(Match,In,[Token|In]) :-
    get_dict(0,Match,String),atom_string(Token,String).

vad_clauses(Tokens,Clauses) :- vad_clauses(Tokens,[],[],Clauses).
vad_clauses([],Current,Acc,Clauses) :-
    reverse(Current,Clause),vad_add_clause(Clause,Acc,Clauses).
vad_clauses([Token|Rest],Current,Acc,Clauses) :-
    ( memberchk(Token,['.','!','?',';',',']) ->
        reverse(Current,Clause),vad_add_clause(Clause,Acc,Next),
        vad_clauses(Rest,[],Next,Clauses)
    ; memberchk(Token,[but,however,although,though,yet]) ->
        reverse(Current,Clause),vad_add_clause(Clause,Acc,Next),
        vad_clauses(Rest,[Token],Next,Clauses)
    ; vad_clauses(Rest,[Token|Current],Acc,Clauses) ).

vad_add_clause([],Clauses,Clauses).
vad_add_clause(Clause,Clauses,Out) :- Clause=[_|_],append(Clauses,[Clause],Out).

vad_measure_clauses([],_,_,[]).
vad_measure_clauses([Clause|Rest],MaximumNgram,Index,
    [['vad-clause-measure-v1',Index,['token-count',TokenCount],
      ['covered-token-count',Covered],['matched-expression-count',MatchCount],
      ['axis-sums',Valence,Arousal,Dominance]]|Rows]) :-
    length(Clause,TokenCount),
    vad_scan_clause(Clause,MaximumNgram,Matches),
    vad_match_totals(Matches,Covered,MatchCount,Valence,Arousal,Dominance),
    Next is Index+1,vad_measure_clauses(Rest,MaximumNgram,Next,Rows).

vad_scan_clause([],_,[]).
vad_scan_clause(Tokens,MaximumNgram,
    [match(Width,V,A,D)|Matches]) :-
    vad_longest_exact(Tokens,MaximumNgram,Width,V,A,D,Remaining),!,
    vad_scan_clause(Remaining,MaximumNgram,Matches).
vad_scan_clause([_|Rest],MaximumNgram,Matches) :-
    vad_scan_clause(Rest,MaximumNgram,Matches).

vad_longest_exact(Tokens,MaximumNgram,Width,V,A,D,Remaining) :-
    length(Tokens,Available),Upper is min(Available,MaximumNgram),
    between(1,Upper,Offset),Width is Upper-Offset+1,
    length(Prefix,Width),append(Prefix,Remaining,Tokens),
    atomic_list_concat(Prefix,' ',Term),vad_lex(Term,V,A,D),!.

vad_match_totals(Matches,Covered,Count,V,A,D) :-
    length(Matches,Count),
    foldl(vad_add_match,Matches,totals(0,0.0,0.0,0.0),
      totals(Covered,V,A,D)).

vad_add_match(match(Width,V,A,D),totals(C0,V0,A0,D0),
    totals(C1,V1,A1,D1)) :-
    C1 is C0+Width,V1 is V0+V,A1 is A0+A,D1 is D0+D.

vad_totals([],0,0,0).
vad_totals([['vad-clause-measure-v1',_,['token-count',Tokens],
      ['covered-token-count',Covered],['matched-expression-count',Matches],_]
      |Rest],TotalTokens,TotalCovered,TotalMatches) :-
    vad_totals(Rest,T0,C0,M0),
    TotalTokens is T0+Tokens,TotalCovered is C0+Covered,
    TotalMatches is M0+Matches.

vad_unavailable(Descriptor,Error,
    ['vad-observation-unavailable-v1',CueId,Reason,'no-cue-admitted']) :-
    ( Descriptor=['vad-language-request-v1',CueId0|_],
      vad_symbol(CueId0,CueId) -> true ; CueId='unknown-cue' ),
    functor(Error,Functor,_),
    ( vad_symbol(Functor,Reason) -> true ; Reason='vad-mechanical-boundary' ).

vad_root(Value,Root) :-
    miter_store_nonempty_atom(Value,Root),is_absolute_file_name(Root),
    exists_directory(Root),\+ read_link(Root,_,_).

vad_scope(['scope',Principal,Audience,Project]) :-
    maplist(vad_symbol,[Principal,Audience,Project],_).

vad_symbol(Value,Atom) :-
    miter_store_nonempty_atom(Value,Atom),
    re_match('^[A-Za-z][A-Za-z0-9_.:-]{0,127}$',Atom).

vad_sha256(Value,Atom) :-
    miter_store_nonempty_atom(Value,Atom),atom_length(Atom,64),
    atom_codes(Atom,Codes),maplist(miter_store_hex_code,Codes).

vad_native_id(Prefix,Term,Id) :-
    ground(Term),acyclic_term(Term),
    term_string(Term,Text,[quoted(true),ignore_ops(true)]),
    crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]),
    atomic_list_concat([Prefix,Hash],'-',Id).
