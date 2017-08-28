-module(dubber_parser).

-export([generate/1]).

gen_module() ->
    erl_syntax:revert(erl_syntax:attribute(erl_syntax:atom(module), [erl_syntax:atom(dubber)])).

gen_export(Name, Args) ->
    erl_syntax:arity_qualifier(erl_syntax:atom(Name), erl_syntax:integer(length(Args))).

gen_function(Name, Args) ->
    Parameter = array:to_list(array:map(fun (I, _V) -> erl_syntax:variable("X" ++ integer_to_list(I)) end, array:from_list(Args))),
    %% Body = erl_syntax:application(erl_syntax:atom(dubber_core), erl_syntax:atom(fire), [erl_syntax:list([erl_syntax:string(Name)]), erl_syntax:list(Parameter)]),
    Body = erl_syntax:application(erl_syntax:atom(dubber_core), erl_syntax:atom(fire), [erl_syntax:string(Name), erl_syntax:list(Parameter)]),
    Clause =  erl_syntax:clause(Parameter, [],[Body]),
    Function =  erl_syntax:function(erl_syntax:atom(Name), [Clause]),
    {gen_export(Name, Args), erl_syntax:revert(Function)}.

gen_config(Options) ->
    {ok, OptionsToken, _} = erl_scan:string(lists:flatten(io_lib:format("~p.", [Options]))),
    {ok, OptionsAST} = erl_parse:parse_exprs(OptionsToken),
    Clause = erl_syntax:clause([], [], OptionsAST),
    Function = erl_syntax:function(erl_syntax:atom(get_config), [Clause]),
    {erl_syntax:arity_qualifier(erl_syntax:atom(get_config), erl_syntax:integer(0)), erl_syntax:revert(Function)}.

generate(Options) ->
    ModuleForm = gen_module(),
    {ConfigExport, ConfigForm} = gen_config(Options),
    ZipForm = maps:fold(fun (Name, Value, FormList) ->
                                {_, Args, _} = maps:get("signature", Value),
                                FormList ++ [gen_function(Name, Args)]
                        end, [], maps:get("interfaces", Options)),
    {FnExport, FunctionForm} = lists:unzip(ZipForm),
    ExportForm = erl_syntax:revert(erl_syntax:attribute(erl_syntax:atom(export), [erl_syntax:list([ConfigExport] ++ FnExport)])),
    {ok, Module, Binary} = compile:forms([ModuleForm, ExportForm] ++ [ConfigForm] ++ FunctionForm),
    code:load_binary(Module, [], Binary).
