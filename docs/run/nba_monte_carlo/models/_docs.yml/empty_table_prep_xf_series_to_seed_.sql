select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main"."prep_xf_series_to_seed"
    HAVING COUNT(*) = 0


      
    ) dbt_internal_test