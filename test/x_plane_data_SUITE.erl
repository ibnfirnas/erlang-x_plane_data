-module(x_plane_data_SUITE).

-include_lib("x_plane_data.hrl").

%% CT callbacks
-export(
    [ all/0
    , groups/0
    ]).

%% Test cases
-export(
    [ t_basic_sanity_check/1
    ]).

-define(GROUP, x_plane_data).

%% ============================================================================
%% CT callbacks
%% ============================================================================

all() ->
    [ {group, ?GROUP}
    ].

groups() ->
    Tests =
        [ t_basic_sanity_check
        ],
    Properties = [parallel],
    [ {?GROUP, Properties, Tests}
    ].


%% =============================================================================
%%  Test cases
%% =============================================================================

t_basic_sanity_check(_Cfg) ->
    Test =
        fun (PacketBase64) ->
            Packet = base64:decode(PacketBase64),
            MaxIndex = 133,
            BadIndex = MaxIndex + 1,
            FakeBlockData = list_to_binary(lists:seq(1, 32)),
            FakeBlockOk       = <<MaxIndex:32/little-integer, FakeBlockData/binary>>,
            FakeBlockBadIndex = <<BadIndex:32/little-integer, FakeBlockData/binary>>,
            {error, {block_index_byte_out_of_range, {BadIndex,_,_,_,_,_,_,_,_}}} =
                x_plane_data:of_bin(<<Packet/binary, FakeBlockBadIndex/binary>>),
            {error, packet_unrecognized} =
                x_plane_data:of_bin(<<"bad-header", Packet/binary>>),
            {error, packet_length_invalid} = 
                x_plane_data:of_bin(<<Packet/binary, "extra-stuff">>),
            {ok, Data} = 
                x_plane_data:of_bin(<<Packet/binary, FakeBlockOk/binary>>),
            {some, #x_plane_datum_speeds{}} =
                hope_kv_list:get(Data, speeds),
            {some, #x_plane_datum_pitch_roll_heading{}} =
                hope_kv_list:get(Data, pitch_roll_heading),
            {some, #x_plane_datum_lat_lon_alt{}} =
                hope_kv_list:get(Data, lat_lon_alt),
            {some, {MaxIndex,_,_,_,_,_,_,_,_}} =
                hope_kv_list:get(Data, MaxIndex),
            ok
        end,
    lists:foreach(Test, sample_packets_base64_encoded()).



%% =============================================================================
%% Sample data
%% =============================================================================

sample_packets_base64_encoded() ->
        [ <<"REFUQUADAAAAbcpGQLt81EBfZNlATnUoNwDAecSow2RAnCv6QLrbQTcRAAAA3i8VQFL3ZT6dPfFCx4IFQwDAecQAwHnEAMB5xADAecQUAAAA1ZciQg6ik8JGBv9AdDxoPgAAgD9G/o3CAAAgQgAAlsI=">>
        ].
