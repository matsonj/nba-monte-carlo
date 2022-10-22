select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select team
from "main"."main"."teams"
where team is null



      
    ) dbt_internal_test