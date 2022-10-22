
    
    

with all_values as (

    select
        conf as value_field,
        count(*) as n_records

    from "main"."main"."ratings"
    group by conf

)

select *
from all_values
where value_field not in (
    'East','West'
)


