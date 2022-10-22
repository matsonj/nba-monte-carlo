select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select team
from "main"."main"."vegas_wins"
where team is null



      
    ) dbt_internal_test