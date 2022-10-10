# MDS in a box
This project serves as end to end example of running the "Modern Data Stack" in a local environment. Development is primarily done on Windows via WSL, which means Mac is untested (but should work).

## Current progress
Right now, you can get the nba schedule and elo ratings from this project and generate the following query. more to come, see to-dos at bottom of readme. And of course, the dbt docs are self hosted in Github Pages, [check them out here](https://matsonj.github.io/nba-monte-carlo/).
<img width="1005" alt="image" src="https://user-images.githubusercontent.com/16811433/193949511-71944c9f-2a73-4a01-bacd-c95259323ff2.png">
![image](https://user-images.githubusercontent.com/16811433/194679803-90afe1af-07e2-4fc8-b883-1e86fd14ab84.png)

## Getting started - Windows
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
5. build your project & run your pipeline
```
make build
make run
```
6. Connect duckdb to superset. first, create an admin users
```
meltano invoke superset:create-admin
```
 - then boot up superset
```
meltano run superset:ui
```
 - lastly, connect it to duck db. navigate to localhost:8088, login, and add duckdb as a database.

   - SQL Alchemy URL: ```duckdb:////tmp/mdsbox.db```

   - Advanced Settings > Other > Engine Parameters: ```{"connect_args":{"read_only":true}}```

7. Explore your data inside superset. Go to SQL Labs > SQL Editor and write a custom query. A good example is ```SELECT * FROM reg_season_end```.

## Running your pipeline on demand
After your run ```make run```, you can run your pipeline again at any time with the following meltano command:
```
meltano run tap-spreadsheets-anywhere target-duckdb dbt-duckdb:build
```

## Todos
- [x] write initial steps
- [x] create a makefile so you 'make pipeline' and it just all happens
- [x] get data and load to github storage
- [x] add extraction steps to spreadsheets anywhere
- [x] build basic data frame w/dbt
- [x] build the monte carlo sim
- [x] add meta-stats
  - [x] playoff seeding
  - [x] playin game stuff
  - [x] playoff schedule
  - [x] series winners
  - [x] playoff wins
- [ ] some basic charts in superset (replicate 538?)
- [x] add github action to build it
- [x] add dbt docs as github pages

## Optional stuff
- [ ] add dbt tests
- [ ] add dmodel descriptions
- [ ] change elo calculation to a udf
- [ ] make playoff elimination stuff a macro (param: schedule type)
