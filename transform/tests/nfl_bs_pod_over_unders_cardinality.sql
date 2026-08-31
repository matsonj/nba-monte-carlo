with
    stats as (
        select
            count(*) as row_count,
            count(distinct team) as team_count,
            count(distinct speaker) as speaker_count,
            count(distinct conf) as conference_count,
            min(season) as min_season,
            max(season) as max_season
        from {{ ref("nfl_bs_pod_over_unders") }}
    )

select *
from stats
where row_count <> 64
    or team_count <> 32
    or speaker_count <> 2
    or conference_count <> 2
    or coalesce(min_season, 0) <> 2026
    or coalesce(max_season, 0) <> 2026
