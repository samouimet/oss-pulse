from airflow.sdk import dag
from airflow.providers.standard.operators.bash import BashOperator
from pendulum import datetime

INGESTION_DIR = "/usr/local/airflow/ingestion/github_api"   
RAW_DIR = "/usr/local/airflow/data/raw"
DBT_BIN = "/usr/local/airflow/dbt_venv/bin/dbt"
DBT_DIR = "/usr/local/airflow/oss_pulse"                     

@dag(                                  
    dag_id="oss_pulse_pipeline",       
    start_date=datetime(2026, 11, 1),  
    schedule="@daily",                 
    catchup=False,                     
    default_args={"owner": "sam", "retries": 2},  
    tags=["oss-pulse"],                
)
def oss_pulse_pipeline():
    ingest_repos = BashOperator(       
        task_id="ingest_repos",        
        bash_command=f"python -u {INGESTION_DIR}/github_repos.py --owner dbt-labs --repo dbt",
        env={"RAW_OUTPUT_DIR": RAW_DIR},  
        append_env=True,               
    )
    ingest_commits = BashOperator(       
        task_id="ingest_commits",        
        bash_command=f"python -u {INGESTION_DIR}/github_commits.py --owner dbt-labs --repo dbt",
        env={"RAW_OUTPUT_DIR": RAW_DIR},  
        append_env=True,               
    )
    ingest_issue_comments = BashOperator(       
        task_id="ingest_issue_comments",        
        bash_command=f"python -u {INGESTION_DIR}/github_issue_comments.py --owner dbt-labs --repo dbt",
        env={"RAW_OUTPUT_DIR": RAW_DIR},  
        append_env=True,               
    )
    ingest_issues = BashOperator(       
        task_id="ingest_issues",        
        bash_command=f"python {INGESTION_DIR}/github_issues.py --owner dbt-labs --repo dbt",
        env={"RAW_OUTPUT_DIR": RAW_DIR},  
        append_env=True,               
    )
    ingest_pull_requests= BashOperator(       
        task_id="ingest_pull_requests",        
        bash_command=f"python -u {INGESTION_DIR}/github_pull_requests.py --owner dbt-labs --repo dbt",
        env={"RAW_OUTPUT_DIR": RAW_DIR},  
        append_env=True,               
    )
    ingest_reviews = BashOperator(       
        task_id="ingest_reviews",        
        bash_command=f"python -u {INGESTION_DIR}/github_reviews.py --owner dbt-labs --repo dbt",
        env={"RAW_OUTPUT_DIR": RAW_DIR},  
        append_env=True,               
    )

    ingest_releases = BashOperator(       
        task_id="ingest_releases",        
        bash_command=f"python -u {INGESTION_DIR}/github_releases.py --owner dbt-labs --repo dbt",
        env={"RAW_OUTPUT_DIR": RAW_DIR},  
        append_env=True,               
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=f"{DBT_BIN} build",
        cwd=DBT_DIR

    )

    ingest_pull_requests >> ingest_reviews

    [ingest_repos, ingest_issues, ingest_issue_comments,
     ingest_commits, ingest_releases, ingest_reviews] >> dbt_build

oss_pulse_pipeline()                   