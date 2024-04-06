MODEL (
  name nba.playoff_sim_r3,
  kind VIEW
);

JINJA_QUERY_BEGIN;
WITH cte_playoff_sim AS (
    {{ playoff_sim('nba.playoffs_r3','nba.playoff_sim_r2' ) }}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }};
JINJA_END;