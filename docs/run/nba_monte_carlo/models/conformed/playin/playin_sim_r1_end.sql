create or replace view "main"."playin_sim_r1_end__dbt_int" as (
        select * from '/tmp/data_catalog/conformed/playin_sim_r1_end.parquet'
    );