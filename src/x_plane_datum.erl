-module(x_plane_datum).

-include("x_plane_datum_defaults.hrl").
-include("include/x_plane_data.hrl").

-export_type(
    [ t/0
    , label/0
    , anonymous/0
    , identified/0
    , parsing_error/0
    ]).

-export(
    [ of_bin/1  % Use default max index
    , of_bin/2  % Specify max index
    ]).

-type parsing_error() ::
      {block_structure_invalid, binary()}
    | {block_index_byte_out_of_range, anonymous()}
    .

-type anonymous() ::
    { non_neg_integer()
    , float()
    , float()
    , float()
    , float()
    , float()
    , float()
    , float()
    , float()
    }.

-type label() ::
      speeds
    | pitch_roll_heading
    | lat_lon_alt
    .

-type identified() ::
      #x_plane_datum_speeds{}
    | #x_plane_datum_pitch_roll_heading{}
    | #x_plane_datum_lat_lon_alt{}
    .

-type t() ::
      {non_neg_integer() , anonymous()}
    | {label()           , identified()}
    .

-spec of_bin(binary()) ->
    hope_result:t(t(), parsing_error()).
of_bin(<<Block/binary>>) ->
    of_bin(Block, ?DEFAULT_MAX_INDEX).

-spec of_bin(binary(), non_neg_integer()) ->
    hope_result:t(t(), parsing_error()).
of_bin(<<Block/binary>>, MaxIndex) ->
    case anonymous_of_bin(Block, MaxIndex)
    of {ok, Anonymous} ->
            IdentifiedOrIndexed = identify_or_index(Anonymous),
            {ok, IdentifiedOrIndexed}
    ;   {error, _}=Error ->
            Error
    end.

-spec anonymous_of_bin(binary(), non_neg_integer()) ->
    hope_result:t(anonymous(), parsing_error()).
anonymous_of_bin(
    << Index:32/little-integer
     ,    V1:32/little-float
     ,    V2:32/little-float
     ,    V3:32/little-float
     ,    V4:32/little-float
     ,    V5:32/little-float
     ,    V6:32/little-float
     ,    V7:32/little-float
     ,    V8:32/little-float
    >>,
    MaxIndex
) ->
    Anonymous = {Index, V1, V2, V3, V4, V5, V6, V7, V8},
    if Index > 0 andalso Index =< MaxIndex ->
        {ok, Anonymous}
    ;  true ->
        {error, {block_index_byte_out_of_range, Anonymous}}
    end;
anonymous_of_bin(<<Block/binary>>, _) ->
    % This case shouldn't be possible with a correct packet length, but we want
    % to allow for possibility of using this module independently of it's
    % parent, data module.
    {error, {block_structure_invalid, Block}}.

-spec identify_or_index(anonymous()) ->
    t().
identify_or_index({3, V1, V2, V3, V4, _, V6, V7, V8}) ->
    Datum =
        #x_plane_datum_speeds
        { vind_kias   = V1
        , vind_keas   = V2
        , vtrue_ktas  = V3
        , vtrue_ktgs  = V4

        , vind_mph    = V6
        , vtrue_mphas = V7
        , vtrue_mphgs = V8
        },
    {speeds, Datum};
identify_or_index({17, V1, V2, V3, V4, _, _, _, _}) ->
    Datum =
        #x_plane_datum_pitch_roll_heading
        { pitch_deg  = V1
        , roll_deg   = V2
        , hding_true = V3
        , hding_mag  = V4
        },
    {pitch_roll_heading, Datum};
identify_or_index({20, V1, V2, V3, V4, V5, V6, V7, V8}) ->
    Datum =
        #x_plane_datum_lat_lon_alt
        { lat_deg   = V1
        , lon_deg   = V2
        , alt_ftmsl = V3
        , alt_ftagl = V4
        , on_runwy  = V5
        , alt_ind   = V6
        , lat_south = V7
        , lon_west  = V8
        },
    {lat_lon_alt, Datum};
identify_or_index({Index, _, _, _, _, _, _, _, _}=Anonymous) ->
    {Index, Anonymous}.
