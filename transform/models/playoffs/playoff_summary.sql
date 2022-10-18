-- depends-on: {{ ref( 'initialize_seeding' ) }}
-- depends-on: {{ ref( 'playoff_sim_r1' ) }}
-- depends-on: {{ ref( 'playoff_sim_r2' ) }}
-- depends-on: {{ ref( 'playoff_sim_r3' ) }}
-- depends-on: {{ ref( 'playoff_sim_r4' ) }}

{% if target.name == 'parquet' %}
{{
    config(
        materialized = "ephemeral"
) }}
{% elif target.name != 'parquet' %}
{{
    config(
        materialized = "view"
) }}
{% endif %}


WITH cte_playoffs_r1 AS (
    SELECT
        winning_team,
        COUNT(1) AS made_playoffs
    {% if target.name == 'parquet' %}
    FROM '/tmp/storage/initialize_seeding.parquet'
    {% elif target.name != 'parquet' %}
    FROM {{ ref( 'initialize_seeding' ) }}
    {% endif %}
    GROUP BY ALL
),

cte_playoffs_r2 AS (
    SELECT
        winning_team,
        COUNT(1) AS made_conf_semis
    {% if target.name == 'parquet' %}
    FROM '/tmp/storage/playoff_sim_r1.parquet'
    {% elif target.name != 'parquet' %}
    FROM {{ ref( 'playoff_sim_r1' ) }}
    {% endif %}
    GROUP BY ALL
),

cte_playoffs_r3 AS (
        SELECT winning_team,
        COUNT(1) AS made_conf_finals
    {% if target.name == 'parquet' %}
    FROM '/tmp/storage/playoff_sim_r2.parquet'
    {% elif target.name != 'parquet' %}
    FROM {{ ref( 'playoff_sim_r2' ) }}
    {% endif %}
    GROUP BY ALL
),

cte_playoffs_r4 AS (
        SELECT winning_team,
        COUNT(1) AS made_finals
    {% if target.name == 'parquet' %}
    FROM '/tmp/storage/playoff_sim_r3.parquet'
    {% elif target.name != 'parquet' %}
    FROM {{ ref( 'playoff_sim_r3' ) }}
    {% endif %}
    GROUP BY ALL
),

cte_playoffs_finals AS (
        SELECT winning_team,
        COUNT(1) AS won_finals
    {% if target.name == 'parquet' %}
    FROM '/tmp/storage/playoff_sim_r4.parquet'
    {% elif target.name != 'parquet' %}
    FROM {{ ref( 'playoff_sim_r4' ) }}
    {% endif %}
    GROUP BY ALL
)

SELECT
    T.team,
    R1.made_playoffs,
    R2.made_conf_semis,
    R3.made_conf_finals,
    R4.made_finals,
    F.won_finals
FROM {{ ref( 'teams' ) }} T
LEFT JOIN cte_playoffs_r1 R1 ON R1.winning_team = T.team
LEFT JOIN cte_playoffs_r2 R2 ON R2.winning_team = T.team
LEFT JOIN cte_playoffs_r3 R3 ON R3.winning_team = T.team
LEFT JOIN cte_playoffs_r4 R4 ON R4.winning_team = T.team
LEFT JOIN cte_playoffs_finals F ON F.winning_team = T.team
