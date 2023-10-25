{{
    config(
        materialized='external',
        location="{{ env_var('MELTANO_PROJECT_ROOT') }}/data/data_catalog/raw/{{this.name}}.parquet"
    )
}}

SELECT *
FROM {{ source( 'nba', 'nba_team_ratings' ) }}
