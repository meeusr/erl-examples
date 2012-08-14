-module(socket_nif).
-export([socket/0, bind/2, send/2 ,loopback/1, close/1, create_server/1, client_sync/2]).
-on_load(init/0).

init() ->
    ok = erlang:load_nif("./socket_nif", 0).

socket() ->
    exit(nif_library_not_loaded).
bind(_SOCK,_Port) ->
    exit(nif_library_not_loaded).
send(_SOCK,_DestPort) ->
    exit(nif_library_not_loaded).
loopback(_SOCK) ->
    exit(nif_library_not_loaded).
close(_SOCK) ->
    exit(nif_library_not_loaded).

create_server(Port) ->
    SRV = socket_nif:socket(),
    socket_nif:bind(SRV,Port),
    register(udp_server,spawn(fun() -> server_loop(SRV) end)).

server_loop(Sock) ->
   socket_nif:loopback(Sock),
   server_loop(Sock).

client_sync(N,Port) ->
   CLT = socket_nif:socket(),
   client_loop(CLT,Port,N).

client_loop(_Sockn,_Port,0) -> ok;
client_loop(Sock,Port,N) ->
   socket_nif:send(Sock,Port),
   client_loop(Sock,Port,N-1).



