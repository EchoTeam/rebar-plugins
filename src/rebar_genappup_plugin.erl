%%% vim: set ts=4 sts=4 sw=4 et:

-module(rebar_genappup_plugin).
-export([
    'post_compile'/2
]).

'post_compile'(Config, _AppFile) ->
    SrcDir  = filename:join(rebar_utils:get_cwd(), "src"),
    Files = filelib:wildcard(SrcDir ++ "/*.appup.src"),
    lists:foreach(fun(File) ->
        copy_appup_src(Config, File)
    end, Files).

copy_appup_src(Config, Src) ->
    App  = filename:basename(Src, ".appup.src"),
    Dest = filename:join([get_deps_dir(Config, App),
        "ebin", App ++ ".appup"]),
    DestDir = filename:dirname(Dest),
    case filelib:is_dir(DestDir) of
        true ->
            io:format("Found ~s. Making ~s...~n",
                [filename:basename(Src), filename:basename(Dest)]),
            {ok, _} = file:copy(Src, Dest);
        false ->
            io:format("ERROR: Can't process ~p. Path ~p not found.~n",
                [Src, DestDir]),
            halt(1)
    end.

get_deps_dir(Config, App) ->
    BaseDir = rebar_config:get_xconf(Config, base_dir, []),
    DepsDir = rebar_config:get_xconf(Config, deps_dir, "deps"),
    filename:join([BaseDir, DepsDir, App]).
