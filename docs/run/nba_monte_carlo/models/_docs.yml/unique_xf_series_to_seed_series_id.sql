select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    series_id as unique_field,
    count(*) as n_records

from "main"."main"."xf_series_to_seed"
where series_id is not null
group by series_id
having count(*) > 1



      
    ) dbt_internal_test