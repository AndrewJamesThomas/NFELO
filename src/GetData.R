library(nflfastR)
library(dplyr)

i <- 2010
while (i <= 2023){
  temp_df_ <- load_pbp(i) %>% 
    group_by(week, home_team, away_team) %>% 
    summarize(home_score = max(total_home_score), 
              away_score = max(total_away_score),
              home_win = home_score >= away_score,
              away_win = away_score >= home_score,
              season = i
    ) %>% 
    ungroup  
  
  if (i == 2010) {
    df <- temp_df_
  } else {
    df <- temp_df_ %>% 
      bind_rows(df)
  }
  
  i <- i + 1
}

write.csv(df, "data/historic_data.csv", row.names=FALSE)

