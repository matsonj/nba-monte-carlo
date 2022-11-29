# MDS in a box
This project serves as end to end example of running the "Modern Data Stack" in a local environment. For those looking for a more integrated experience, devcontainers have been implemented as well. If you have docker and WSL installed, the container can booted up right from VS Code.

## Current progress
Right now, you can get the nba schedule and elo ratings from this project and generate the following query. more to come, see to-dos at bottom of readme. And of course, the dbt docs are self hosted in Github Pages, [check them out here](https://matsonj.github.io/nba-monte-carlo/).
![image](https://user-images.githubusercontent.com/16811433/195012880-adf8da03-ab16-4c16-8080-95514fb41c21.png)
![image](https://user-images.githubusercontent.com/16811433/195012951-dde884a0-88f5-48d5-8203-b6f06ba7dbd4.png)

## Using GitHub Codespaces

Want to try MDS in a Box right away? Create a Codespace:

![image](https://user-images.githubusercontent.com/79663385/204594948-1d50a7f2-b17f-4cb8-b8d4-7659cd526dd5.png)

You can run in the Codespace two ways:

1. Directly in the Codespaces development environment:

	```
	make build pipeline superset-visuals
	```
	
2. Or using Docker inside the Codespace:

	```
	make docker-build docker-run
	```

In both cases, you will need to wait for the pipeline to run and Superset configuration to complete. 

You can then access the Superset dashboard by clicking on the Open in Browswer button on the Ports tab:
![image](https://user-images.githubusercontent.com/79663385/204596948-64cac757-cbaf-434d-ab65-327b8ed8f043.png)
and log in with the username and password: "admin" and "password".

## Building MDS in a box in Windows
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
sudo apt-get install python3.8 python3-pip python3.8-venv
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
Make sure to open up superset when prompted (default location is localhost:8088). 
The username and password is "admin" and "password".

## Using Docker and Kubernetes

You can build a docker container by running: 

```
make docker-build
```

Then run the container using 
```
make docker-run
```
These are both aliases defined in the Makefile:

```
docker-build:
	docker build -t mdsbox .

docker-run:
	docker run \
		--publish 8088:8088 \
	 	--env MELTANO_CLI_LOG_LEVEL=WARNING \
		--env MDS_SCENARIOS=1000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		mdsbox make pipeline superset-visuals 
```

You can then scale out to Kubernetes, assuming you have it installed:

```
kubectl apply -f ./kubernetes/pod.yaml
```

## Using Parquet instead of a database
This project leverages parquet in addition to a database for file storage. This is experimental and implementation will evolve over time.

## Todos
- [x] replace reg season schedule with 538 schedule
- [x] add table for results
- [x] add config options in dbt vars to ignore completed games
- [x] make simulator only sim incomplete games
- [x] add table for new ratings
- [x] add config to use original or new ratings
- [x] cleanup dbt-osmosis
- [ ] clean up env vars + implement incremental builds
- [x] clean up dev container plugins (remove irrelevant ones, add some others)
- [ ] add dbt tests on simulator tables that no numeric values are null (elo ratings, home team win probabilities)

## Optional stuff
- [x] add dbt tests
- [ ] add model descriptions
- [x] change elo calculation to a udf
- [x] make playoff elimination stuff a macro (param: schedule type)

## Source Data
The data contained within this project comes from [538](https://data.fivethirtyeight.com/#nba-forecasts), [basketball reference](https://basketballreference.com), and [draft kings](https://www.draftkings.com). 
