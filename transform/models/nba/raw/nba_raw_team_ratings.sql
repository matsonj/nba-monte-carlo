{{
    config(
        materialized='external',
        location="../data/data_catalog/raw/{{this.name}}.parquet"
    )
}}

SELECT *
FROM {{ source( 'nba', 'nba_team_ratings' ) }}
