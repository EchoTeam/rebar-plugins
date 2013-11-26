%%% vim: set ts=4 sts=4 sw=4 et:

-module(rebar_genappup_plugin).
-export([
    'post_compile'/2
]).

'post_compile'(_Config, _AppFile) ->
    AppDir = rebar_utils:get_cwd(),
    AppUpSrc = appup_src_name(AppDir),
    AppUp = appup_name(AppDir),
    case file:read_file_info(AppUpSrc) of
        {error, enoent} -> ok;
        {ok, _} ->
            io:format("Found ~s. Making ~s...~n",
                [filename:basename(AppUpSrc), filename:basename(AppUp)]),
            {ok, _} = file:copy(AppUpSrc, AppUp),
            ok
    end.

appup_src_name(AppDir) ->
    AppName = filename:basename(AppDir),
    filename:join([AppDir, "src", AppName ++ ".appup.src"]).

appup_name(AppDir) ->
    AppName = filename:basename(AppDir),
    filename:join([AppDir, "ebin", AppName ++ ".appup"]).
