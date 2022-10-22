select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main"."reg_season_schedule"
    HAVING COUNT(*) = 0


      
    ) dbt_internal_test