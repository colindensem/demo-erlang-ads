-module (cb_media_creatives_controller, [Req]).
-compile(export_all).

-default_action(index).

index('GET', []) ->
    Records = boss_db:find(creative,[]),
    {ok, [{records, Records}]}.

create('GET',[])->
    ok;
create('POST',[])->
    CreativeName = Req:post_param("name"),
    CreativeUrl = Req:post_param("url"),
    CreativeSize = Req:post_param("size"),
    NewCreative = creative:new(id, CreativeName, CreativeUrl, CreativeSize),
    case NewCreative:save() of
        {ok, SavedCreative} ->
            {redirect, [{action, "index"}]};
        {error, ErrorList} ->
            {ok, [{errors, ErrorList}, {new_creative, NewCreative}]}
    end.

show('GET',[RecordId])->
    Record = boss_db:find(RecordId),
    {ok, [{record, Record}]}.

edit('GET',[RecordId])->
    Record = boss_db:find(RecordId),
    {ok, [{record, Record}]};
edit('POST', [RecordId]) ->
    Record = boss_db:find(RecordId),
    NewRecord = lists:foldr(fun
            ('id', Acc) ->
                Acc;
            (Attr, Acc) ->
                AttrName = atom_to_list(Attr),
                Val = Req:post_param(AttrName),
                case lists:suffix("_time", AttrName) of
                    true ->
                        case Val of "now" -> Acc:set(Attr, erlang:now());
                            _ -> Acc
                        end;
                    false -> Acc:set(Attr, Val)
                end
        end, Record, Record:attribute_names()),
    case NewRecord:save() of
        {ok, SavedRecord} ->
            {redirect, [{action, "show"}, {record_id, RecordId}]};
        {error, Errors} ->
            {ok, [{errors, Errors}, {record, NewRecord}]}
    end.


delete('POST', [RecordId]) ->
  boss_db:delete(RecordId),
  {redirect, [{action, "index"}]}.

