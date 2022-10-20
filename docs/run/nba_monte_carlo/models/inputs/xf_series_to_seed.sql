
  create view "main"."xf_series_to_seed__dbt_tmp" as (
    





SELECT
    series_id,
    seed

FROM "main"."main"."raw_xf_series_to_seed"

  );
