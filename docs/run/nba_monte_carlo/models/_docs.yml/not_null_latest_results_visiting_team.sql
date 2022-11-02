select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



with __dbt__cte__raw_nba_elo_latest as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_elo_latest/*.parquet'
),  __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM __dbt__cte__raw_nba_elo_latest
GROUP BY ALL
),  __dbt__cte__latest_results as (
SELECT
    (_smart_source_lineno - 1)::int AS game_id,
    team1 AS home_team, 
    score1 AS home_team_score,
    team2 AS visiting_team,
    score2 AS visiting_team_score,
    date,
    CASE 
        WHEN score1 > score2 THEN team1
        ELSE team2
    END AS winning_team,
    CASE 
        WHEN score1 > score2 THEN team2
        ELSE team1
    END AS losing_team,
    True AS include_actuals
FROM __dbt__cte__prep_nba_elo_latest
WHERE score1 IS NOT NULL
GROUP BY ALL
)select visiting_team
from __dbt__cte__latest_results
where visiting_team is null



      
    ) dbt_internal_test