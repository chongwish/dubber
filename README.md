# NAME

Dubber - A Dubbo Client For Erlang

#SYNOPSIS

    Find dubber provider with zookeeper, and communicate with hessian protocol.

# Dependency

    zookeeper (rebar3)
    hessian2.0-erlang (manual: https://github.com/optd-dl/hessian2.0-erlang)

# Usage

    # compile
    #> rebar3 compile
    # link
    #> erl -pa _build/default/lib/dubber/ebin -pa _build/default/erlzk/ebin -pa $hessian_ebin

    # demo
    # a dubber provider demo (sayHello demo) come from: https://github.com/alibaba/dubbo
    # just like the example file: src/dubber_test.erl
    # Config = #{
    #               "application" => "demo",
    #               "version" => "2.5.3.6",
    #               "address" => ip,
    #               "port" => port,
    #               "namespace" => "dubbo",
    #               "interfaces" => #{
    #                 "test" => #{
    #                   "interface" => "xxx",
    #                   "group" => "xxx",
    #                   "signature" => {"xxx", ["xxx", "xxx"], "xxx"}
    #                 },
    #                 "say" => #{
    #                   "interface" => "com.alibaba.dubbo.demo.DemoService",
    #                   "group" => "abc",
    #                   "signature" => {"sayHello", ["java.lang.String"], "long"}
    #                  }   
    #                }   
    #             }). 
    #erl> dubber:init(Config).
    # then will generate say function and test function in the dubber module
    #erl> dubber:say("dreamy").
    # <<"06Hello dreamy, response form provider: 192.168.31.22:20888">>}