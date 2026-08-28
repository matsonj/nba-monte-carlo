with
    picks as (
        select
            cast(season as integer) as season,
            trim(speaker) as speaker,
            trim(team) as team,
            lower(trim(pick)) as pick,
            cast(line as double) as line,
            cast(episode_date as date) as episode_date,
            trim(episode_url) as episode_url
        from {{ source("nfl", "bs_pod_over_unders") }}
    ),

    teams as (
        select team, conf, division
        from {{ ref("nfl_ratings") }}
    ),

    scheduled_games as (
        select team, count(*) as scheduled_games
        from
            (
                select home_team as team, game_id
                from {{ ref("nfl_schedules") }}
                where type = 'reg_season'
                union all
                select visiting_team as team, game_id
                from {{ ref("nfl_schedules") }}
                where type = 'reg_season'
            ) schedule_by_team
        group by team
    ),

    completed_games as (
        select
            s.game_id,
            r.home_team,
            r.home_team_score,
            r.visiting_team,
            r.visiting_team_score
        from {{ ref("nfl_schedules") }} s
        inner join {{ ref("nfl_latest_results") }} r on r.game_id = s.game_id
        where s.type = 'reg_season'
    ),

    team_game_results as (
        select
            home_team as team,
            case when home_team_score > visiting_team_score then 1 else 0 end as wins,
            case when home_team_score < visiting_team_score then 1 else 0 end as losses,
            case when home_team_score = visiting_team_score then 1 else 0 end as ties
        from completed_games
        union all
        select
            visiting_team as team,
            case when visiting_team_score > home_team_score then 1 else 0 end as wins,
            case when visiting_team_score < home_team_score then 1 else 0 end as losses,
            case when visiting_team_score = home_team_score then 1 else 0 end as ties
        from completed_games
    ),

    actuals as (
        select
            team,
            sum(wins)::integer as current_wins,
            sum(losses)::integer as current_losses,
            sum(ties)::integer as current_ties,
            count(*)::integer as games_played
        from team_game_results
        group by team
    ),

    metrics as (
        select
            p.season,
            p.speaker,
            p.team,
            t.conf,
            t.division,
            p.pick,
            p.line,
            p.episode_date,
            p.episode_url,
            coalesce(a.games_played, 0)::integer as games_played,
            coalesce(s.scheduled_games, 0)::integer as scheduled_games,
            coalesce(a.current_wins, 0)::integer as current_wins,
            coalesce(a.current_losses, 0)::integer as current_losses,
            coalesce(a.current_ties, 0)::integer as current_ties,
            case
                when coalesce(s.scheduled_games, 0) > 0
                and coalesce(a.games_played, 0) >= s.scheduled_games
                then true
                else false
            end as regular_season_complete
        from picks p
        left join teams t on t.team = p.team
        left join scheduled_games s on s.team = p.team
        left join actuals a on a.team = p.team
    ),

    results as (
        select
            *,
            case
                when regular_season_complete then
                    case
                        when pick = 'over' and current_wins > line then 'Win'
                        when pick = 'under' and current_wins < line then 'Win'
                        when current_wins = line then 'Push'
                        else 'Loss'
                    end
            end as final_result
        from metrics
    )

select
    *,
    case
        when regular_season_complete then final_result
        when (pick = 'over' and current_wins > line)
            or (pick = 'under' and current_wins < line)
        then 'On track'
        else 'Behind'
    end as live_status
from results
