-module(message).
-export([parse/1,compose/3,roundtrip/1]).

parse(Data) when is_list(Data) ->
    [D1,D2,D3,D4,D5] = string:tokens(Data, " ,{}"),
    {list_to_integer(D1),list_to_integer(D2),{list_to_integer(D3),list_to_integer(D4),list_to_integer(D5)}}.

compose(Idx1,Idx2,TS) when is_integer(Idx1),is_integer(Idx2), is_tuple(TS) ->
    lists:flatten(io_lib:format("~w ~w ~w",[Idx1,Idx2,TS])).

roundtrip({_,_,TS} = Message) ->
    timer:now_diff(erlang:now(),TS).
