from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime
import subprocess

default_args = {
    'start_date': datetime(2025, 6, 6),
}

def run_execute_script():
    subprocess.run(["python", "/scripts/execute_positions.py"])

with DAG('ib_pipeline_dag', schedule_interval='@daily', catchup=False, default_args=default_args) as dag:

    collect_data = BashOperator(
        task_id='collect_data',
        bash_command='python /scripts/realtime_forex_collector.py'
    )

    run_strategy = BashOperator(
        task_id='run_strategy',
        bash_command='Rscript /scripts/run_strategy_pipeline.R /scripts/realtime_forex_input.csv'
    )

    execute_trades = PythonOperator(
        task_id='execute_trades',
        python_callable=run_execute_script
    )

    collect_data >> run_strategy >> execute_trades
