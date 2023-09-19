# define functions for ELO model
get_probability <- function(elo1, elo2){
  identity <- elo2 - elo1
  proba <- (1+10^(identity/400))^-1
  return(proba)
}

update_elo <- function(elo, win_proba, team_win, k=8){
  new_elo <- elo + k*(team_win - win_proba)
  return(new_elo)
}