with reviews as (

    select
        fetched,
        meta,
        unnest(data) as review
    from {{ source('github', 'reviews') }}

)

select
    cast(review.id as BIGINT) as review_id,
    cast(meta.pr_number as INT) as pull_request_number,
    cast(review.pull_request_url as VARCHAR) as pull_request_url,
    cast(review.user.id as BIGINT) as submitted_by_actor_id,
    cast(review.user.login as VARCHAR) as submitted_by_actor_login,
    cast(review.user.type as VARCHAR) as submitted_by_actor_type,
    cast(review.state as VARCHAR) as state,
    cast(review.submitted_at as TIMESTAMP) as submitted_at,
    cast(reviews.fetched as DATE) as snapshot_date
from reviews
