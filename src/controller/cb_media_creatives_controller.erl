-module (cb_media_creatives_controller, [Req]).
-compile(export_all).

-default_action(index).
-define(LOG(Name, Value), io:format("DEBUG: ~s: ~p~n", [Name, Value])).

index('GET', []) ->
    Records = boss_db:find(creative,[]),
    {ok, [{records, Records}]}.

create('GET',[])->
    ok;
create('POST',[])->
    Name = Req:post_param("name"),
    Url = Req:post_param("url"),
    Size = Req:post_param("size"),
    Image = '',
    NewCreative = creative:new(id, Name, Url, Size, Image),
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
    Record:set(impr_counter,0),
    %Handle upload file / replacement
    case Req:post_files() of
        [{uploaded_file, FileName, FileTmp, FileLength}] ->
            % = Req:post_files(),
            ?LOG("NEWFILE", FileName),
            PublicDestination="/static/creatives/"++RecordId++"-"++FileName,
            Destination = "./priv"++PublicDestination,

            ?LOG("File1", PublicDestination),
            ?LOG("File2", Destination),

            file:copy(FileTmp, Destination),
            file:delete(FileTmp);

        _Else ->
            PublicDestination=false
    end,


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
                false ->
                    case Attr==image of
                        true->
                            case PublicDestination==false of
                                true ->
                                    Acc:set(Attr, Val);
                                false ->
                                    Acc:set(Attr, PublicDestination)
                            end;
                        false->
                            Acc:set(Attr, Val)
                    end
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

