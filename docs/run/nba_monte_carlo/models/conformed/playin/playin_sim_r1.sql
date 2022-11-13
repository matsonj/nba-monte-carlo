create or replace view "main"."playin_sim_r1__dbt_int" as (
        select * from '/tmp/data_catalog/conformed/playin_sim_r1.parquet'
    );