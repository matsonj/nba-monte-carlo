FROM tournament_end
SELECT
    winning_team,
    tournament_group,
    sum(made_tournament) / 10000.0 as won_group,
    sum(made_wildcard) / 30000.0 as made_wildcard,
    sum(made_tournament) / 10000.0 + sum(made_wildcard) / 30000.0 as made_tournament,
    avg(wins) as wins,
    avg(losses) as losses
GROUP BY ALL
ORDER BY tournament_group, made_tournament DESC