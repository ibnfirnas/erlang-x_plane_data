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
