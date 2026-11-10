select

    a.pull_request_id,
    b.submitted_at as first_review_at

from {{ ref('stg_github__pull_requests') }} as a
inner join {{ ref('stg_github__reviews') }} as b

    on a.pull_request_url = b.pull_request_url

where
    a.opened_by_actor_id != b.submitted_by_actor_id
    and
    b.submitted_by_actor_type != 'Bot'

qualify
    row_number() over (partition by a.pull_request_id order by b.submitted_at)
    = 1
