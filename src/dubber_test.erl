-module(dubber_test).

-export([demo/0]).

demo() ->
    dubber:init(#{
                   "application" => "demo",
                   "version" => "2.5.3.6",
                   "address" => "192.168.31.22",
                   "port" => 2181,
                   "namespace" => "dubbo",
                   "interfaces" => #{
                     "foo" => #{
                       "interface" => "com.alibaba.dubbo.demo.DemoService",
                       "group" => "abc",
                       "signature" => {"sayHello", ["long", "com.xx.YY", "[List]"], "long"}
                      },
                     "bar" => #{
                       "interface" => "com.alibaba.dubbo.demo.DemoService",
                       "group" => "abc",
                       "signature" => {"sayHello", ["java.lang.String"], "long"}
                      }
                    }
                 }).
