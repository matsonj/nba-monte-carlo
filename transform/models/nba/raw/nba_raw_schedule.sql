SELECT 
    id,
    type,
    strptime("Year" || "Date",'%Y %b %-d')::date AS "date",
    "Start (ET)",
    "Visitor/Neutral" as "VisTm",
    "Home/Neutral" as "HomeTm",
    "Attend.",
    arena,
    notes,
    series_id
FROM {{ source( 'nba', 'nba_schedule' ) }}
