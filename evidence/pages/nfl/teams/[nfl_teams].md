# Detailed Analysis for <Value data={nfl_season_summary.filter(d => d.team === $page.params.nfl_teams)} column=team/>

```nfl_season_summary
select R.*,
    R.elo_vs_vegas*-1.0 as vs_vegas_num1,
    R.avg_wins as predicted_wins,
    (COALESCE(R.made_postseason,0) + COALESCE(R.first_round_bye,0) )/ 10000.0 as made_playoffs_pct1
from nfl_reg_season_summary R
left join nfl_prep_team_ratings T on R.team = T.team
```

## Hello World

Once the playoff model is built, some fun analysis can go here!