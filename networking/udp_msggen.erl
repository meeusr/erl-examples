-module(udp_msggen).
-export([s/0]).

-define(UINT16(N), N:2/native-unsigned-integer-unit:8).
-define(PF_INET, 2).
-define(PORT, 6001).

s() ->
    {ok,FD} = procket:socket(inet, dgram, 0),
    % sockaddr for Linux
    Sockaddr = <<?UINT16(?PF_INET), ?PORT:16, 0:32, 0:64>>,
    ok = procket:bind(FD, Sockaddr),
    spawn(fun() -> server_loop(FD) end).

server_loop(FD) ->
    case procket:recvfrom(FD,1000,0,60) of
	{ok,Data,Addr} -> 
		io:format("Message received, start generating...\n"),
		server_generate(FD,Data,Addr);

	{error,eagain} -> 
		server_loop(FD)
    end.

server_generate(FD,Data,Addr) ->
    procket:sendto(FD,Data,0,Addr),
    server_generate(FD,Data,Addr).
