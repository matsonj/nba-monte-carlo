import os
import duckdb

# initiate the MotherDuck connection through a service token through
con = duckdb.connect('md:?motherduck_token=' + os.environ.get('MOTHERDUCK_TOKEN'))

con.sql("CREATE TABLE IF NOT EXISTS nba_history_v2.main.season_summary ( elo_rating VARCHAR(15), team VARCHAR(3), conf VARCHAR(4), record VARCHAR(10), avg_wins REAL, vegas_wins REAL, elo_vs_vegas REAL, win_range VARCHAR(15), seed_range VARCHAR(15), made_postseason INT, made_play_in INT, nba_sim_start_date DATETIME, made_playoffs INT, made_conf_semis INT, made_conf_finals INT, made_finals INT, won_finals INT, PRIMARY KEY (team,nba_sim_start_date))")

con.sql("INSERT OR IGNORE INTO nba_history_v2.main.season_summary (SELECT * FROM 'data/data_catalog/season_summar*.parquet')")

print("Data Loaded to Motherduck!")
