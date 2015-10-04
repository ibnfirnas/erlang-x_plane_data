-module(x_plane_data_raw).

-export_type(
    [ t/0
    , index/0
    , group_index/0
    , group_values/0
    , group/0
    , groups/0
    ]).

-export(
    [ of_bin/1
    ]).

-type parsing_error() ::
      packet_bad_header
    | packet_bad_length
    .

-type group_index() ::
    non_neg_integer().

-type group_values() ::
    { float()
    , float()
    , float()
    , float()
    , float()
    , float()
    , float()
    , float()
    }.

-type group() ::
    {group_index(), group_values()}.

% Packet index byte. Essentially a schema version.
-type index() ::
    integer().

-type groups() ::
    [group()].

-type t() ::
    {index(), groups()}.

-define(BYTE_SIZE_OF_EACH_BLOCK, 36).
-define(PACKET_HEADER, "DATA").

-spec of_bin(binary()) ->
      {ok, t()}
    | {error, parsing_error()}
    .
of_bin(<<?PACKET_HEADER, _:8/integer, ContiguousBlocks/binary>>)
    when byte_size(ContiguousBlocks) rem ?BYTE_SIZE_OF_EACH_BLOCK =/= 0 ->
    {error, packet_bad_length};
of_bin(<<?PACKET_HEADER, Index:8/integer, ContiguousBlocks/binary>>) ->
    Groups = [group_of_bin(B) || B <- blocks_split(ContiguousBlocks)],
    {ok, {Index, Groups}};
of_bin(<<_/binary>>) ->
    {error, packet_bad_header}.

-spec blocks_split(binary()) ->
    [binary()].
blocks_split(<<>>) ->
    [];
blocks_split(<<Block:?BYTE_SIZE_OF_EACH_BLOCK/bytes, Blocks/binary>>) ->
    [Block | blocks_split(Blocks)].

-spec group_of_bin(binary()) ->
    group().
group_of_bin(
    << Index:32/little-integer
     ,    V1:32/little-float
     ,    V2:32/little-float
     ,    V3:32/little-float
     ,    V4:32/little-float
     ,    V5:32/little-float
     ,    V6:32/little-float
     ,    V7:32/little-float
     ,    V8:32/little-float
    >>
) ->
    Values = {V1, V2, V3, V4, V5, V6, V7, V8},
    {Index, Values}.
