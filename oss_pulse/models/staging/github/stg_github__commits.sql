with commits as (

    select
        fetched,
        unnest(data) as commit_data
    from {{ source('github', 'commits') }}
)

select

    cast(commit_data.sha as VARCHAR) as commit_sha,
    cast(commit_data.author.id as BIGINT) as author_actor_id,
    cast(commit_data.author.login as VARCHAR) as author_actor_login,
    cast(commit_data.author.type as VARCHAR) as author_actor_type,
    cast(
        regexp_replace(commit_data.url, '/commits/[0-9a-f]+$', '') as VARCHAR
    ) as repository_url,
    cast(commit_data.commit.author.date as TIMESTAMP) as authored_at,
    cast(commit_data.commit.author.name as VARCHAR) as author_name,
    cast(commit_data.commit.author.email as VARCHAR) as author_email,
    cast(commits.fetched as DATE) as snapshot_date

from commits
