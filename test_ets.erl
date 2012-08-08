-module(test_ets).
-compile(export_all).

perf_test(N,Length) ->
  Table = ets:new( 'test_ets',  [] ),
  Data = lists:seq(1,Length),
  Start = erlang:now(),
  populate(Table,N,Data),
  io:format("stop : ~p\n",[timer:now_diff(erlang:now(),Start)]),
  lookup(Table),
  ets:delete(Table).

populate( _Table, 0, _Data) -> ok;

populate( Table, N, Data ) ->
  ets:insert( Table,{entry,N,Data}),
  populate( Table,N-1,Data ).
        
lookup( Table ) ->
  [{entry,N,_List}] = ets:lookup( Table,entry ),
  io:format("Lookup : ~p\n",[N]).

