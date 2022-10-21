
  create view "main_prep"."prep_xf_series_to_seed__dbt_tmp" as (
    

SELECT *
FROM "main"."raw"."xf_series_to_seed"
  );
