with releases as (

    select
        fetched,
        unnest(data) as release
    from {{ source('github', 'releases') }}

)

select
    cast(release.id as BIGINT) as release_id,
    cast(release.author.id as BIGINT) as published_by_actor_id,
    cast(release.author.login as VARCHAR) as published_by_actor_login,
    cast(release.author.type as VARCHAR) as published_by_actor_type,
    cast(regexp_replace(release.url, '/releases/[0-9]+$', '') as VARCHAR)
        as repository_url,
    cast(release.tag_name as VARCHAR) as tag_name,
    cast(release.created_at as TIMESTAMP) as created_at,
    cast(release.updated_at as TIMESTAMP) as updated_at,
    cast(release.published_at as TIMESTAMP) as published_at,
    cast(release.draft as BOOLEAN) as draft,
    cast(release.prerelease as BOOLEAN) as prerelease,
    cast(releases.fetched as DATE) as snapshot_date

from releases
