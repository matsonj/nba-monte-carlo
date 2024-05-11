select * from {{ source("nfl", "nfl_schedule") }}
