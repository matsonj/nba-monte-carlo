select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select visiting_team
from "main"."main"."schedules"
where visiting_team is null



      
    ) dbt_internal_test