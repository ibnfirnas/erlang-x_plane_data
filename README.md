[![Build Status](https://travis-ci.org/ibnfirnas/erlang-x_plane_data.svg?branch=master)](https://travis-ci.org/ibnfirnas/erlang-x_plane_data)

X-Plane UDP data parser
=======================

Examples
--------

### Receive data packet

```erlang
{ok, Socket} = gen_udp:open(Port, [binary, {active, false}]),
{ok, {_, _, <<XPlaneDataPacket/binary>>}} = gen_udp:recv(Socket, 0),
```

### Parse data packet

```erlang
{ok, {64=Index, GroupsRaw}=DataRaw} = x_plane_data_raw:of_bin(XPlaneDataPacket),
```

### Access parsed data

#### Raw

At this stage, only the structure of the packet was parsed. No attempt at
interpreting the values have been made:

```erlang
% Speeds are in group 3
{3, Speeds} = lists:keyfind(3, 1, GroupsRaw),
{ VindKias
, VindKeas
, VtrueKtas
, VtrueKtgs
, _
, VindMph
, VtrueMphas
, VtrueMphgs
} = Speeds,

% Pitch roll and headings values are in group 17
{17, PitchRollHeadings} = lists:keyfind(17, 1, GroupsRaw),
{ PitchDeg
, RollDeg
, HdingTrue
, HdingMag
, _
, _
, _
, _
} = PitchRollHeadings,
```

#### Named

Here we identify what each of the numbered groups mean in a given X-Plane
version. Right now only X-Plane 10 is supported and I only identified 3 groups
so far:

| packet index | group index | group name           |
|--------------|-------------|----------------------|
| 64           | 3           | `speeds`             |
| 64           | 17          | `pitch_roll_heading` |
| 64           | 20          | `lat_lon_alt`        |

Unidentified groups (with index other than what is listed above) will be
absent from the list of named groups (think of `x_plane_data_named:of_raw/1` as
a filter), so you'll have to access their raw version, if needed.

##### Identify
```erlang
{ok, {x_plane_data_v10, GroupsNamed}} = x_plane_data_named:of_raw(DataRaw),
```

##### Access
```erlang
-include_lib("x_plane_data_group_lat_lon_alt.hrl").
-include_lib("x_plane_data_group_pitch_roll_heading.hrl").
-include_lib("x_plane_data_group_speeds.hrl").

...

{speeds, #x_plane_data_group_speeds
    { vind_kias   = VindKias
    , vind_keas   = VindKeas
    , vtrue_ktas  = VtrueKtas
    , vtrue_ktgs  = VtrueKtgs
    , vind_mph    = VindMph
    , vtrue_mphas = VtrueMphas
    , vtrue_mphgs = VtrueMphgs
    }
} = lists:keyfind(speeds, 1, GroupsNamed),

{pitch_roll_heading, #x_plane_data_group_pitch_roll_heading
    { pitch_deg  = PitchDeg
    , roll_deg   = RollDeg
    , hding_true = HdingTrue
    , hding_mag  = HdingMag
    }
} = lists:keyfind(pitch_roll_heading, 1, GroupsNamed),
```

Data format references
----------------------

- http://b58.svglobe.com/data.html
- http://www.nuclearprojects.com/xplane/xplaneref.html
