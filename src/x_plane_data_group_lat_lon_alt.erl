-module(x_plane_data_group_lat_lon_alt).

-include("include/x_plane_data_group_lat_lon_alt.hrl").

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
of_raw_values_v10({V1, V2, V3, V4, V5, V6, V7, V8}) ->
    ?T
    { lat_deg   = V1
    , lon_deg   = V2
    , alt_ftmsl = V3
    , alt_ftagl = V4
    , on_runwy  = V5
    , alt_ind   = V6
    , lat_south = V7
    , lon_west  = V8
    }.
