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
{ok, {Index, Groups}} = x_plane_data_raw:of_bin(XPlaneDataPacket),
```

### Access parsed data

```erlang
% Speeds are in group 3
{3, Speeds} = lists:keyfind(3, 1, Groups),
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
{17, PitchRollHeadings} = lists:keyfind(17, 1, Groups),
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

Data format references
----------------------

- http://b58.svglobe.com/data.html
- http://www.nuclearprojects.com/xplane/xplaneref.html
