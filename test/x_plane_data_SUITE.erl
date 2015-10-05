-module(x_plane_data_SUITE).

-include_lib("x_plane_data_group_lat_lon_alt.hrl").
-include_lib("x_plane_data_group_pitch_roll_heading.hrl").
-include_lib("x_plane_data_group_speeds.hrl").

%% CT callbacks
-export(
    [ all/0
    , groups/0
    ]).

%% Test cases
-export(
    [ t_bin_to_raw/1
    , t_bin_to_raw_to_named/1
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
        [ t_bin_to_raw
        , t_bin_to_raw_to_named
        ],
    Properties = [parallel],
    [ {?GROUP, Properties, Tests}
    ].


%% =============================================================================
%%  Test cases
%% =============================================================================

t_bin_to_raw(_Cfg) ->
    Test =
        fun (PacketBase64) ->
            Packet = base64:decode(PacketBase64),
            {error, packet_bad_header} =
                x_plane_data_raw:of_bin(<<"bad-header", Packet/binary>>),
            {error, packet_bad_length} =
                x_plane_data_raw:of_bin(<<Packet/binary, "extra-stuff">>),
            {ok, {Index, Groups}} =
                x_plane_data_raw:of_bin(<<Packet/binary>>),
            ct:log("Index: ~p", [Index]),
            ct:log("Groups: ~p", [Groups]),
            {some, Group3 } = kv_list_find(Groups, 3),
            {some, Group17} = kv_list_find(Groups, 17),
            {some, Group20} = kv_list_find(Groups, 20),
            { 3.106105089187622
            , 6.640225887298584
            , 6.793502330780029
            , 1.0040892448159866e-5
            , -999.0
            , 3.574441909790039
            , 7.81782341003418
            , 1.1554855518625118e-5
            } = Group3,
            { 2.3310465812683105
            , 0.22457626461982727
            , 120.6203384399414
            , 133.51084899902344
            , -999.0
            , -999.0
            , -999.0
            , -999.0
            } = Group17,
            { 40.64827346801758
            , -73.81651306152344
            , 7.969515800476074
            , 0.226793110370636
            , 1.0
            , -70.99662780761719
            , 40.0
            , -75.0
            } = Group20,
            ok
        end,
    lists:foreach(Test, sample_packets_base64_encoded()).

t_bin_to_raw_to_named(_Cfg) ->
    Test =
        fun (PacketBase64) ->
            Packet = base64:decode(PacketBase64),
            {ok, DataRaw} = x_plane_data_raw:of_bin(Packet),
            ct:log("DataRaw: ~p", [DataRaw]),
            {64, _} = DataRaw,
            {ok, DataNamed} = x_plane_data_named:of_raw(DataRaw),
            ct:log("DataNamed: ~p", [DataNamed]),
            {x_plane_data_v10, Groups} = DataNamed,
            {some, #x_plane_data_group_speeds
                { vind_kias   = 3.106105089187622
                , vind_keas   = 6.640225887298584
                , vtrue_ktas  = 6.793502330780029
                , vtrue_ktgs  = 1.0040892448159866e-5
                , vind_mph    = 3.574441909790039
                , vtrue_mphas = 7.81782341003418
                , vtrue_mphgs = 1.1554855518625118e-5
                }
            } = kv_list_find(Groups, speeds),
            {some, #x_plane_data_group_pitch_roll_heading
                { pitch_deg  = 2.3310465812683105
                , roll_deg   = 0.22457626461982727
                , hding_true = 120.6203384399414
                , hding_mag  = 133.51084899902344
                }
            } = kv_list_find(Groups, pitch_roll_heading),
            {some, #x_plane_data_group_lat_lon_alt
                { lat_deg   = 40.64827346801758
                , lon_deg   = -73.81651306152344
                , alt_ftmsl = 7.969515800476074
                , alt_ftagl = 0.226793110370636
                , on_runwy  = 1.0
                , alt_ind   = -70.99662780761719
                , lat_south = 40.0
                , lon_west  = -75.0
                }
            } = kv_list_find(Groups, lat_lon_alt),
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
