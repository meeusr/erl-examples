-module(gen_udp_test).
-export([start_server/0, stop_server/0, client_sync/1,client_async/1]).

start_server() ->
    register(udp_server,spawn(fun() -> server(6001) end)).

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
            %% io:format("server received:~p~n",[Msg]),
            gen_udp:send(Socket, Host, Port, Data),
            loop(Socket,MsgCount+1);
	{stats} ->
	    io:format("~p~n",[MsgCount]),
	    loop(Socket,MsgCount);
        stop -> ok
    end.

client_sync(N) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    %% io:format("client opened socket=~p~n",[Socket]),
    Start = erlang:now(),
    sendmessage_sync(Socket,N),
    io:format("stop : ~p\n",[timer:now_diff(erlang:now(),Start)]),
    gen_udp:close(Socket).

client_async(N) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    %% io:format("client opened socket=~p~n",[Socket]),
    Start = erlang:now(),
    sendmessage_async(Socket,N),
    recvmessage_async(Socket,N),
    io:format("stop : ~p\n",[timer:now_diff(erlang:now(),Start)]),
    gen_udp:close(Socket).

sendmessage_sync(_Socket,0) -> ok;
sendmessage_sync(Socket,N) ->
    ok = gen_udp:send(Socket, "127.0.0.1", 9000, "test"),
    receive
        {udp, Socket, _, _, Data} = Msg ->
            %% io:format("client received:~p data:~p ~n",[Msg,Data]),
            sendmessage_sync(Socket,N-1)
        after 2000 ->
            io:format("sendmessagesync timeout~n")
    end.

sendmessage_async(_Socket,0) -> ok;
sendmessage_async(Socket,N) ->
    ok = gen_udp:send(Socket, "127.0.0.1", 9000, "test"),
    sendmessage_async(Socket,N-1).

recvmessage_async(_Socket,0) -> ok;
recvmessage_async(Socket,N) ->
    receive
        {udp, Socket, _, _, Data} = Msg ->
            %% io:format("client received:~p data:~p ~n",[Msg,Data]),
            recvmessage_async(Socket,N-1)
        after 2000 ->
            io:format("recvmessage_async timeout~n")
    end.
