with issue_comments as (

    select
        fetched,
        unnest(data) as issue_comment
    from {{ source('github', 'issue_comments') }}

)

select

    cast(issue_comment.id as BIGINT) as comment_id,
    cast(issue_comment.user.id as BIGINT) as author_actor_id,
    cast(issue_comment.user.login as VARCHAR) as author_actor_login,
    cast(issue_comment.user.type as VARCHAR) as author_actor_type,
    cast(issue_comment.issue_url as VARCHAR) as issue_url,
    cast(issue_comment.created_at as TIMESTAMP) as created_at,
    cast(issue_comment.updated_at as TIMESTAMP) as updated_at,
    cast(issue_comment.html_url as VARCHAR) as html_url,
    cast(issue_comments.fetched as DATE) as snapshot_date,
    cast(issue_comment.reactions.total_count as INT) as reactions_total_count

from issue_comments
