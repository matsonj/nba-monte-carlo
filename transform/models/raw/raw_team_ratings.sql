{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT *
FROM {{ "'s3://datalake/psa/team_ratings/*.parquet'" if target.name == 'parquet' 
    else source('nba', 'team_ratings' ) }}