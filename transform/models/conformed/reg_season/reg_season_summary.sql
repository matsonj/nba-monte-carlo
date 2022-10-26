-- depends-on: {{ ref( 'reg_season_end' ) }}

{{
    config(
        materialized = "view" if target.name == 'parquet' else "table",
        post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/data_catalog/conformed/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
            if target.name == 'parquet' else " "
) }}

    WITH cte_summary AS (
    SELECT
        winning_team AS team,
        E.conf,
        ROUND(AVG(wins),1) AS avg_wins,
        V.win_total AS vegas_wins,
        ROUND(AVG(V.win_total) - AVG(wins), 1) AS elo_vs_vegas,
        ROUND(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY wins ASC), 1) AS wins_5th,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY wins ASC), 1) AS wins_95th,
        COUNT(*) FILTER (WHERE made_playoffs = 1 AND made_play_in = 0) AS made_postseason,
        COUNT(*) FILTER (WHERE made_play_in = 1) AS made_play_in,
        ROUND(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY season_rank ASC), 1) AS seed_5th,
        ROUND(AVG(season_rank), 1) AS avg_seed,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY season_rank ASC), 1) AS seed_95th
    FROM {{ "'/tmp/data_catalog/conformed/reg_season_end.parquet'" if target.name == 'parquet'
            else ref( 'reg_season_end' ) }} E
    LEFT JOIN {{ ref( 'vegas_wins' ) }} V ON V.team = E.winning_team
    GROUP BY ALL
    )

SELECT 
    C.team,
    C.conf,
    A.wins || ' - ' || A.losses AS record,
    C.avg_wins,
    C.vegas_wins,
    c.elo_vs_vegas,
    C.wins_5th || ' to ' || C.wins_95th AS win_range,
    C.seed_5th || ' to ' || C.seed_95th AS seed_range,
    c.made_postseason,
    c.made_play_in
FROM cte_summary C
LEFT JOIN {{ ref( 'reg_season_actuals' ) }} A ON A.team = C.team
