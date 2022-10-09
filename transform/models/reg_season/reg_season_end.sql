{{
  config(
    materialized = "table"
) }}

WITH cte_wins AS (
  SELECT S.scenario_id, 
      S.winning_team,
      R.conf,
      COUNT(1) as wins
  FROM {{ ref( 'reg_season_simulator' ) }} S
    LEFT JOIN {{ ref( 'ratings' ) }} R ON R.team = S.winning_team
  GROUP BY ALL
),
cte_ranked_wins AS (
  SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY scenario_id, conf ORDER BY wins DESC, winning_team DESC ) as season_rank
  FROM cte_wins
  --no tiebreaker, so however row number handles order ties will need to be dealt with
),
cte_made_playoffs AS (
  SELECT *,
    CASE WHEN season_rank <= 10 THEN 1
      ELSE 0 
    END AS made_playoffs,
    CASE WHEN season_rank BETWEEN 7 AND 10 THEN 1
      ELSE 0
    END AS made_play_in,
    conf || '-' || season_rank::text AS seed
  FROM cte_ranked_wins 
)
SELECT * FROM cte_made_playoffs
