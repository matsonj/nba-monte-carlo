# Detailed Analysis for <Value data={season_summary.filter(d => d.team === $page.params.nba_teams.toUpperCase().replace(/\/+$/,""))} column=team_long/>

```season_summary
select R.*,
    R.elo_vs_vegas*-1.0 as vs_vegas_num1,
    R.avg_wins as predicted_wins,
    (COALESCE(R.made_postseason,0) + COALESCE(R.made_play_in,0) )/ 10000.0 as made_playoffs_pct1,
    T.team_long
from reg_season_summary R
left join nba_ratings T on R.team = T.team
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
FROM nba_latest_elo
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

```most_recent_games
SELECT
    game_date as date,
    CASE WHEN type = 'In-Season Tournament' THEN '🏆' ELSE '' END AS T,
    vstm as visiting_team,
    '@' as " ",
    hmtm as home_team,
    home_team_score || ' - ' || visiting_team_score as score,
    winning_team,
    ABS(elo_change) AS elo_change_num1
FROM nba_results_log RL
ORDER BY game_date desc
```

```game_trend
with cte_games AS (
SELECT 0 as game_id, team, original_rating as elo_rating, 0 as elo_change 
FROM nba_latest_elo
UNION ALL
SELECT game_id, vstm as team, visiting_team_elo_rating as elo_rating, elo_change
FROM nba_results_log
UNION ALL
SELECT game_id, hmtm as team, home_team_elo_rating as elo_rating, elo_change*-1 as elo_change
FROM nba_results_log )
SELECT 
    COALESCE(AR.game_date,'2023-10-23')::date AS date,
    RL.team, 
    RL.elo_rating, 
    RL.elo_change,
    sum(RL.elo_change) over (partition by team order by COALESCE(AR.game_date,'2023-10-23') asc rows between unbounded preceding and current row) as cumulative_elo_change_num0
FROM cte_games RL
LEFT JOIN nba_results_log AR ON AR.game_id = RL.game_id
ORDER BY date
```

## Season-to-date Results

<BigValue 
    data={elo_latest.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='elo_rating' 
    comparison='since_start' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='predicted_wins' 
    comparison='vs_vegas_num1' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='seed_range' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='win_range' 
/> 

<LineChart
    data={game_trend.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    x=date
    y=cumulative_elo_change_num0
    title='elo change over time'
/>

### Most Recent Games

<DataTable
    data={most_recent_games.filter(d => d.home_team === $page.params.nba_teams.toUpperCase() | d.visiting_team === $page.params.nba_teams.toUpperCase())} 
    rows=5
/>


### Matchup Summary

<DataTable
    data={records_table.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    rows=7
/>


### Playoff Odds

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='top_six_pct1' 
/> 

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='play_in_pct1' 
/> 

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='missed_playoffs_pct1' 
/> 

<AreaChart 
    data={wins_seed_scatter.filter(d => d.team === $page.params.nba_teams.toUpperCase())}
    x=wins
    y=odds_pct1
    series=season_result
    xAxisTitle=wins
    title='projected end of season wins'
/>

<BarChart 
    data={seed_details.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    x=seed
    y=occurances_pct1
    xAxisTitle=seed
    title='projected end of season seeding'
/>

{#if game_trend.length == 0}

## Playoff Analysis

add the following:
- play-in analysis (if playin games exist, i.e. count > 1)
  - this will show % of time by spot, and then % of advancing by seed
- playoff analysis
  - most common opponents with win rate by series (mostly nulls, sparsely populated)


  {/if}