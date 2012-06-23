-module(cb_media_world_controller, [Req]).
-compile(export_all).

hello('GET',[]) ->
  {ok, [{message,"Hello World!!"}]}.

list('GET', []) ->
  Messages = boss_db:find(message, []),
  {ok, [{messages, Messages}]}.

create('GET', [])->
  ok;
create('POST',[])->
  MessageText = Req:post_param("message_text"),
  NewMessage = message:new(id, MessageText),
  case NewMessage:save() of
    {ok, Savedmessage} ->
      {redirect, [{action, "list"}]};
    {error, ErrorList} ->
      {ok, [{errors, ErrorList}, {new_msg, NewMessage}]}
  end.


delete('POST', []) ->
  boss_db:delete(Req:post_param("message_id")),
  {redirect, [{action, "list"}]}.

send_test_message('GET', []) ->
    TestMessage = "Free at last!",
        boss_mq:push("test-channel", TestMessage),
        {output, TestMessage}.

pull('GET', [LastTimestamp])->
    {ok, Timestamp, Messages} = boss_mq:pull("new-messages",
        list_to_integer(LastTimestamp)),
    {json, [{timestamp, Timestamp}, {messages, Messages}]}.

pop('GET', [LastTimestamp])->
    {ok, Timestamp, Messages} = boss_mq:pull("old-messages",
        list_to_integer(LastTimestamp)),
    {json, [{timestamp, Timestamp}, {messages, Messages}]}.

live('GET',[])->
    Messages = boss_db:find(message,[]),
    Timestamp = boss_mq:now("new-messages"),
    {ok, [{messages, Messages}, {timestamp, Timestamp}]}.