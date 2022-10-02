# MDS in a box
This project serves as end to end example of running the "Modern Data Stack" in a local environment. Development is primarily done on Windows via WSL, which means Mac is untested (but should work).

## Getting started - Windows
1. Create your WSL environment.
```
wsl --install
```
2. Open Ubuntu in your terminal and update your packages. 
```
sudo apt-get update
```
3. Install python3.
```
sudo apt-get install python3.8 python3-pip
```
4. Now its time to grab pipx. 
```
# install pipx and ensure it is on the path
python3 -m pip install --user pipx
python3 -m pipx ensurepath
# Be sure pipx is available on your path
source ~/.bashrc
```
5. install meltano
```
pipx install meltano
# check the version
meltano --version
```
6. clone the this repo.
```
mkdir nba-monte-carlo
cd nba-monte-carlo
git clone https://github.com/matsonj/nba-monte-carlo.git
```
7. run meltano install
```
meltano install
# if you run into any dependency issues, clear them and then re-run meltano install
```
8. run your pipeline!
```
 meltano elt tap-spreadsheets-anywhere target-duckdb --transform=run
 ```
 9. if you feel so inclined, install the duckDB CLI and check your work.
 ```
wget https://github.com/duckdb/duckdb/releases/download/v0.5.1/duckdb_cli-linux-amd64.zip
unzip duckdb_cli-linux-amd64.zip
./duckdb
.open /tmp/mdsbox.db
SELECT * FROM test;
```
note to self: steps 4 to 8 should probably be a makefile. baby steps!

## Todos
- [x] write initial steps
- [ ] create a makefile so you 'make pipeline' and it just all happens
- [x] get data and load to ~~github~~ local storage
- [ ] find a web location for the source files
- [x] add extraction steps to spreadsheets anywhere
- [x] build basic data frame w/dbt
- [ ] build the monte carlo sim
- [ ] some basic charts in superset (replicate 538?)
