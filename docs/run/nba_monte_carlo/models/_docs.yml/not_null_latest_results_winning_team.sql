select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select winning_team
from "main"."main"."latest_results"
where winning_team is null



      
    ) dbt_internal_test