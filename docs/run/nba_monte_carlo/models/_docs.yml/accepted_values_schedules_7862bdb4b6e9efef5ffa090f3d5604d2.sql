select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        type as value_field,
        count(*) as n_records

    from "main"."main"."schedules"
    group by type

)

select *
from all_values
where value_field not in (
    'reg_season','playin_r1','playin_r2','playoffs_r1','playoffs_r2','playoffs_r3','playoffs_r4'
)



      
    ) dbt_internal_test