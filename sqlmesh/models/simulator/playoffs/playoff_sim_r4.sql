MODEL (
  name nba.playoff_sim_r4,
  kind VIEW
);

JINJA_QUERY_BEGIN;
WITH cte_playoff_sim AS (
    {{ playoff_sim('nba.playoffs_r4','nba.playoff_sim_r3' ) }}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }};
JINJA_END;