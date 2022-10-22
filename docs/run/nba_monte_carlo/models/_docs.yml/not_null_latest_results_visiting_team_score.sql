select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select visiting_team_score
from "main"."main"."latest_results"
where visiting_team_score is null



      
    ) dbt_internal_test