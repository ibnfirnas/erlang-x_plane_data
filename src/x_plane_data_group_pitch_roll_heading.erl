-module(x_plane_data_group_pitch_roll_heading).

-include("include/x_plane_data_group_pitch_roll_heading.hrl").

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
of_raw_values_v10({V1, V2, V3, V4, _, _, _, _}) ->
    ?T
    { pitch_deg  = V1
    , roll_deg   = V2
    , hding_true = V3
    , hding_mag  = V4
    }.
