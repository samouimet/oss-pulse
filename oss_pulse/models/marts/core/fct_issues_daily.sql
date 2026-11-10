select 

    issue_id, 
    snapshot_date, 
    reactions_total_count

from {{ ref('int_issues_joined') }}