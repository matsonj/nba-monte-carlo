
    
    

select
    team as unique_field,
    count(*) as n_records

from "mdsbox"."main"."vegas_wins"
where team is not null
group by team
having count(*) > 1


