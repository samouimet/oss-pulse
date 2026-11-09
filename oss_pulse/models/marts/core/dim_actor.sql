with ranked as

(select
    actor_id, 
    login, 
    type,
    row_number() over (partition by actor_id order by snapshot_date desc) as row_num
from {{ ref('int_actors_unioned') }}
)

select 
    actor_id, 
    login, 
    type, 
    case 
        when type = 'Bot' then TRUE else FALSE 
        end as is_bot
from ranked
where row_num = 1
