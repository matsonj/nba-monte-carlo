create or replace view "main"."playoff_sim_r2__dbt_int" as (
        select * from '/tmp/data_catalog/conformed/playoff_sim_r2.parquet'
    );