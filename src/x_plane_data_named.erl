-module(x_plane_data_named).

-export_type(
    [ t/0
    , version/0
    , group/0
    ]).

-export(
    [ of_raw/1
    ]).

-type version() ::
    x_plane_data_v10.

-type group() ::
      {speeds            , x_plane_data_group_speeds:t()}
    | {pitch_roll_heading, x_plane_data_group_pitch_roll_heading:t()}
    | {lat_lon_alt       , x_plane_data_group_lat_lon_alt:t()}
    .

-type t() ::
    {version(), [group()]}.

-define(DATA_INDEX_V10, 64).

-spec of_raw(x_plane_data_raw:t()) ->
    hope_result:t(t(), unknown_x_plane_version).
of_raw({?DATA_INDEX_V10, GroupsRaw}) ->
    ConsKnownDropUnknown =
        fun (GroupRaw, Groups1) ->
            GroupOpt = v10_group_identify(GroupRaw),
            Groups2Opt = hope_option:map(GroupOpt, fun (G) -> [G | Groups1] end),
            hope_option:get(Groups2Opt, Groups1)
        end,
    GroupsNamed = lists:foldl(ConsKnownDropUnknown, [], GroupsRaw),
    T = {x_plane_data_v10, GroupsNamed},
    {ok, T};
of_raw({_, _}) ->
    {error, unknown_x_plane_version}.

-spec v10_group_identify(x_plane_data_raw:group()) ->
    hope_option:t(group()).
v10_group_identify({Index, Values}) ->
    LabAndConsOpt = v10_index_to_label_and_constructor(Index),
    hope_option:map(LabAndConsOpt, fun ({L, C}) -> {L, C(Values)} end).

v10_index_to_label_and_constructor(Index) ->
    F = of_raw_values_v10,
    case Index
    of  3  -> {some, {speeds            , fun x_plane_data_group_speeds:F/1}}
    ;   17 -> {some, {pitch_roll_heading, fun x_plane_data_group_pitch_roll_heading:F/1}}
    ;   20 -> {some, {lat_lon_alt       , fun x_plane_data_group_lat_lon_alt:F/1}}
    ;   _ -> none
    end.
