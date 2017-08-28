-module(dubber_client).

-behaviour(gen_server).

-export([init/1, handle_cast/2, handle_call/3]).
-export([start_link/0]).
-export([run/2]).

init(_) ->
    {ok, "init"}.

handle_cast(_, _) ->
    {ok, "cast"}.

handle_call({Consumer, {Fn, Message}}, _, State) ->
    Map = Consumer(Fn),
    {ok, Sock} = gen_tcp:connect(maps:get("address", Map), maps:get("port", Map), [binary, {active, false}, {packet, 0}]),
    gen_tcp:send(Sock, dubber_coding:encode(Map, Message)),
    {ok, Data} = gen_tcp:recv(Sock, 0),
    {Result, _, _} = dubber_coding:decode(Data),
    gen_tcp:close(Sock),
    {reply, {Consumer, Result}, State};
handle_call(_, _, State) ->
    {reply, {[], {}}, State}.

start_link() ->
    start_link([]).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

run(Pid, Message) ->
    gen_server:call(Pid, Message).
