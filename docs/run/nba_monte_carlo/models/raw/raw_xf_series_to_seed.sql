
  create view "main"."raw_xf_series_to_seed__dbt_tmp" as (
    

SELECT *
FROM "main"."psa"."xf_series_to_seed"
  );
