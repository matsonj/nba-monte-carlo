select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select visting_team_score
from "main"."main"."latest_results"
where visting_team_score is null



      
    ) dbt_internal_test