{{
  config(
    materialized = "ephemeral"
) }}

SELECT E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    XF.seed
FROM {{ ref( 'playoff_sim_r1' ) }} E
    LEFT JOIN {{ ref( 'xf_series_to_seed' ) }} XF ON XF.series_id = E.series_id
WHERE E.series_result = 4