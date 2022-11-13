create or replace view "main"."season_summary__dbt_int" as (
        select * from '/tmp/data_catalog/conformed/season_summary.parquet'
    );