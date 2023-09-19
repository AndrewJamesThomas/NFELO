library(DBI)
source("src/functions.R")
source("src/BuildDatabase.R")


# connect to databse
mydb <- dbConnect(RSQLite::SQLite(), "data/my-db.sqlite")

# run elo loop
# loop through years
for (year in 2010:2023){
  for (w in 1:22){
    game <- year+w/100
    # get elo data
    query <- sprintf("SELECT g.*, 
                    (select elo from Schedule 
                      where game <= g.game and team=g.home_team 
                      order by game desc
                      limit 1) as home_elo, 
                    (select elo from Schedule 
                      where game <= g.game and team=g.away_team 
                      order by game desc
                      limit 1) as away_elo
              FROM Games g
              where g.season = %s and g.game = %s", year, game)
    weekly_data <- dbGetQuery(mydb, query)
    
    # run ELO model
    weekly_data <- weekly_data %>% 
      mutate(proba=get_probability(home_elo, away_elo),
             home_elo_updated=update_elo(home_elo, proba, home_win),
             away_elo_updated=update_elo(away_elo, proba, away_win))
    
    updated_home <- weekly_data %>% 
      select(team=home_team, season, game, elo=home_elo_updated) %>% 
      mutate(game=game+0.01)
    
    updated_away <- weekly_data %>% 
      select(team=away_team, season, game, elo=away_elo_updated) %>% 
      mutate(game=game+0.01)
    
    dbWriteTable(mydb, "Schedule", updated_home, append=TRUE)
    dbWriteTable(mydb, "Schedule", updated_away, append=TRUE)
  }
}

dbDisconnect(mydb)