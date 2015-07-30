-record(x_plane_datum_speeds,
    { vind_kias   :: float() % 1
    , vind_keas   :: float() % 2
    , vtrue_ktas  :: float() % 3
    , vtrue_ktgs  :: float() % 4
                             % 5
    , vind_mph    :: float() % 6
    , vtrue_mphas :: float() % 7
    , vtrue_mphgs :: float() % 8
    }).

-record(x_plane_datum_pitch_roll_heading,
    { pitch_deg  :: float()  % 1
    , roll_deg   :: float()  % 2
    , hding_true :: float()  % 3
    , hding_mag  :: float()  % 4
                             % 5
                             % 6
                             % 7
                             % 8
    }).

-record(x_plane_datum_lat_lon_alt,
    { lat_deg   :: float() % 1
    , lon_deg   :: float() % 2
    , alt_ftmsl :: float() % 3
    , alt_ftagl :: float() % 4
    , on_runwy  :: float() % 5
    , alt_ind   :: float() % 6
    , lat_south :: float() % 7
    , lon_west  :: float() % 8
    }).
