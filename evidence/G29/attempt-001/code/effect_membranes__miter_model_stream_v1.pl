% Bounded HTTP capture only. This membrane returns observations, not decisions.
:- use_module(library(http/http_open)).
:- use_module(library(http/http_json)).
:- use_module(library(readutil)).
:- use_module(library(time)).
:- use_module(library(utf8)).

% The caller owns path/grant validation. Exclusive creation prevents reuse of a
% prepared call. Keep received bytes even if cancellation interrupts a line.
ms_capture(Prepared, Wire, Header, Seconds, MaxBytes, Record) :-
 rv_json(Prepared,P),get_time(Start),State=state(0,0,none),
 miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
 catch((setup_call_cleanup(open(Wire,write,Out,[type(binary),if_exists(error)]),
   (chmod(Wire,0o600),
    catch(call_with_time_limit(Seconds,
      setup_call_cleanup(http_open(P.endpoint,In,[method(post),post(json(P.body)),status_code(Status),
        timeout(Seconds),redirect(false),request_header('Accept'='text/event-stream')]),
       (nb_setarg(1,State,Status),tv_durable_json(Header,_{http_status:Status,started_at:Start}),
        set_stream(In,encoding(octet)),
        (ms_copy(In,Out,MaxBytes,0,[],State)->true;nb_setarg(3,State,copy_failed))),
       ignore(catch(close(In),CloseError,nb_setarg(3,State,CloseError))))),E,nb_setarg(3,State,E))),
   (flush_output(Out),miter_store_fsync_stream(Out),close(Out)))->true;
   (var(Thrown)->Thrown=transport_goal_failed;true)),Outer,(var(Thrown)->Thrown=Outer;true)),
 get_time(End),Elapsed is round((End-Start)*1000),
 arg(3,State,Caught),
 % Some HTTP stream reads fail at their timeout instead of throwing. Preserve
 % that distinction in error; classify deadline exhaustion only with elapsed
 % time evidence, never from a generic read failure alone.
 (Caught==copy_failed,Elapsed>=Seconds*1000->Transport=timeout,Error="stream_read_failed_at_deadline";
  Caught\==none->ms_error(Caught,Transport),term_string(Caught,Error);
  var(Thrown)->Transport=eof,Error="none";ms_error(Thrown,Transport),term_string(Thrown,Error)),
 arg(1,State,Http),arg(2,State,Count),
 (exists_file(Wire)->crypto_file_hash(Wire,Hash,[algorithm(sha256),encoding(octet)]);Hash=unavailable),
 Record=_{transport:Transport,error:Error,http_status:Http,elapsed_ms:Elapsed,bytes:Count,wire_sha256:Hash}.
ms_copy(In,Out,Limit,N,Line,State) :-
 (N>=Limit->throw(capture_limit);get_byte(In,B),
  (B=:= -1->true;
   put_byte(Out,B),N1 is N+1,nb_setarg(2,State,N1),
   (B=:=10->flush_output(Out),miter_store_fsync_stream(Out),reverse(Line,Codes),
     (Codes=[100,97,116,97,58,32,91,68,79,78,69,93]->true;ms_copy(In,Out,Limit,N1,[],State))
    ;ms_copy(In,Out,Limit,N1,[B|Line],State)))).
ms_error(time_limit_exceeded,timeout) :- !.
ms_error(error(timeout_error(_,_),_),timeout) :- !.
ms_error(capture_limit,capture_limit) :- !.
ms_error(_,transport_error).

% Parse only complete SSE lines from the captured wire. An unfinished line stays
% in the wire artifact but is never repaired or guessed. Malformed data lines
% prevent a seemingly complete product from becoming eligible in native code.
ms_decode(Wire,Done,Finish,Parse,Content,Files,Usage) :-
 read_file_to_codes(Wire,Bytes,[type(binary)]),
 ms_lines(Bytes,Lines),ms_events(Lines,Events,Bad),
 (member(done,Events)->Done=true;Done=false),
 findall(S,(member(J,Events),is_dict(J),get_dict(choices,J,Choices),member(C,Choices),
   get_dict(delta,C,D),get_dict(content,D,S),string(S)),Parts),atomics_to_string(Parts,Content),
 findall(F,(member(J,Events),is_dict(J),get_dict(choices,J,Cs),member(C,Cs),get_dict(finish_reason,C,F),string(F)),Finishes),
 (Finishes=[]->Finish=unknown;last(Finishes,FS),atom_string(Finish,FS)),
 findall(U,(member(J,Events),is_dict(J),get_dict(usage,J,U),is_dict(U)),Usage),
 (Bad==true->Parse='malformed-stream',Files=[];
  catch(atom_json_dict(Content,Product,[]),_,fail)->
   (ms_files(Product,Files)->Parse='artifact-shaped';Parse='schema-mismatch',Files=[])
   ;Parse='malformed-artifact',Files=[]).
ms_lines(Bytes,Lines) :-
 (append(Line,[10|Rest],Bytes)->Lines=[Line|More],ms_lines(Rest,More);Lines=[]).
ms_events([],[],false).
ms_events([Line|Rest],Events,Bad) :-
 ms_events(Rest,Tail,TBad),
 (append([100,97,116,97,58],Data,Line)->
   (phrase(utf8_codes(Codes),Data),string_codes(S0,Codes),normalize_space(string(S),S0),
    (S=="[DONE]"->Event=done;catch(atom_json_dict(S0,Event,[]),_,fail))
    ->Events=[Event|Tail],Bad=TBad;Events=Tail,Bad=true)
  ;Events=Tail,Bad=TBad).
ms_files(D,Files) :- is_dict(D),dict_pairs(D,_,Pairs),pairs_keys(Pairs,[adapter,smoke]),
 string(D.adapter),string(D.smoke),string_length(D.adapter,A),A>0,A=<131072,
 string_length(D.smoke,S),S>0,S=<131072,
 ms_file("extension/adapter.sh",D.adapter,Adapter),ms_file("candidate_tests/smoke.sh",D.smoke,Smoke),Files=[Adapter,Smoke].
ms_file(Path,Content,['candidate-file',Path,Content,Hash]) :- crypto_data_hash(Content,Hash,[algorithm(sha256),encoding(utf8)]).
