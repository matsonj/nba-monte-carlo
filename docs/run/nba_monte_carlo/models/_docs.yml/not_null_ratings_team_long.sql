select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select team_long
from "main"."main"."ratings"
where team_long is null



      
    ) dbt_internal_test