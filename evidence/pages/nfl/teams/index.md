```reg_season
select
  conf,
  team,
  elo_rating,
  avg_wins as avg_wins_num1,
  NULL AS " ",
  COALESCE((made_postseason + first_round_bye) / 10000.0,0) as make_playoffs_pct1
from nfl_reg_season_summary
order by conf, avg_wins desc
```

```afc_conf
select
  ROW_NUMBER() OVER (ORDER BY avg_wins_num1 DESC) AS seed,
  '/nfl/teams/' || R.team as team_link,
  R.team,
  R." ",
  elo_rating AS elo_rating_num0,
  avg_wins_num1,
  make_playoffs_pct1
FROM ${reg_season} R
WHERE conf = 'AFC'
ORDER BY avg_wins_num1 DESC
```

```nfc_conf
select
  ROW_NUMBER() OVER (ORDER BY avg_wins_num1 DESC) AS seed,
  '/nfl/teams/' || R.team as team_link,
  R.team,
  R." ",
  elo_rating as elo_rating_num0,
  avg_wins_num1,
  make_playoffs_pct1
FROM ${reg_season} R
WHERE conf = 'NFC'
ORDER BY avg_wins_num1 DESC
```

## Team Browser
### American Football Conference

<DataTable data={afc_conf} link=team_link rows=16>
  <Column id=seed/>
  <Column id=team/>
  <Column id=elo_rating_num0/>
  <Column id=avg_wins_num1/>
  <Column id=make_playoffs_pct1/>
</DataTable>

### National Football Conference

<DataTable data={nfc_conf} link=team_link rows=16>
  <Column id=seed/>
  <Column id=team/>
  <Column id=elo_rating_num0/>
  <Column id=avg_wins_num1/>
  <Column id=make_playoffs_pct1/>
</DataTable>