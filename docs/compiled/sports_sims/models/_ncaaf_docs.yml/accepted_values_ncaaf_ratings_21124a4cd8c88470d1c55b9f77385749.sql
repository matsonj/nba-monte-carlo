
    
    

with all_values as (

    select
        conf as value_field,
        count(*) as n_records

    from "mdsbox"."main"."ncaaf_ratings"
    group by conf

)

select *
from all_values
where value_field not in (
    'SEC (East)','SEC (West)','Big Ten (East)','ACC','CUSA','Big 12','Pac-12','American','MWC','Ind','Big Ten (West)','Sun Belt (East)','Sun Belt (West)','MAC (East)','MAC (West)','Other'
)


