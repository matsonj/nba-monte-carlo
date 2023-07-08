-- Execute with: dbt run-operation elo_rollforward --args '{"dry_run": True}'
-- to run the job, run w/o the args

{% macro elo_rollforward(dry_run='false') %}

-- get the schedule loaded (will loop through this)
{% set sql_statement %}
    SELECT
        (S._smart_source_lineno - 1) AS game_id,
        S.team2 AS visiting_team,
        S.team1 AS home_team,
        CASE WHEN score1 > score2 THEN team1 ELSE team2 END AS winning_team,
        CASE
            WHEN score2 > score1 THEN 1
            ELSE 0
        END AS game_result
    FROM '{{ env_var('MELTANO_PROJECT_ROOT') }}/data/data_catalog/psa/nba_elo_latest/*.parquet' S
    WHERE score1 IS NOT NULL 
        --TEMPORARILY FILTER THIS OUT
        AND 1=0
    GROUP BY ALL
    ORDER BY S._smart_source_lineno
{% endset %}
{% do log(sql_statement, info=False) %}

{% set log_table %}
    CREATE OR REPLACE TABLE results_log(
        game_id INTEGER, 
        visiting_team VARCHAR(3), 
        visiting_team_elo_rating REAL,
        home_team VARCHAR(3),
        home_team_elo_rating REAL,
        winning_team VARCHAR(3),
        elo_change REAL
    )
{% endset %}
{% do log(log_table, info=True) %}
{% do run_query(log_table) %}

-- load elo ratings into a temporary table
{% set temp_ratings %}
    CREATE OR REPLACE TEMPORARY TABLE workings_ratings AS (
        SELECT team, elo_rating::real as elo_rating, elo_rating::real AS original_rating
        FROM  '{{ env_var('MELTANO_PROJECT_ROOT') }}/data/data_catalog/psa/team_ratings/*.parquet'
        GROUP BY ALL
    )
{% endset %}
{% do run_query(temp_ratings) %}
{% do log(temp_ratings, info=False) %}

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
    {% do log(game, info=False) %}
    {% for j in workings_game.rows %}
        {% set update_proc %}
            UPDATE workings_ratings
                SET elo_rating = elo_rating - {{ elo_diff( j[4] , j[2] , j[6] ) }}
                WHERE team = '{{ j[3] }}';
            UPDATE workings_ratings
                SET elo_rating = elo_rating + {{ elo_diff( j[4] , j[2] , j[6] ) }}
                WHERE team = '{{ j[1] }}';
            INSERT INTO results_log VALUES 
                ({{ j[0] }},
                '{{ j[1] }}',
                {{ j[2] }},
                '{{ j[3] }}',
                {{ j[4] }},
                '{{ j[5] }}',
                {{ elo_diff( j[4] , j[2] , j[6] ) }});
        {% endset %}
        {%- do log("Running Update Statement for game_id " ~ i[0] ~ ".", info=True)  -%}
        {% do log(update_proc, info=False) %}
         {% if dry_run == 'false' %}
            {% do run_query(update_proc) %}
        {% endif %}
    {% endfor %}
    {% set update_proc = true %}
{% endfor %} 
-- NOTE: because we are using duckdb in-memory, need to explicity materialize our result tables
{% set output %}
    COPY (SELECT * FROM workings_ratings ) TO '{{ env_var('MELTANO_PROJECT_ROOT') }}/data/data_catalog/prep/elo_post.parquet' (FORMAT 'parquet', CODEC 'ZSTD');
    COPY (SELECT * FROM results_log) TO '{{ env_var('MELTANO_PROJECT_ROOT') }}/data/data_catalog/prep/results_log.parquet' (FORMAT 'parquet', CODEC 'ZSTD');
{% endset %}
{% do log(output, info=True) %}
{% do run_query(output) %}
{% do log("elo rollforward completed", info=True) %}
{% endmacro %}
