-module(udp_srv2).
-export([s/0]).

s() ->
    {ok,FD} = procket:socket(inet, dgram, 0),
    Sockaddr = <<2:2/native-unsigned-integer-unit:8,6001:16, 0:32, 0:64>>,
    ok = procket:bind(FD, Sockaddr),
    {ok,Ref} = gen_udp:open(6001,[{fd,FD}]),
    loop(Ref,FD,0).

loop(Ref,FD,MsgCount) ->
    inet:setopts(Ref, [{active, once},{recbuf,5200*1024}]),
    receive
        {udp, Socket, Host, Port, Data} ->
	    {B1,B2,B3,B4} = Host,
            Addr = <<2:2/native-unsigned-integer-unit:8,Port:16,B1:8,B2:8,B3:8,B4:8, 0:64>>,
 	    process_data(FD,Addr,list_to_binary(Data)),
	    MsgCount2 = MsgCount + loop_procket(FD,0) + 1,
	    loop(Ref,FD,MsgCount2);
	{stats} ->
	    io:format("Nbr of messages received ~p~n",[MsgCount]),
	    loop(Ref,FD,MsgCount);
        _  -> 
	    loop(Ref,FD,MsgCount)
    end.

loop_procket(FD,MsgCount) ->
    case procket:recvfrom(FD,1000,0,60) of
	{ok,Data,Addr} -> 
	    process_data(FD,Addr,Data),
	    loop_procket(FD,MsgCount+1);
	{error,_} -> 
	    MsgCount
    end.

process_data(FD,Addr,Data) ->
    procket:sendto(FD,Data,0,Addr).

