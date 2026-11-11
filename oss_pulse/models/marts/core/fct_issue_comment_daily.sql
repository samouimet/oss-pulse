select

    comment_id,
    snapshot_date,
    reactions_total_count

from {{ ref('stg_github__issue_comments') }}
