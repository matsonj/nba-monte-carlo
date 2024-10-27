select
    id,
    type,
    strptime("Year" || "Date", '%Y %b %-d')::date as "date",
    "Start (ET)",
    "Visitor/Neutral" as "VisTm",
    "Home/Neutral" as "HomeTm",
    "Attend.",
    arena,
    notes,
    series_id
from {{ source("nba", "nba_schedule") }}
where arena is null -- make sure playoffs are included
    or arena <> 'Placeholder' -- removing IST games w/o teams & arena
