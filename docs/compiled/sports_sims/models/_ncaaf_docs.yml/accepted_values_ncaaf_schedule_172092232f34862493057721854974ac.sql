
    
    

with all_values as (

    select
        type as value_field,
        count(*) as n_records

    from "mdsbox"."main"."ncaaf_schedules"
    group by type

)

select *
from all_values
where value_field not in (
    'reg_season','playin_r1','playin_r2','playoffs_r1','playoffs_r2','playoffs_r3','playoffs_r4'
)


