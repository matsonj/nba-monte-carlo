import dlt
from dlt.sources.helpers import requests

# Specify the URL of the API endpoint
url = "https://api.pbpstats.com/get-games/nba?Season=2023-24&SeasonType=Regular%20Season"
# Make a request and check if it was successful
response = requests.get(url)
response.raise_for_status()

pipeline = dlt.pipeline(
    pipeline_name="nba_pipeline",
    destination="duckdb",
    dataset_name="nba_data",
)
# The response contains a list of issues
load_info = pipeline.run(
    response.json().get('results', []),
    table_name="games", write_disposition="replace", 
    destination=dlt.destinations.duckdb(credentials="../data/data_catalog/mdsbox.duckdb")
    )

print(load_info)