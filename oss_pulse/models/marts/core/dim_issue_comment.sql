select

    a.comment_id,
    a.author_actor_id,
    b.issue_id,
    c.pull_request_id,
    a.created_at,
    a.updated_at,
    a.html_url

from {{ ref('stg_github__issue_comments') }} as a
left join {{ ref('stg_github__issues') }} as b
    on
        a.issue_url = b.issue_url
        and b.is_pull_request = False
left join {{ ref('stg_github__pull_requests') }} as c
    on a.issue_url = c.issue_url

qualify
    row_number() over (partition by a.comment_id order by a.snapshot_date desc)
    = 1
