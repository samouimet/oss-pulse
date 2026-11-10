with pull_requests as (

    select
        fetched,
        unnest(data) as pull_request
    from {{ source('github', 'pull_requests') }}
)

select

    cast(pull_request.id as BIGINT) as pull_request_id,
    cast(pull_request.user.id as BIGINT) as opened_by_actor_id,
    cast(pull_request.url as VARCHAR) as pull_request_url,
    cast(pull_request.base.repo.url as VARCHAR) as repository_url,
    cast(pull_request.base.repo.id as BIGINT) as repository_id,
    cast(pull_request.state as VARCHAR) as state,
    cast(pull_request.created_at as TIMESTAMP) as created_at,
    cast(pull_request.updated_at as TIMESTAMP) as updated_at,
    cast(pull_request.closed_at as TIMESTAMP) as closed_at,
    cast(pull_request.merged_at as TIMESTAMP) as merged_at,
    cast(pull_request.number as INT) as number,
    cast(pull_request.base.ref as VARCHAR) as base_ref,
    cast(pull_request.user.login as VARCHAR) as opened_by_actor_login,
    cast(pull_request.user.type as VARCHAR) as opened_by_actor_type,
    cast(pull_requests.fetched as DATE) as snapshot_date

from pull_requests
