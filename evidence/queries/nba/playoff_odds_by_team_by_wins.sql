SELECT
    winning_team as team,
    wins as wins,
    conf,
    count(*) / 10000.0 as odds_pct1,
    case when season_rank <= 6 then 'top six seed'
        when season_rank between 7 and 10 then 'play in'
        else 'missed playoffs'
    end as season_result,
    Count(*) FILTER (WHERE season_rank <=6)*-1 AS sort_key
FROM src_reg_season_end
GROUP BY ALL
ORDER BY sort_key