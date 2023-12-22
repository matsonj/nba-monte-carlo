SELECT 
    team,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'top six seed'),0) as top_six_pct1,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'play in'),0) as play_in_pct1,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'missed playoffs'),0) as missed_playoffs_pct1
FROM ${playoff_wins}
GROUP BY ALL