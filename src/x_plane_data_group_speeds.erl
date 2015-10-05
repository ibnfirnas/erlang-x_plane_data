-module(x_plane_data_group_speeds).

-include("include/x_plane_data_group_speeds.hrl").

-export_type(
    [ t/0
    ]).

-export(
    [ of_raw_values_v10/1
    ]).

-define(T, #?MODULE).

-type t() ::
    ?T{}.

-spec of_raw_values_v10(x_plane_data_raw:group_values()) ->
    t().
of_raw_values_v10({V1, V2, V3, V4, _, V6, V7, V8}) ->
    ?T
    { vind_kias   = V1
    , vind_keas   = V2
    , vtrue_ktas  = V3
    , vtrue_ktgs  = V4

    , vind_mph    = V6
    , vtrue_mphas = V7
    , vtrue_mphgs = V8
    }.
