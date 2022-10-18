{% if target.name == 'parquet' %}
{{
  config(
    materialized = "ephemeral"
) }}
{% endif %}

{% if target.name != 'parquet' %}
{{
  config(
    materialized = "view"
) }}
{% endif %}

SELECT
    S.key::int AS game_id,
    S.type,
    S.series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
{% if target.name == 'parquet' %}
FROM '/tmp/storage/raw_schedule/*.parquet' S
{% elif target.name != 'parquet' %}
FROM {{ source( 'nba', 'raw_schedule' ) }} S
{% endif %}
LEFT JOIN {{ ref( 'ratings' ) }} V ON V.team_long = S.visitorneutral
LEFT JOIN {{ ref( 'ratings' ) }} H ON H.team_long = S.homeneutral
WHERE S.type = 'reg_season'
GROUP BY ALL
UNION ALL
SELECT
    S.key::int AS game_id,
    S.type,
    S.series_id,
    NULL AS visiting_conf,
    S.visitorneutral AS visiting_team,
    NULL AS visiting_team_elo_rating,
    NULL AS home_conf,
    S.homeneutral AS home_team,
    NULL AS home_team_elo_rating
{% if target.name == 'parquet' %}
FROM '/tmp/storage/raw_schedule/*.parquet' AS S
{% elif target.name != 'parquet' %}
FROM {{ source( 'nba', 'raw_schedule' ) }} S
{% endif %}
WHERE S.type <> 'reg_season'
GROUP BY ALL
