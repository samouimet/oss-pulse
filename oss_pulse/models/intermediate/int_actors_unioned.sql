--- repos
select
    owner_actor_id as actor_id,
    owner_actor_login as login,
    owner_actor_type as type,
    snapshot_date
from {{ ref('stg_github__repos') }}

union all

--- issues opened by 
select
    opened_by_actor_id as actor_id,
    opened_by_actor_login as login,
    opened_by_actor_type as type,
    snapshot_date

from {{ ref('stg_github__issues') }}

union all

--- issues closed by
select
    closed_by_actor_id as actor_id,
    closed_by_actor_login as login,
    closed_by_actor_type as type,
    snapshot_date
from {{ ref('stg_github__issues') }}
where closed_by_actor_id is not null

union all

--- pull requests
select
    opened_by_actor_id as actor_id,
    opened_by_actor_login as login,
    opened_by_actor_type as type,
    snapshot_date
from {{ ref('stg_github__pull_requests') }}

union all

--- comments
select
    author_actor_id as actor_id,
    author_actor_login as login,
    author_actor_type as type,
    snapshot_date
from {{ ref('stg_github__issue_comments') }}

union all

--- reviews
select
    submitted_by_actor_id as actor_id,
    submitted_by_actor_login as login,
    submitted_by_actor_type as type,
    snapshot_date
from {{ ref('stg_github__reviews') }}

union all

--- commits
select
    author_actor_id as actor_id,
    author_actor_login as login,
    author_actor_type as type,
    snapshot_date
from {{ ref('stg_github__commits') }}
where author_actor_id is not null

union all

--- releases
select
    published_by_actor_id as actor_id,
    published_by_actor_login as login,
    published_by_actor_type as type,
    snapshot_date
from {{ ref('stg_github__releases') }}
