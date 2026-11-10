select

    a.pull_request_id,
    a.opened_by_actor_id,
    a.repository_id,
    a.state,
    a.created_at,
    a.updated_at,
    a.closed_at,
    a.merged_at,
    a.number,
    a.base_ref,
    b.first_review_at

from {{ ref('stg_github__pull_requests') }} as a
left join {{ ref('int_pull_requests_first_review') }} as b
    on a.pull_request_id = b.pull_request_id

qualify
    row_number()
        over (partition by a.pull_request_id order by a.snapshot_date desc)
    = 1
