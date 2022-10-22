select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    game_id as unique_field,
    count(*) as n_records

from "main"."main"."schedules"
where game_id is not null
group by game_id
having count(*) > 1



      
    ) dbt_internal_test