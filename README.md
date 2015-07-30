[![Build Status](https://travis-ci.org/ibnfirnas/erlang-x_plane_data.svg?branch=master)](https://travis-ci.org/ibnfirnas/erlang-x_plane_data)

X-Plane UDP data parser
=======================

Example
-------

```erlang
-include_lib("include/x_plane_data.hrl").

main(Port) ->
    {ok, Socket} = gen_udp:open(Port, [binary, {active, false}]),
    {ok, {_, _, <<XPlaneDataPacket/binary>>}} = gen_udp:recv(Socket, 0),
    {ok, XPlaneData} = x_plane_data:of_bin(XPlaneDataPacket),

    % Currently there're 133 possible data types sent by X-Plane 10, of which
    % I've identified and labeled only some of. See x_plane_datum:t() type for
    % what is currently labeled.
    % The types I've not yet labeled are in the format specified by
    % x_plane_datum:anonymous() and can be looked-up by their index number.

    % Find a labeled data type
    {some, #x_plane_datum_speeds{}} = hope_kv_list:get(XPlaneData, speeds),
    {some, #x_plane_datum_pitch_roll_heading{}} = hope_kv_list:get(XPlaneData, pitch_roll_heading),
    {some, #x_plane_datum_lat_lon_alt{}} = hope_kv_list:get(XPlaneData, lat_lon_alt),

    % Find an unlabled data type
    {some, {10, V1, V2, V3, V4, V5, V6, V7, V8}} = hope_kv_list:get(XPlaneData, 10),

    % Attempt to find a data type that was not included in current packet
    none = hope_kv_list:get(XPlaneData, 130),
    none = hope_kv_list:get(XPlaneData, 67),

    ...
```

Note: you can, of course, use any other method to search a `[{K, V}]` list
(which is how `x_plane_data:t()` is structured), such as:
`proplists:get_value/2`, `lists:keyfind/3`, etc., but I prefer the API of
`hope_kv_list`, so I used that.


Data format references
----------------------

- http://b58.svglobe.com/data.html
- http://www.nuclearprojects.com/xplane/xplaneref.html
