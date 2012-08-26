-module(system_stats).
-export([get_total/1,get_all/0]).

get_total(Type) ->
    List = [ element(2,lists:keyfind(Type,1,erlang:process_info(F))) || F <- erlang:processes()],
    lists:foldl(fun(X, Sum) -> X + Sum end, 0, List).

get_all() ->
    [{context_switches,element(1,erlang:statistics(context_switches))},
     {run_queue,erlang:statistics(run_queue)},
     {process_count,erlang:system_info(process_count)},
     {exact_reductions,element(1,erlang:statistics(exact_reductions))} |
     [{Atom,get_total(Atom)} || Atom <- [heap_size,stack_size,message_queue_len,reductions]]
    ].
