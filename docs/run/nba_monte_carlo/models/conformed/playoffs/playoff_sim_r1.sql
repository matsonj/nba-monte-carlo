create or replace view "main"."playoff_sim_r1__dbt_int" as (
        select * from '/tmp/data_catalog/conformed/playoff_sim_r1.parquet'
    );