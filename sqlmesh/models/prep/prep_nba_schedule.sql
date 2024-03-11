MODEL (
  name nba.prep_schedule,
  kind FULL 
);

SELECT 
    id,
    type,
    CASE WHEN type = 'reg_season' THEN
    strptime("Year"::int || "Date",'%Y %b %-d')::date 
    ELSE NULL END AS "date",
    "Start (ET)",
    "Visitor/Neutral" as "VisTm",
    "Home/Neutral" as "HomeTm",
    "Attend.",
    arena,
    notes,
    series_id
FROM nba.raw_schedule;