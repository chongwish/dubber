-module(dubber_core).

-export([fire/2]).

fire(Fn, Message) ->
    {ok, Client} = dubber_client:start_link(),
    Options = dubber:get_config(),
    dubber_client:run(Client, {dubber_register:get_consumer(Options), {Fn, Message}}).
