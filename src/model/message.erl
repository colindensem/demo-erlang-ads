-module(message, [Id, MessageText]).
-compile(export_all).

validation_tests() ->
[
  {fun() -> length(MessageText) > 0 end,
    "Message must be provided"},
  {fun() -> length(MessageText) =< 140 end,
    "Message must be less than 140 characters"}
].

before_create() ->
  ModifiedRecord = set(message_text,
    re:replace(MessageText, "masticate","chew", [{return, list}])),
  {ok, ModifiedRecord}.

%after_create()->
%    boss_mq:push("new-messages", THIS).