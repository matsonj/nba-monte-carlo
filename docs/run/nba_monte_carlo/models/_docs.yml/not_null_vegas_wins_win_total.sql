select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select win_total
from "main"."main"."vegas_wins"
where win_total is null



      
    ) dbt_internal_test