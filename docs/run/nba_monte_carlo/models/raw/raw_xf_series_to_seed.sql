
  create view "main"."raw_xf_series_to_seed__dbt_tmp" as (
    

SELECT *
FROM '/tmp/data_catalog/psa/xf_series_to_seed/*.parquet'
  );
