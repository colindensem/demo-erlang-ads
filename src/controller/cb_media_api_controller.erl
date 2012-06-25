-module (cb_media_api_controller, [Req]).
-compile(export_all).

-default_action(index).
-define(LOG(Name, Value), io:format("DEBUG: ~s: ~p~n", [Name, Value])).

index('GET',[])->
    {ok, "API OK"}.

randomJson('GET',[])->
    Counter = boss_db:count(creative),
    % Records = boss_db:find(creative,[]),
    ?LOG("randomJson-counter", Counter),
    random:seed(now()),
    Index   = random:uniform(Counter),
    ?LOG("randomJson-index", Index),
    % Record  = lists:nth(Index, Records),
    Records = boss_db:find(creative,[], 1, Index-1),
     ?LOG("Click-Record", Records),
    Record = lists:nth(1, Records),
    Record:incr(impr_counter),

    % boss_mq:push("metrics-impressions", Record:id()),
    Callback= Req:query_param("callback"),
    {jsonp, Callback, Record}.

click('GET',[RecordId]) ->
    Record = boss_db:find(RecordId),
    boss_mq:push("metrics-clicks", Record:id()),
     ?LOG("Click-Record", Record),
    {redirect, Record:url()}.