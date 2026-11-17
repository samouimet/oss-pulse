with activities as (

--- COMMENTS
    select

        'comment' as activity_type,
        cast(a.comment_id as VARCHAR) as source_id,
        a.author_actor_id as actor_id,
        a.created_at as activity_at,
        coalesce(b.repository_id, c.repository_id) as repository_id

    from {{ ref('dim_issue_comment') }} as a
    left join {{ ref('dim_issue') }} as b
        on a.issue_id = b.issue_id
    left join {{ ref('dim_pull_request') }} as c
        on a.pull_request_id = c.pull_request_id

    union all

    --- COMMITS
    select

        'commit' as activity_type,
        cast(commit_sha as VARCHAR) as source_id,
        author_actor_id as actor_id,
        authored_at as activity_at,
        repository_id

    from {{ ref('dim_commit') }}

    union all

    --- REVIEWS
    select

        'review' as activity_type,
        cast(a.review_id as VARCHAR) as source_id,
        a.submitted_by_actor_id as actor_id,
        a.submitted_at as activity_at,
        b.repository_id

    from {{ ref('dim_review') }} as a
    left join {{ ref('dim_pull_request') }} as b
        on a.pull_request_id = b.pull_request_id

    union all

    --- ISSUES OPENED
    select

        'issue_opened' as activity_type,
        cast(issue_id as VARCHAR) as source_id,
        opened_by_actor_id as actor_id,
        created_at as activity_at,
        repository_id

    from {{ ref('dim_issue') }}

    union all

    --- ISSUES CLOSED

    select

        'issue_closed' as activity_type,
        cast(issue_id as VARCHAR) as source_id,
        closed_by_actor_id as actor_id,
        closed_at as activity_at,
        repository_id

    from {{ ref('dim_issue') }}
    where state = 'closed'

    union all

    --- PULL REQUESTS
    select

        'pull_request_opened' as activity_type,
        cast(pull_request_id as VARCHAR) as source_id,
        opened_by_actor_id as actor_id,
        created_at as activity_at,
        repository_id

    from {{ ref('dim_pull_request') }}

)

select a.*
from activities as a
inner join {{ ref('dim_actor') }} as b
    on a.actor_id = b.actor_id
where b.is_bot = False
