-- Execute with: dbt run-operation elo_rollforward --args '{"dry_run": True}'
-- to run the job, run w/o the args

{% macro elo_rollforward(dry_run='false') %}

-- get the schedule loaded (will loop through this)
{% set sql_statement %}
    SELECT
        S.game_id,
        S.visiting_team,
        S.home_team,
        LR.winning_team,
        CASE
            WHEN LR.winning_team = S.visiting_team THEN 0
            ELSE 1
        END AS game_result
    FROM {{ ref( 'schedules' ) }} S
    JOIN {{ ref( 'latest_results' ) }} LR ON LR.game_id = S.game_id AND LR.include_actuals = true
    ORDER BY S.game_id
{% endset %}
{% do log(sql_statement, info=True) %}

-- load elo ratings into a temporary table
{% set temp_ratings %}
    CREATE OR REPLACE TEMPORARY TABLE workings_ratings AS (
        SELECT team, elo_rating, elo_rating AS original_rating
        FROM {{ ref( 'prep_team_ratings' ) }}
    )
{% endset %}
{% do run_query(temp_ratings) %}
{% do log(temp_ratings, info=True) %}

{%- set updates = run_query(sql_statement) -%}

{% for i in updates.rows  -%}
    {% set game %}
        SELECT 
            {{ i[0] }} AS game_id,
            '{{ i[1] }}' AS visiting_team,
            RV.elo_rating,
           '{{ i[2] }}' AS home_team,
            RH.elo_rating,
            '{{ i[3] }}' AS winning_team,
            {{ i[4] }} AS result
        FROM workings_ratings RH
            LEFT JOIN workings_ratings RV ON RV.team = '{{ i[1] }}'
        WHERE RH.team = '{{ i[2] }}'
    {% endset %}
    {% set workings_game = run_query(game) %}
    {% do log(game, info=True) %}
    {% for j in workings_game.rows %}
        {% set update_proc %}
            UPDATE workings_ratings
                SET elo_rating = elo_rating + {{ elo_diff( j[4] , j[2] , j[6] ) }}
                WHERE team = '{{ j[3] }}';
            UPDATE workings_ratings
                SET elo_rating = elo_rating - {{ elo_diff( j[4] , j[2] , j[6] ) }}
                WHERE team = '{{ j[1] }}';
        {% endset %}
        {%- do log("running update below...", info=True)  -%}
        {% do log(update_proc, info=True) %}
        {% if dry_run == 'false' %}
            {% do run_query(update_proc) %}
        {% endif %}
    {% endfor %}
    {% set update_proc = true %}
{% endfor %} 
{% set output %}
    CREATE OR REPLACE TABLE raw.elo_post AS (
        SELECT *
        FROM workings_ratings
    )
{% endset %}
{% do run_query(output) %}
{% do log("elo rollforward completed", info=True) %}
{% endmacro %}
