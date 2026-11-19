{{ 
    dbt_utils.date_spine(
    datepart='month',
    start_date = "cast('2010-01-01' as date)",
    end_date = dbt.dateadd('month', 1, 'current_date')
)
}}
