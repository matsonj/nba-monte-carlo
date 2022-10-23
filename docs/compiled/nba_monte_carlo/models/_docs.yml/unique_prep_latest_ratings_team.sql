
    
    

select
    team as unique_field,
    count(*) as n_records

from "main"."main_prep"."prep_latest_ratings"
where team is not null
group by team
having count(*) > 1


