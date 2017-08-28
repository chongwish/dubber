-module(dubber_register).

-export([configure/1, get_config/2, get_config/3, get_consumer/1]).

configure(Options) ->
    {ok, Options}.

get_config([Key|Rest], Options) when is_list(Key) or is_atom(Key) ->
    case Rest of
        [] -> get_config(Key, Options);
        _ -> get_config(Rest, maps:get(Key, Options))
    end;
get_config(Key, Options) ->
    maps:get(Key, Options).

get_config([Key|Rest], Options, Value) when is_list(Key) or is_atom(Key) ->
    case Rest of
        [] -> get_config(Key, Options, Value);
        _ -> get_config(Rest, maps:get(Key, Options), Value)
    end;
get_config(Key, Options, Value) ->
    maps:get(Key, Options, Value).

get_consumer(Options) ->
    Type = maps:get(type, Options, zookeeper),
    case Type of
        zookeeper ->
            dubber_register_zookeeper:register_link(Options)
    end.
