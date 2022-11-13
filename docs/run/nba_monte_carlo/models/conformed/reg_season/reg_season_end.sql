create or replace view "main"."reg_season_end__dbt_int" as (
        select * from '/tmp/data_catalog/conformed/reg_season_end.parquet'
    );