-module(dubber_register_zookeeper).

-behaviour(gen_server).

-define(PORT, 2181).
-define(TIMEOUT, 30000).
-define(ADDRESS, "localhost").

-export([init/1, handle_cast/2, handle_call/3]).
-export([register_link/1]).

init(_) ->
    {ok, "init"}.

handle_cast(_, _) ->
    {ok, "cast"}.

handle_call({Zookeeper, Options, Fn}, _, State) ->
    {ok, NodeList} = erlzk:get_children(Zookeeper, "/" ++ maps:get("namespace", Options) ++ "/" ++ dubber_register:get_config(["interfaces", Fn, "interface"], Options) ++ "/providers"),
    if NodeList =/= [] ->
            Node = lists:nth(rand:uniform(length(NodeList)), NodeList),
            {ok, {Schema, _User, Address, Port, Path, "?" ++ Query}} = http_uri:parse(http_uri:decode(http_uri:decode(Node))),
            Result = maps:from_list(lists:append([{"schema", Schema},
                                                  {"address", Address},
                                                  {"port", Port},
                                                  {"path", Path},
                                                  {"version", dubber_register:get_config(["interfaces", Fn, "version"], Options, "")},
                                                  {"group", dubber_register:get_config(["interfaces", Fn, "group"], Options)},
                                                  {"signature", dubber_register:get_config(["interfaces", Fn, "signature"], Options)}],
                                                 [case string:split(X, "=") of
                                                      [K, V] -> {K, V}
                                                  end || X <- string:split(Query, "&", all)])),
            {reply, Result, State};
       true ->
            {reply, #{}, State}
    end.

register_link(Options) ->
    erlzk:start(),
    {ok, Zookeeper} = erlzk:connect([{maps:get("address", Options, ?ADDRESS), maps:get("port", Options, ?PORT)}], maps:get("timeout", Options, ?TIMEOUT)),
    {ok, GenServer} = gen_server:start_link(?MODULE, [], []),
    fun(Fn) -> gen_server:call(GenServer, {Zookeeper, Options, Fn}) end.
