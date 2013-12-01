%%% vim: set ts=4 sts=4 sw=4 et:

-module(rebar_genappup_plugin).
-export([
    'post_compile'/2,
    'post_clean'/2
]).

'post_compile'(Config, _AppFile) ->
    SrcDir  = filename:join(rebar_utils:get_cwd(), "src"),
    Files = filelib:wildcard(SrcDir ++ "/*.appup.src"),
    lists:foreach(fun(File) ->
        copy_appup_src(Config, File)
    end, Files).

'post_clean'(Config, _AppFile) ->
    SrcDir  = filename:join(rebar_utils:get_cwd(), "src"),
    Files = filelib:wildcard(SrcDir ++ "/*.appup.src"),
    lists:foreach(fun(File) ->
        delete_appup(Config, File)
    end, Files).


copy_appup_src(Config, Src) ->
    io:format("Found ~s.", [filename:basename(Src)]),
    App  = filename:basename(Src, ".appup.src"),
    Dest = filename:join([get_app_dir(Config, App),
        "ebin", App ++ ".appup"]),
    io:format(" Making ~s...~n", [filename:basename(Dest)]),
    {ok, _} = file:copy(Src, Dest).

delete_appup(Config, Src) ->
    App  = filename:basename(Src, ".appup.src"),
    Dest = filename:join([get_app_dir(Config, App),
        "ebin", App ++ ".appup"]),
    file:delete(Dest).

get_app_dir(Config, App) ->
    DepsDir = rebar_config:get_xconf(Config, deps_dir, "deps"),
    LibDirs = rebar_config:get(Config, lib_dirs, []),
    find_app(Config, App,
        lists:umerge([DepsDir], lists:sort(LibDirs))).

find_app(_Config, App, []) ->
    io:format("~nERROR: Can't find app ~p.~n", [App]),
    halt(1);
find_app(Config, App, [Dir | RestDirs]) ->
    BaseDir = rebar_config:get_xconf(Config, base_dir, []),
    AppDir = filename:join([BaseDir, Dir, App]),
    case filelib:is_dir(AppDir) of
        true -> AppDir;
        false -> find_app(Config, App, RestDirs)
    end.
