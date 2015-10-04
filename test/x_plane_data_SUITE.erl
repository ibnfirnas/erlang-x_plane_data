-module(x_plane_data_SUITE).

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
            {error, packet_bad_header} =
                x_plane_data_raw:of_bin(<<"bad-header", Packet/binary>>),
            {error, packet_bad_length} =
                x_plane_data_raw:of_bin(<<Packet/binary, "extra-stuff">>),
            {ok, {_, Groups}} =
                x_plane_data_raw:of_bin(<<Packet/binary>>),
            {some, {_, _, _, _, _, _, _, _}} = kv_list_find(Groups, 3),
            {some, {_, _, _, _, _, _, _, _}} = kv_list_find(Groups, 17),
            {some, {_, _, _, _, _, _, _, _}} = kv_list_find(Groups, 20),
            ok
        end,
    lists:foreach(Test, sample_packets_base64_encoded()).

%% =============================================================================
%% Sample data
%% =============================================================================

sample_packets_base64_encoded() ->
        [ <<"REFUQUADAAAAbcpGQLt81EBfZNlATnUoNwDAecSow2RAnCv6QLrbQTcRAAAA3i8VQFL3ZT6dPfFCx4IFQwDAecQAwHnEAMB5xADAecQUAAAA1ZciQg6ik8JGBv9AdDxoPgAAgD9G/o3CAAAgQgAAlsI=">>
        ].


%% =============================================================================
%% Helpers
%% =============================================================================

kv_list_find(KVL, K) ->
    case lists:keyfind(K, 1, KVL)
    of  false  -> none
    ;   {K, V} -> {some, V}
    end.
