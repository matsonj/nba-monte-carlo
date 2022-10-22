select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select seed
from "main"."main"."xf_series_to_seed"
where seed is null



      
    ) dbt_internal_test