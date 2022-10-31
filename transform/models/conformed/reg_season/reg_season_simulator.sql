-- depends-on: {{ ref( 'random_num_gen' ) }}

{{
    config(
      materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT 
    R.scenario_id,
    S.*,
    {{ elo_calc( 'S.home_team_elo_rating', 'S.visiting_team_elo_rating' ) }} as home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN LR.include_actuals = true THEN LR.winning_team
        WHEN {{ elo_calc( 'S.home_team_elo_rating', 'S.visiting_team_elo_rating' ) }}  >= R.rand_result THEN S.home_team
        ELSE S.visiting_team
    END AS winning_team,
    COALESCE(LR.include_actuals, false) AS include_actuals
FROM {{ ref( 'schedules' ) }} S
LEFT JOIN {{ "'s3://datalake/conformed/random_num_gen.parquet'" if target.name == 'parquet'
        else ref( 'random_num_gen' ) }} R ON R.game_id = S.game_id
LEFT JOIN {{ ref( 'latest_results' ) }} LR ON LR.game_id = S.game_id
WHERE S.type = 'reg_season'
