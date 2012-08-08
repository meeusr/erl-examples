-module(ordered_list).
-export([valid_entry_count/4,timediff/2]).

timediff(Now,TS) -> 
  round(erlang:now_diff(Now,TS)/1000000).

valid_entry_count(List,Now,Age,F) ->
  valid_entry_count(List,Now,Age,F,0).

valid_entry_count([],_Now,_Age,_F,Acc) ->
  Acc;

valid_entry_count([Head|Tail],Now,Age,F,Acc) ->
  Diff = F(Now,Head),
  io:format("valid_entry_count ~p\n",[Timediff]),
  if 
    Diff < Age -> 
        valid_entry_count(Tail,Now,Age,F,Acc+1);
    true -> Acc
  end.

