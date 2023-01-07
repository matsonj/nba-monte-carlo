# Current progress: "Serverless BI"
The latest version of the project is available at [mdsinabox.com](http://www.mdsinabox.com). The website embraces the notion of "Serverless BI" - the pages are built asynchronously with open source software on commodity hardware and then pushed to a static site. The github action that automatically deploys the site upon PR can be [found here](https://github.com/matsonj/nba-monte-carlo/blob/master/.github/workflows/deploy_on_netlify.yml).

# MDS-in-a-box
This project serves as end to end example of running the "Modern Data Stack" on a single node. The components are designed to be "hot swappable", using Meltano to create clearly defined interfaces between discrete components in the stack. It runs in many enviroments with many visualization options. In addition, the data transformation documentation is [self hosted on github pages](https://matsonj.github.io/nba-monte-carlo/#!/overview).
## Many Environments
It runs practically anywhere, and has been tested in the environments below.


| Operating System | Local | Docker | Devcontainer | Docker in Devcontainer |
|-|-|-|-|-|
| Windows (w/WSL) | n/a | ✅  | ✅  | ✅  |
| Mac (Ventura) | ✅  | ✅  | ✅  | ✅  |
| Linux (Ubuntu 20.04) |✅  | ✅  | ✅  | ✅  |

## Many Visualization Options
### [Apache Superset](https://superset.apache.org/)

![image](https://user-images.githubusercontent.com/16811433/195012880-adf8da03-ab16-4c16-8080-95514fb41c21.png)
![image](https://user-images.githubusercontent.com/16811433/195012951-dde884a0-88f5-48d5-8203-b6f06ba7dbd4.png)

### [Evidence.dev](https://www.evidence.dev)
1 | 2 | 3
-|-|-
<img width="600" alt="image" src="https://user-images.githubusercontent.com/16811433/210928882-9853abd4-5633-4b1a-b8e6-7d63faa8c3ca.png"> | <img width="600" alt="image" src="https://user-images.githubusercontent.com/16811433/210928938-cbe97bb6-b352-4b69-8669-83289af8bd2b.png"> | <img width="600" alt="image" src="https://user-images.githubusercontent.com/16811433/210929106-6e95db75-c068-48f5-a4b3-9ed57ac0023e.png">



This version can also be explored live at [mdsinabox.com](http://www.mdsinabox.com). 
### [Rill Developer](https://www.rilldata.com/)
<img width="1435" alt="image" src="https://user-images.githubusercontent.com/16811433/210934893-7ca7d0aa-9629-4fbb-8009-89658b92158b.png">

Rill should be considered experimental - no dashboards have been defined yet!

# Getting Started
## Building MDS-in-a-box in Github Codespaces

Want to try MDS-in-a-box right away? Create a Codespace:

![image](https://user-images.githubusercontent.com/79663385/204594948-1d50a7f2-b17f-4cb8-b8d4-7659cd526dd5.png)

You can run in the Codespace by running the following command:
```
make build pipeline superset-visuals
```
You will need to wait for the pipeline to run and Superset configuration to complete. The 4-core codespace performs signifcantly better in testing, and is recommended for a better experience.

Once the build completes, you can access the Superset dashboard by clicking on the Open in Browser button on the Ports tab:
![image](https://user-images.githubusercontent.com/79663385/204596948-64cac757-cbaf-434d-ab65-327b8ed8f043.png)
and log in with the username and password: "admin" and "password".

Codespaces also supports "Docker-in-docker", so you can run docker inside the codespace with the following command:
```
make docker-build docker-run-superset
```

## Building MDS-in-a-box in Windows
1. Create your WSL environment. Open a PowerShell terminal running as an administrator and execute:
```
wsl --install
```
* If this was the first time WSL has been installed, restart your machine.

2. Open Ubuntu in your terminal and update your packages. 
```
sudo apt-get update
```
3. Install python3.
```
sudo apt-get install python3.9 python3-pip python3.9-venv
```
4. clone the this repo.
```
mkdir meltano-projects
cd meltano-projects
git clone https://github.com/matsonj/nba-monte-carlo.git
# Go one folder level down into the folder that git just created
cd nba-monte-carlo
```
5. build your project
```
make build pipeline superset-visuals
```
Make sure to open up superset when prompted (default location is 127.0.0.1:8088). 
The username and password is "admin" and "password".

## Using Docker and Kubernetes

You can build a docker container by running: 

```
make docker-build
```

Then run the container using 
```
make docker-run-superset
```
These are both aliases defined in the Makefile:

```
docker-build:
	docker build -t mdsbox .

docker-run:
	docker run \
		--publish 8088:8088 \
	 	--env MELTANO_CLI_LOG_LEVEL=WARNING \
		--env MDS_SCENARIOS=10000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		--env ENVIRONMENT=docker \
		mdsbox make pipeline superset-visuals
```
You can then scale out to Kubernetes, assuming you have it installed:
```
kubectl apply -f ./kubernetes/pod.yaml
```

# Notes on Design Choices

## DuckDB as compute engine
Using DuckDB keeps install and config very simple - its a single command and runs everywhere. It also frankly covers for the sin of building a monte carlo simulation in SQL - it would be quite slow without the kind of computing that DuckDB can do.

Postgres was also considered in this project, but it is not a great pattern to run postgres on the same node as the rest of the data stack. 

## Using Parquet instead of a database
This project leverages parquet in addition to the DuckDB database for file storage. This is experimental and implementation will evolve over time - especially as both the DuckDB format continues to evolve and Iceberg/Delta support is added to DuckDB.
## External Tables
dbt-duckdb supports external tables, which are parquet files exported to the ```data_catalog``` folder. This allows easier integration with Rill, for example, which can read the parquet files and transform them directly with its own DuckDB implementation.


# What's next?

## To-dos
- [ ] clean up env vars + implement incremental builds
- [ ] submit your PR or open an issue!

### Source Data
The data contained within this project comes from [538](https://data.fivethirtyeight.com/#nba-forecasts), [basketball reference](https://basketballreference.com), and [draft kings](https://www.draftkings.com). 
