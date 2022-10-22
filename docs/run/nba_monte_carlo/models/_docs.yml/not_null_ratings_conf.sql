select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select conf
from "main"."main"."ratings"
where conf is null



      
    ) dbt_internal_test