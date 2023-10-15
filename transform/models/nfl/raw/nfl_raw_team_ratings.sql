{{
    config(
        materialized='external',
        location="../data/data_catalog/prep/{{this.name}}.parquet"
    )
}}


SELECT 
    "Team" as team,
    "Team_short" as team_short,
    "Win Total" as win_total,
    "ELO rating" as elo_rating,
    "Conf" as conf,
    "Division" as division
FROM {{ source( 'nfl', 'nfl_team_ratings' ) }}