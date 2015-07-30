-module(x_plane_data).

-include("x_plane_datum_defaults.hrl").

-export_type(
    [ t/0
    ]).

-export(
    [ of_bin/1
    ]).

-type parsing_error() ::
      packet_unrecognized
    | packet_length_invalid
    | x_plane_datum:parsing_error()
    .

-type t() ::
    [x_plane_datum:t()].

-define(BYTE_SIZE_OF_EACH_BLOCK, 36).

-spec of_bin(binary()) ->
    hope_result:t(t(), parsing_error()).
of_bin(<<Packet/binary>>) ->
    of_bin(Packet, ?DEFAULT_MAX_INDEX).

-spec of_bin(binary(), non_neg_integer()) ->
    hope_result:t(t(), parsing_error()).
of_bin(<<"DATA", _PacketIndexByte:1/bytes, ContiguousBlocks/binary>>, MaxIndex) ->
    % Packet index byte seems to be changing from X-Plane version to verion.
    % What is it's meaning?
    if byte_size(ContiguousBlocks) rem ?BYTE_SIZE_OF_EACH_BLOCK =:= 0 ->
            Blocks = blocks_split(ContiguousBlocks),
            ParseBlock = fun (B) -> x_plane_datum:of_bin(B, MaxIndex) end,
            hope_list:map_result(Blocks, ParseBlock)
    ;  true ->
            {error, packet_length_invalid}
    end;
of_bin(<<_/binary>>, _) ->
    {error, packet_unrecognized}.

-spec blocks_split(binary()) ->
    [binary()].
blocks_split(<<>>) ->
    [];
blocks_split(<<Block:?BYTE_SIZE_OF_EACH_BLOCK/bytes, Blocks/binary>>) ->
    [Block | blocks_split(Blocks)].
