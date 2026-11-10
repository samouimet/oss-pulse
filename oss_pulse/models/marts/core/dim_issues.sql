select

    a.issue_id,
    a.opened_by_actor_id,
    a.closed_by_actor_id,
    a.repository_id,
    a.state,
    a.created_at,
    a.updated_at,
    a.closed_at,
    a.number,
    b.first_response_at

from {{ ref('int_issues_joined') }} as a
left join {{ ref('int_issues_first_response') }} as b
    on a.issue_id = b.issue_id

qualify
    row_number() over (partition by a.issue_id order by a.snapshot_date desc) = 1
