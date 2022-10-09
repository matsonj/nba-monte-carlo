SELECT R.*,
    P.made_playoffs,
    P.made_conf_semis,
    P.made_conf_finals,
    P.made_finals,
    P.won_finals
FROM {{ ref( 'reg_season_summary' ) }} R
    LEFT JOIN {{ ref( 'playoff_summary' ) }} P ON P.team = R.team