{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT *
FROM {{ "'s3://datalake/psa/team_ratings/*.parquet'" }}