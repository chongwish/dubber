-module(dubber_coding).

-include("hessian.hrl").

%% 8 * 16 * 256 * 256
-define(MAX_BIT, 8388608).

-export([encode/2, decode/1]).
-export([gen_header/1, gen_body/2, gen_type_sign/1]).

encode(Map, Args) ->
    Body = gen_body(Map, Args),
    Header = gen_header(byte_size(Body)),
    <<Header/binary, Body/binary>>.

gen_body(Map, Args) ->
    Revision = hessianEncode:encode(maps:get("revision", Map), []),
    Interface = hessianEncode:encode(maps:get("interface", Map), []),
    Version = hessianEncode:encode(maps:get("version", Map), []),
    Methods = hessianEncode:encode(maps:get("methods", Map), []),
    {Hash, _} = hessianEncode:encode(
                  #map{dict = 
                           dict:from_list([
                                      {<<"interface">>, maps:get("interface", Map)},
                                      {<<"path">>, maps:get("interface", Map)},
                                      {<<"group">>, maps:get("group", Map)}
                                     ])}, []),
    if Args =/= [] ->
            {_, FnArgsSign, _} = maps:get("signature", Map),
            TypeSign = hessianEncode:encode(gen_type_sign(FnArgsSign), []),
            Argv = binary:list_to_bin([hessianEncode:encode(X, []) || X <- Args]),
            <<Revision/binary, Interface/binary, Version/binary, Methods/binary, TypeSign/binary, Argv/binary, Hash/binary>>;
       true ->
            <<Revision/binary, Interface/binary, Version/binary, Methods/binary, Hash/binary>>
    end.

gen_type_sign(Args) ->
    TypeMap = #{"boolean" => "Z", "int" => "I", "short" => "S", "long" => "J", "double" => "D", "float" => "F"},
    unicode:characters_to_binary(
      string:join([case X of
                       "[" ++ Rest ->
                           Type = string:slice(Rest, 0, length(Rest) - 1),
                           "[" ++ maps:get(Type, TypeMap, "L" ++ string:replace(Type, ".", "/", all) ++ ";");
                       _ -> maps:get(X, TypeMap, "L" ++ string:replace(X, ".", "/", all) ++ ";")
                   end|| X <- Args], "")).

gen_header(Length) ->
    Header = <<16#da, 16#bb, 16#c2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>,
    Footer = binary:encode_unsigned(Length),
    <<(binary:part(Header, 0, 16 - byte_size(Footer)))/binary, Footer/binary>>.

decode(Binary) ->
    <<_:16/binary, Code/binary>> = Binary,
    hessianDecode:decode(Code, hessianDecode:init()).
