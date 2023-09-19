library(DBI)

# create databse
mydb <- dbConnect(RSQLite::SQLite(), "data/my-db.sqlite")


# load and process data
df <- read_csv("data/historic_data.csv")
df <- df %>% 
  mutate(game=((week/100))+season)

schedule <- tibble(team=unique(df$home_team),
                   season=2010,
                   game=((1/100))+season,
                   elo=1500)


# load data tables to database
dbWriteTable(mydb, "Games", df, overwrite=TRUE)
dbWriteTable(mydb, "Schedule", schedule, overwrite=TRUE)


dbDisconnect(mydb)
