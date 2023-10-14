{{
    config(
        materialized='external',
        location="../data/data_catalog/prep/{{this.name}}.parquet"
    )
}}

SELECT
    Week as wk,
    "Winner/tie" as winner,
    PtsW as winner_pts,
    "Loser/tie" as loser,
    PtsL as loser_pts,
    CASE WHEN PtsL = PtsW THEN 1 ELSE 0 END as tie_flag
FROM {{ source( 'nfl','nfl_results' ) }}