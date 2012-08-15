-module(udp_srv).
-export([s/0]).

-define(UINT16(N), N:2/native-unsigned-integer-unit:8).
-define(PF_INET, 2).
-define(PORT, 6001).

s() ->
    {ok,FD} = procket:socket(inet, dgram, 0),
    % sockaddr for Linux
    Sockaddr = <<?UINT16(?PF_INET), ?PORT:16, 0:32, 0:64>>,
    ok = procket:bind(FD, Sockaddr),
    Ref = erlang:open_port({fd, FD, FD}, [stream, binary]),
    loop(Ref).

loop(Ref) ->
    receive
        {Ref,{data,Data}} ->
            error_logger:info_report(Ref),
            loop(Ref)
    end.
