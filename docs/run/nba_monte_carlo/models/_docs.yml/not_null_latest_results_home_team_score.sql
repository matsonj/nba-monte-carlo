select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select home_team_score
from "main"."main"."latest_results"
where home_team_score is null



      
    ) dbt_internal_test