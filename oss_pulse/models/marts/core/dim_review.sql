select

    a.review_id,
    b.pull_request_id,
    a.submitted_by_actor_id,
    a.state,
    a.submitted_at

from {{ ref('stg_github__reviews') }} as a
left join {{ ref('stg_github__pull_requests') }} as b
    on a.pull_request_url = b.pull_request_url

qualify
    row_number() over (partition by a.review_id order by a.snapshot_date desc)
    = 1
