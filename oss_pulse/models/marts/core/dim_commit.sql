select

    a.commit_sha,
    a.author_actor_id,
    b.repository_id,
    a.authored_at,
    a.author_name,
    a.author_email

from {{ ref('stg_github__commits') }} as a
left join {{ ref('stg_github__repos') }} as b
    on a.repository_url = b.repository_url

qualify
    row_number() over (partition by a.commit_sha order by a.snapshot_date desc)
    = 1
