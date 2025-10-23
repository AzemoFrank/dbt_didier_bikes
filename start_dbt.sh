#source /home/fazemo/dbt-env/bin/activate
dbt clean
dbt deps
dbt run-operation stage_external_sources
dbt run
dbt test --show-all-deprecations

#doc dbt du projet
dbt docs generate
#dbt docs serve
