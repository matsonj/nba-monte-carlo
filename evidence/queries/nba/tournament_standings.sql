WITH cte_wins AS (
    SELECT
        S.winning_team,
        COUNT(*) AS wins
    FROM ${past_games} S
    WHERE s.type = 'tournament'
    GROUP BY ALL
),
cte_losses AS (
    SELECT
        CASE WHEN S.home_team = S.winning_team 
            THEN S.visiting_team ELSE S.home_team
        END AS losing_team,
        COUNT(*) AS losses
    FROM ${past_games} S
    WHERE s.type = 'tournament'
    GROUP BY ALL
),
cte_scores AS (
    FROM src_nba_results_by_team
    SELECT
        team,
        avg(score) as pts,
        sum(margin) as margin
    WHERE type = 'tournament'
    group by all
)
SELECT 
    T.team,
    '/nba/teams/' || T.team as team_link,
    T.conf,
    COALESCE(W.wins,0) AS wins,
    COALESCE(L.losses,0) as losses,
    COALESCE(W.wins,0) || '-' || COALESCE(L.losses,0) AS record,
    coalesce(S.margin,0) as margin,
    CASE WHEN S.margin > 0 THEN '+' || margin ELSE margin::varchar END AS pt_diff,   
    T.tournament_group as group,
    R.won_group AS won_group_pct1,
    R.made_wildcard AS won_wildcard_pct1,
    R.made_tournament AS made_tournament_pct1,
    ROUND(R.wins,1) || '-' || ROUND(R.losses,1) AS proj_record 
FROM src_nba_teams T
    LEFT JOIN cte_wins W ON W.winning_team = T.team
    LEFT JOIN cte_losses L ON L .losing_team = T.team
    LEFT JOIN ${tournament_results} R ON R.winning_team = T.team
    LEFT JOIN cte_scores S ON S.team = T.team
GROUP BY ALL
ORDER BY T.tournament_group,  wins DESC, won_group DESC, made_tournament_pct1 DESC, margin DESC