%%%-------------------------------------------------------------------
%%% @author Evgeny Khramtsov <ekhramtsov@process-one.net>
%%% @copyright (C) 2017, Evgeny Khramtsov
%%% @doc
%%%
%%% @end
%%% Created :  9 Mar 2017 by Evgeny Khramtsov <ekhramtsov@process-one.net>
%%%-------------------------------------------------------------------
-module(p1_queue_test).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").
-include("p1_queue.hrl").

queue_dir() ->
    {ok, Cwd} = file:get_cwd(),
    filename:join(Cwd, "p1_queue").

eacces_dir() ->
    {ok, Cwd} = file:get_cwd(),
    filename:join(Cwd, "eacces_queue").

mk_list() ->
    mk_list(1, 10).

mk_list(From, To) ->
    lists:seq(From, To).

start_test() ->
    ?assertEqual(ok, p1_queue:start(queue_dir())).

double_start_test() ->
    ?assertEqual(ok, p1_queue:start(queue_dir())).

new_ram_test() ->
    p1_queue:new().
new_file_test() ->
    Q = p1_queue:new(file),
    ?assertEqual(ok, p1_file_queue:close(Q)).

double_close_test() ->
    Q = p1_queue:new(file),
    ?assertEqual(ok, p1_file_queue:close(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

close_test() ->
    Q1 = p1_queue:new(file),
    Q2 = p1_queue:new(file),
    ?assertEqual(ok, p1_file_queue:close(Q1)),
    ?assertEqual(ok, p1_file_queue:close(Q2)).

type_ram_test() ->
    Q = p1_queue:new(ram),
    ?assertEqual(ram, p1_queue:type(Q)).
type_file_test() ->
    Q = p1_queue:new(file),
    ?assertMatch({file, _}, p1_queue:type(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

is_queue_ram_test() ->
    Q = p1_queue:new(ram),
    ?assertEqual(true, p1_queue:is_queue(Q)).
is_queue_file_test() ->
    Q = p1_queue:new(file),
    ?assertEqual(true, p1_queue:is_queue(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

is_queue_not_queue_test() ->
    ?assertEqual(false, p1_queue:is_queue(some)).

from_list_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L),
    ?assertEqual(ram, p1_queue:type(Q)).
from_list_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    ?assertMatch({file, _}, p1_queue:type(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

to_list_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, ram),
    ?assertEqual(L, p1_queue:to_list(Q)).
to_list_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    ?assertEqual(L, p1_queue:to_list(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

len_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, ram),
    ?assertEqual(10, p1_queue:len(Q)).
len_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    ?assertEqual(10, p1_queue:len(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

len_macro_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, ram),
    ?assertMatch(X when ?qlen(X) == 10, Q).
len_macro_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    ?assertMatch(X when ?qlen(X) == 10, Q),
    ?assertEqual(ok, p1_file_queue:close(Q)).

is_empty_ram_test() ->
    Q = p1_queue:new(ram),
    ?assertEqual(true, p1_queue:is_empty(Q)).
is_empty_file_test() ->
    Q = p1_queue:new(file),
    ?assertEqual(true, p1_queue:is_empty(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

clear_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, ram),
    Q1 = p1_queue:clear(Q),
    ?assertEqual(true, p1_queue:is_empty(Q1)).
clear_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    Q1 = p1_queue:clear(Q),
    ?assertEqual(true, p1_queue:is_empty(Q1)),
    ?assertEqual(ok, p1_file_queue:close(Q1)).

in_ram_test() ->
    Q = p1_queue:new(ram),
    Q1 = p1_queue:in(1, Q),
    ?assertEqual([1], p1_queue:to_list(Q1)).
in_file_test() ->
    Q = p1_queue:new(file),
    Q1 = p1_queue:in(1, Q),
    ?assertEqual([1], p1_queue:to_list(Q1)),
    ?assertEqual(ok, p1_file_queue:close(Q1)).

out_ram_test() ->
    Q = p1_queue:new(ram),
    Q1 = p1_queue:in(1, Q),
    ?assertMatch({{value, 1}, Q}, p1_queue:out(Q1)).
out_file_test() ->
    Q = p1_queue:new(file),
    Q1 = p1_queue:in(1, Q),
    ?assertMatch({{value, 1}, Q}, p1_queue:out(Q1)),
    ?assertEqual(ok, p1_file_queue:close(Q1)).

out_empty_ram_test() ->
    Q = p1_queue:new(ram),
    ?assertMatch({empty, Q}, p1_queue:out(Q)).
out_empty_file_test() ->
    Q = p1_queue:new(file),
    ?assertMatch({empty, Q}, p1_queue:out(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

peek_ram_test() ->
    Q = p1_queue:from_list([1], ram),
    ?assertEqual({value, 1}, p1_queue:peek(Q)).
peek_file_test() ->
    Q = p1_queue:from_list([1], file),
    ?assertEqual({value, 1}, p1_queue:peek(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

peek_empty_ram_test() ->
    Q = p1_queue:new(ram),
    ?assertEqual(empty, p1_queue:peek(Q)).
peek_empty_file_test() ->
    Q = p1_queue:new(file),
    ?assertEqual(empty, p1_queue:peek(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

drop_ram_test() ->
    Q = p1_queue:new(ram),
    Q1 = p1_queue:in(1, Q),
    ?assertEqual(Q, p1_queue:drop(Q1)).
drop_file_test() ->
    Q = p1_queue:new(file),
    Q1 = p1_queue:in(1, Q),
    ?assertEqual(Q, p1_queue:drop(Q1)),
    ?assertEqual(ok, p1_file_queue:close(Q1)).

drop_empty_ram_test() ->
    Q = p1_queue:new(ram),
    ?assertError(empty, p1_queue:drop(Q)).
drop_empty_file_test() ->
    Q = p1_queue:new(file),
    ?assertError(empty, p1_queue:drop(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

foreach_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, ram),
    put(p1_queue, []),
    F = fun(X) -> put(p1_queue, get(p1_queue) ++ [X]) end,
    ?assertEqual(ok, p1_queue:foreach(F, Q)),
    ?assertEqual(L, get(p1_queue)).
foreach_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    put(p1_queue, []),
    F = fun(X) -> put(p1_queue, get(p1_queue) ++ [X]) end,
    ?assertEqual(ok, p1_queue:foreach(F, Q)),
    ?assertEqual(L, get(p1_queue)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

foldl_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, ram),
    F = fun(X, Acc) -> Acc ++ [X] end,
    ?assertEqual(L, p1_queue:foldl(F, [], Q)).
foldl_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    F = fun(X, Acc) -> Acc ++ [X] end,
    ?assertEqual(L, p1_queue:foldl(F, [], Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

dropwhile_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, ram),
    F = fun(X) -> X < 6 end,
    Q1 = p1_queue:dropwhile(F, Q),
    ?assertEqual([6,7,8,9,10], p1_queue:to_list(Q1)).
dropwhile_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    F = fun(X) -> X < 6 end,
    Q1 = p1_queue:dropwhile(F, Q),
    ?assertEqual([6,7,8,9,10], p1_queue:to_list(Q1)),
    ?assertEqual(ok, p1_file_queue:close(Q1)).

drop_until_empty_ram_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, ram),
    Q1 = p1_queue:dropwhile(fun(_) -> true end, Q),
    ?assertEqual(true, p1_queue:is_empty(Q1)).
drop_until_empty_file_test() ->
    L = mk_list(),
    Q = p1_queue:from_list(L, file),
    Q1 = p1_queue:dropwhile(fun(_) -> true end, Q),
    ?assertEqual(true, p1_queue:is_empty(Q1)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

format_error_test() ->
    Unknown = "unknown POSIX error",
    ?assertEqual(Unknown, p1_queue:format_error(foo1234)),
    ?assertNotEqual(Unknown, p1_queue:format_error(empty)),
    ?assertNotEqual(Unknown, p1_queue:format_error(corrupted)).

bad_size_test() ->
    #file_q{fd = Fd} = Q = p1_queue:from_list([1], file),
    ?assertMatch({ok, _}, file:position(Fd, 0)),
    ?assertEqual(ok, file:truncate(Fd)),
    ?assertEqual(ok, file:pwrite(Fd, 0, <<1>>)),
    ?assertError(corrupted, p1_queue:out(Q)),
    ?assertError(corrupted, p1_queue:peek(Q)),
    ?assertError(corrupted, p1_queue:drop(Q)),
    ?assertError(corrupted, p1_queue:to_list(Q)),
    ?assertError(corrupted, p1_queue:dropwhile(fun(_) -> true end, Q)),
    ?assertError(corrupted, p1_queue:foreach(fun(_) -> ok end, Q)),
    ?assertError(corrupted, p1_queue:foldl(fun(_, _) -> ok end, ok, Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

eof_test() ->
    #file_q{fd = Fd} = Q = p1_queue:from_list([1], file),
    ?assertMatch({ok, _}, file:position(Fd, 0)),
    ?assertEqual(ok, file:truncate(Fd)),
    ?assertEqual(ok, file:pwrite(Fd, 0, <<1:32>>)),
    ?assertError(corrupted, p1_queue:out(Q)),
    ?assertError(corrupted, p1_queue:peek(Q)),
    ?assertError(corrupted, p1_queue:to_list(Q)),
    ?assertError(corrupted, p1_queue:dropwhile(fun(_) -> true end, Q)),
    ?assertError(corrupted, p1_queue:foreach(fun(_) -> ok end, Q)),
    ?assertError(corrupted, p1_queue:foldl(fun(_, _) -> ok end, ok, Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

bad_term_test() ->
    #file_q{fd = Fd} = Q = p1_queue:from_list([1], file),
    ?assertMatch({ok, _}, file:position(Fd, 0)),
    ?assertEqual(ok, file:truncate(Fd)),
    ?assertEqual(ok, file:pwrite(Fd, 0, <<5:32, 1>>)),
    ?assertError(corrupted, p1_queue:out(Q)),
    ?assertError(corrupted, p1_queue:peek(Q)),
    ?assertError(corrupted, p1_queue:to_list(Q)),
    ?assertError(corrupted, p1_queue:dropwhile(fun(_) -> true end, Q)),
    ?assertError(corrupted, p1_queue:foreach(fun(_) -> ok end, Q)),
    ?assertError(corrupted, p1_queue:foldl(fun(_, _) -> ok end, ok, Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

closed_test() ->
    Q = p1_queue:from_list([1], file),
    ?assertEqual(ok, p1_file_queue:close(Q)),
    ?assertError(einval, p1_queue:in(2, Q)),
    ?assertError(einval, p1_queue:out(Q)),
    ?assertError(einval, p1_queue:peek(Q)),
    ?assertError(einval, p1_queue:drop(Q)),
    ?assertError(einval, p1_queue:to_list(Q)),
    ?assertError(einval, p1_queue:dropwhile(fun(_) -> true end, Q)),
    ?assertError(einval, p1_queue:foreach(fun(_) -> ok end, Q)),
    ?assertError(einval, p1_queue:foldl(fun(_, _) -> ok end, ok, Q)),
    ?assertError(einval, p1_file_queue:clear(Q)),
    ?assertEqual(ok, p1_file_queue:close(Q)).

write_fail_test() ->
    #file_q{fd = Fd, path = Path} = Q = p1_queue:new(file),
    ?assertEqual(ok, file:close(Fd)),
    %% Open file in read-only mode, so write operations fail
    {ok, NewFd} = file:open(Path, [read, binary, raw]),
    Q1 = Q#file_q{fd = NewFd},
    ?assertError(ebadf, p1_queue:in(1, Q1)),
    ?assertError(einval, p1_file_queue:clear(Q1)),
    ?assertEqual(ok, p1_file_queue:close(Q1)).

monitor_test() ->
    %% Check if 'DOWN' messages is correctly processed
    spawn(fun() -> p1_queue:new(file) end).

emfile_test() ->
    _ = [p1_queue:new(file) || _ <- lists:seq(1, 10)],
    ?assertError(emfile, p1_queue:new(file)).

stop_test() ->
    ?assertMatch({ok, [_|_]}, file:list_dir(queue_dir())),
    ?assertEqual(ok, p1_queue:stop()),
    ?assertEqual({ok, []}, file:list_dir(queue_dir())).

start_fail_test() ->
    Dir = eacces_dir(),
    QDir = filename:join(Dir, "p1_queue"),
    ?assertEqual(ok, filelib:ensure_dir(QDir)),
    ?assertEqual(ok, file:change_mode(Dir, 8#00000)),
    ?assertMatch({error, _}, p1_queue:start(QDir)).

start_eacces_test() ->
    ?assertMatch(ok, p1_queue:start(eacces_dir())).

new_eacces_test() ->
    ?assertError(eacces, p1_queue:new(file)).

from_list_eacces_test() ->
    L = mk_list(),
    ?assertError(eacces, p1_queue:from_list(L, file)).

stop_eaccess_test() ->
    ?assertEqual(ok, p1_queue:stop()).