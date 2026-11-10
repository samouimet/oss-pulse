select
    issue_id,
    c.created_at as first_response_at

from {{ ref('int_issues_joined') }} as i
inner join {{ ref('stg_github__issue_comments') }} as c

    on CONCAT(i.repository_url, '/issues/', i.number) = c.issue_url

where
    opened_by_actor_id != author_actor_id
    and
    author_actor_type != 'Bot'

qualify ROW_NUMBER() over (partition by issue_id order by c.created_at) = 1
