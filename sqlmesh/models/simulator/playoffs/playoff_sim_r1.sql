MODEL (
  name nba.playoff_sim_r1,
  kind VIEW
);

JINJA_QUERY_BEGIN;
WITH cte_playoff_sim AS (
    {{ playoff_sim('nba.playoffs_r1','nba.initialize_seeding' ) }}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }};
JINJA_END;