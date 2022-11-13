create or replace view "main"."initialize_seeding__dbt_int" as (
        select * from '/tmp/data_catalog/conformed/initialize_seeding.parquet'
    );