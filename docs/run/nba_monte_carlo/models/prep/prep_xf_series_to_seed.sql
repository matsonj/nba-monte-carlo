
  create view "main"."prep_xf_series_to_seed__dbt_tmp" as (
    

SELECT *
FROM "main"."main"."raw_xf_series_to_seed"
GROUP BY ALL
  );
