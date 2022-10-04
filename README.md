# MDS in a box
This project serves as end to end example of running the "Modern Data Stack" in a local environment. Development is primarily done on Windows via WSL, which means Mac is untested (but should work).

## Current progress
Right now, you can get the nba schedule and elo ratings from this project and generate the following query. more to come, see to-dos at bottom of readme.
![image](https://user-images.githubusercontent.com/16811433/193890561-a0b3a9f5-be83-439d-ae49-0c959d4e9cb2.png)


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
5. build your project
```
make pipeline
```
6. if you feel so inclined, install the duckDB CLI and check your work.
```
wget https://github.com/duckdb/duckdb/releases/download/v0.5.1/duckdb_cli-linux-amd64.zip
sudo apt install unzip
unzip duckdb_cli-linux-amd64.zip
./duckdb
.open /tmp/mdsbox.db
SELECT * FROM reg_season_summary;
```

## Running your pipeline on demand
After your run ```make pipeline```, you can run your pipeline again at any time with the following meltano command:
```
meltano run tap-spreadsheets-anywhere target-duckdb dbt:build
```

## Todos
- [x] write initial steps
- [x] create a makefile so you 'make pipeline' and it just all happens
- [x] get data and load to github storage
- [x] add extraction steps to spreadsheets anywhere
- [x] build basic data frame w/dbt
- [x] build the monte carlo sim
- [ ] add meta-stats
  - [x] playoff seeding
  - [ ] playin game stuff
  - [ ] playoff schedule
  - [ ] series winners
  - [ ] playoff wins
- [ ] some basic charts in superset (replicate 538?)
