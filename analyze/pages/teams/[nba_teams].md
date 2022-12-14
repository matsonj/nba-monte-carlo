# Detailed Analysis for <Value data={season_summary.filter(d => d.team === $page.params.nba_teams)} column=team/>

```season_summary
select *, 
    elo_vs_vegas*-1.0 as vs_vegas_num1,
    avg_wins as predicted_wins,
    (COALESCE(made_postseason,0) + COALESCE(made_play_in,0) )/ 10000.0 as made_playoffs_pct1
from reg_season_summary
```

```records_table
SELECT
    team,
    'all games' as type,
    wins,
    losses,
    wins::real / (wins+losses)::real as win_pct_num3
FROM reg_season_actuals_enriched
UNION ALL
SELECT
    team,
    'at home' as type,
    home_wins,
    home_losses,
    home_wins::real / (home_wins+home_losses)::real as win_pct_num3
FROM reg_season_actuals_enriched
UNION ALL
SELECT
    team,
    'away' as type,
    away_wins,
    away_losses,
    away_wins::real / (away_wins+away_losses)::real as win_pct_num3
FROM reg_season_actuals_enriched
UNION ALL
SELECT
    team,
    'as favorite',
    wins_as_favorite,
    losses_as_favorite,
    wins_as_favorite::real / (wins_as_favorite+losses_as_favorite)::real as pct_num3
FROM reg_season_actuals_enriched
UNION ALL
SELECT
    team,
    'as underdog',
    wins_as_underdog,
    losses_as_underdog,
    wins_as_underdog::real / (wins_as_underdog+losses_as_underdog)::real as pct_num3
FROM reg_season_actuals_enriched
UNION ALL
SELECT
    team,
    'vs good teams',
    wins_vs_good_teams,
    losses_vs_good_teams,
    wins_vs_good_teams::real / (wins_vs_good_teams+losses_vs_good_teams)::real as pct_num3
FROM reg_season_actuals_enriched
UNION ALL
SELECT
    team,
    'vs bad teams',
    wins_vs_bad_teams,
    losses_vs_bad_teams,
    wins_vs_bad_teams::real / (wins_vs_bad_teams+losses_vs_bad_teams)::real as pct_num3
FROM reg_season_actuals_enriched
```

```elo_latest
SELECT *,
    elo_rating - original_rating as since_start
FROM prep_elo_post
```

```seed_details
SELECT
    winning_team as team,
    season_rank as seed,
    count(*) / 10000.0 as occurances_pct1
FROM reg_season_end
GROUP BY ALL
```

```wins_details
SELECT
    winning_team as team,
    wins as wins,
    count(*) as occurances
FROM reg_season_end
GROUP BY ALL
```

```wins_seed_scatter
SELECT
    winning_team as team,
    wins as wins,
    count(*) / 10000.0 as odds_pct1,
    case when season_rank <= 6 then 'top six seed'
        when season_rank between 7 and 10 then 'play in'
        else 'missed playoffs'
    end as season_result
FROM reg_season_end
GROUP BY ALL
```

```playoff_odds
SELECT 
    team,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'top six seed'),0) as top_six_pct1,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'play in'),0) as play_in_pct1,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'missed playoffs'),0) as missed_playoffs_pct1
FROM ${wins_seed_scatter}
GROUP BY ALL
```

```quality_wins
SELECT
    winning_team,
    date,
    team1 || ' vs ' || team2 as matchup,
    score1 || ' - ' || score2 as score,
    ABS(elo_change) AS elo_change_num1
FROM prep_results_log RL
LEFT JOIN prep_nba_elo_latest AR ON
    AR._smart_source_lineno - 1 = RL.game_id
QUALIFY ROW_NUMBER() OVER ( PARTITION BY winning_team ORDER BY ABS(elo_change) DESC ) <=5
ORDER BY ABS(elo_change) desc
```

```bad_losses
SELECT
    CASE WHEN winning_team = home_team THEN visiting_team ELSE home_team END AS losing_team,
    date,
    team1 || ' vs ' || team2 as matchup,
    score1 || ' - ' || score2 as score,
    ABS(elo_change) AS elo_change_num1
FROM prep_results_log RL
LEFT JOIN prep_nba_elo_latest AR ON
    AR._smart_source_lineno - 1 = RL.game_id
QUALIFY ROW_NUMBER() OVER ( PARTITION BY CASE WHEN winning_team = home_team THEN visiting_team ELSE home_team END ORDER BY ABS(elo_change) DESC ) <=5
ORDER BY ABS(elo_change) desc
```

### Season-to-date Results

<BigValue 
    data={elo_latest.filter(d => d.team === $page.params.nba_teams)} 
    value='elo_rating' 
    comparison='since_start' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams)} 
    value='seed_range' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams)} 
    value='win_range' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams)} 
    value='predicted_wins' 
    comparison='vs_vegas_num1' 
/> 

### Matchup Summary

<DataTable
    data={records_table.filter(d => d.team === $page.params.nba_teams)} 
    rows=7
/>

### Quality Wins
<sub>Win quality (good & bad) is ranked on the difference in ELO rating between the teams at the time the game was played. It does not account for lineup changes or resting players.</sub>
<DataTable
    data={quality_wins.filter(d => d.winning_team === $page.params.nba_teams)}
/>

### Bad Losses


<DataTable
    data={bad_losses.filter(d => d.losing_team === $page.params.nba_teams)}
/>

### Playoff Odds

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams)} 
    value='top_six_pct1' 
/> 

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams)} 
    value='play_in_pct1' 
/> 

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams)} 
    value='missed_playoffs_pct1' 
/> 

<AreaChart 
    data={wins_seed_scatter.filter(d => d.team === $page.params.nba_teams)}
    x=wins
    y=odds_pct1
    series=season_result
    xAxisTitle=wins
    title='projected end of season wins'
/>

<BarChart 
    data={seed_details.filter(d => d.team === $page.params.nba_teams)} 
    x=seed
    y=occurances_pct1
    xAxisTitle=seed
    title='projected end of season seeding'
/>

## Playoff Analysis

add the following:
- play-in analysis (if playin games exist, i.e. count > 1)
  - this will show % of time by spot, and then % of advancing by seed
- playoff analysis
  - most common opponents with win rate by series (mostly nulls, sparsely populated)