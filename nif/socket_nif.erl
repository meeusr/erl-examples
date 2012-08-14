-module(socket_nif).
-export([socket/1, send/1,loopback/1, close/1]).
-on_load(init/0).

init() ->
    ok = erlang:load_nif("./socket_nif", 0).

close(_X) ->
    exit(nif_library_not_loaded).
socket(_Y) ->
    exit(nif_library_not_loaded).
send(_X) ->
    exit(nif_library_not_loaded).
loopback(_X) ->
    exit(nif_library_not_loaded).



