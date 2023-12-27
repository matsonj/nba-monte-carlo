SELECT
    winning_team as team,
    conf,
    count(*) / 10000.0 as odds_pct1,
    case when season_rank = 1 then 'first round bye'
        when season_rank between 2 and 7 then 'made playoffs'
        else 'missed playoffs'
    end as season_result,
    Count(*) FILTER (WHERE season_rank <=1) * 10000 + COUNT(*) FILTER (WHERE season_rank <=7) AS sort_key
FROM src_nfl_reg_season_end
GROUP BY ALL
ORDER BY sort_key desc
