select

repository_id, 
snapshot_date, 
stargazers_count, 
forks_count, 
open_issues_count

from {{ ref('stg_github__repos') }}