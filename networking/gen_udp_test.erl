-module(gen_udp_test).
-export([start_server/0, stop_server/0, client_sync/1,client_async/1]).

start_server() ->
    register(udp_server,spawn(fun() -> server(9000) end)).

stop_server() ->
    udp_server ! stop.

server(Port) ->
    {ok, Socket} = gen_udp:open(Port, [binary]),
    io:format("server opened socket:~p~n",[Socket]),
    loop(Socket,0),
    io:format("server close socket:~p~n",[Socket]),
    gen_udp:close(Socket).

loop(Socket,MsgCount) ->
    receive
        {udp, Socket, Host, Port, Data} ->
	    {RxId,_,TS} = message:parse(binary_to_list(Data)),
	    NewData = message:compose(RxId,MsgCount,TS),
            gen_udp:send(Socket, Host, Port, NewData),
            loop(Socket,MsgCount+1);
	{stats} ->
	    io:format("~p~n",[MsgCount]),
	    loop(Socket,MsgCount);
        stop -> ok
    end.

client_sync(N) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    io:format("client opened socket=~p~n",[Socket]),
    Start = erlang:now(),
    sendmessage_sync(Socket,N),
    io:format("stop : ~p\n",[timer:now_diff(erlang:now(),Start)]),
    gen_udp:close(Socket).

client_async(N) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    io:format("client opened socket=~p~n",[Socket]),
    Start = erlang:now(),
    sendmessage_async(Socket,N),
    recvmessage_async(Socket,N),
    io:format("stop : ~p\n",[timer:now_diff(erlang:now(),Start)]),
    gen_udp:close(Socket).

sendmessage_sync(_Socket,0) -> ok;
sendmessage_sync(Socket,N) ->
    Data = message:compose(N,0,erlang:now()),
    ok = gen_udp:send(Socket, "127.0.0.1", 9000,Data),
    receive
        {udp, Socket, _, _, ReplyData} ->
	    {ClientId,ServerId,TS} = message:parse(binary_to_list(ReplyData)),
            io:format("RT=~p ~n",[timer:now_diff(now(),TS)]),
	    case N>0 of 
                true -> sendmessage_sync(Socket,N-1);
		_ -> ok
	    end;

	Msg -> 
	    io:format("sendmessagesync unknown ~p~n",[Msg])

        after 2000 ->
            io:format("sendmessagesync timeout~n")
    end.

sendmessage_async(_Socket,0) -> ok;
sendmessage_async(Socket,N) ->
    Data = message:compose(N,0,erlang:now()),
    ok = gen_udp:send(Socket, "127.0.0.1", 9000, Data),
    sendmessage_async(Socket,N-1).

recvmessage_async(_Socket,0) -> ok;
recvmessage_async(Socket,N) ->
    receive
        {udp, Socket, _, _, ReplyData} ->
            {ClientId,ServerId,TS} = message:parse(binary_to_list(ReplyData)),
            io:format("RT=~p ~n",[timer:now_diff(now(),TS)]),
            sendmessage_sync(Socket,N-1);

        Msg ->
            io:format("sendmessageasync unknown ~p~n",[Msg])

        after 2000 ->
            io:format("sendmessageasync timeout~n")

    end.
