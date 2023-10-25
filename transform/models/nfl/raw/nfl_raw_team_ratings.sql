{{
    config(
        materialized='external',
        location="{{ env_var('MELTANO_PROJECT_ROOT') }}/data/data_catalog/raw/{{this.name}}.parquet"
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
