select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select elo_rating
from "main"."main"."ratings"
where elo_rating is null



      
    ) dbt_internal_test