select 

    a.issue_id, 
    opened_by_actor_id, 
    closed_by_actor_id, 
    repository_id, 
    state, 
    created_at, 
    updated_at, 
    closed_at, 
    number, 
    first_response_at

from {{ ref('int_issues_joined') }} a 
left join {{ ref('int_issues_first_response') }} b
on a.issue_id = b.issue_id

qualify row_number() over (partition by a.issue_id order by snapshot_date desc) = 1