select 

cast(data.id as BIGINT) as repository_id,
cast(data.owner.id as BIGINT) as owner_actor_id,
cast(data.name as VARCHAR) as name,
cast(data.created_at as TIMESTAMP) as created_at, 
cast(data.updated_at as TIMESTAMP) as updated_at, 
cast(data.pushed_at as TIMESTAMP) as pushed_at, 
cast(data.default_branch as VARCHAR) as default_branch, 
cast(data.archived as BOOLEAN) as archived,
cast(fetched as DATE) as snapshot_date,
cast(data.stargazers_count as INT) as stargazers_count,
cast(data.forks_count as INT) as forks_count,
cast(data.open_issues_count as INT) as open_issues_count


from {{ source('github', 'repos') }}
