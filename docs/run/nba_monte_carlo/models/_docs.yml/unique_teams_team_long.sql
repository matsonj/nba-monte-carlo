select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    team_long as unique_field,
    count(*) as n_records

from "main"."main"."teams"
where team_long is not null
group by team_long
having count(*) > 1



      
    ) dbt_internal_test