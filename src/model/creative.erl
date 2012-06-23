-module(creative, [Id, Name, Url, Size]).
-compile(export_all).

validation_tests()->
[
    {fun() -> length(Name) > 0 end,
    "Link must be provided"},
    {fun() -> length(Url) > 0 end,
    "Url must be provided"},
    {fun() -> length(Size) > 0 end,
    "Size must be provided"}
].