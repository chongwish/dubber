-module(dubber).

-export([init/1]).

init(Options) ->
    dubber_parser:generate(Options).
    %% {ok, Client} = dubber_client:start_link(),
    %% spawn(fun() -> run(Client, [], Options) end).

%% run(Client, Consumer, Options) ->
%%     receive
%%         Message ->
%%             {RealConsumer, Result} = dubber_client:run(Client,
%%                                                   {case Consumer of
%%                                                        [] -> dubber_register:get_consumer(Options);
%%                                                        _ -> Consumer
%%                                                    end, Message}),
%%             Result,
%%             run(Client, RealConsumer, Options)
%%     end.
