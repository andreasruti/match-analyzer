
################################################################################
# imports
################################################################################

# load libraries
suppressMessages(suppressWarnings(library(dplyr)))

# load python code
reticulate::source_python("functions/functions.py")


################################################################################
# for import_data.R
################################################################################

#' Import games of a seasons from the five leagues. For currrent season don't 
#' define season argument!
#' 
#' @param season numeric value, e.g. 2019 for season 2020/21
#' @return list containing 5 data frames (1 per league)
import_games <- function(season = NULL) {
  
  if (is.null(season)) {
    current_date <- Sys.Date()
    current_month <- lubridate::month(current_date)
    current_year <- lubridate::year(current_date)
    season <- if (current_month > 7) current_year else current_year - 1
  }
  
  leagues <- c("EPL", "La_liga", "Bundesliga", "Serie_A", "Ligue_1")
  
  file_name <- paste0("data/games_", season, ".rds")
  
  tmp_list <- list()
  
  # loop over leagues
  for (i in leagues) {
    tmp_list[[i]] <- scrape_games(league = i, season = season)
    saveRDS(tmp_list, file = file_name)
  }
  
  cat(paste0(file_name, " imported."))
  cat("\n")
  
}

#' Import shots of all the seasons' games from the five leagues. For currrent 
#' season don't define season argument!
#' 
#' @param season numeric value, e.g. 2019 for season 2020/21
#' @return list containing 5 data frames (1 per league)
import_shots <- function(season = NULL) {
  
  if (is.null(season)) {
    current_date <- Sys.Date()
    current_month <- lubridate::month(current_date)
    current_year <- lubridate::year(current_date)
    season <- if (current_month > 7) current_year else current_year - 1
  }
  
  tmp_games <- readRDS(paste0("data/games_", season, ".rds"))
  
  leagues <- c("EPL", "La_liga", "Bundesliga", "Serie_A", "Ligue_1")
  
  file_name <- paste0("data/shots_", season, ".rds")
  
  tmp_list <- list()
  
  # loop over leagues
  for (i in leagues) {
    
    # grab league's game ids
    game_ids <- tmp_games[[i]] %>% 
      # remove if game did not take place yet
      dplyr::filter(!is.na(H_GOALS)) %>%
      # remove if game doesn't have any stats
      dplyr::filter(H_XG != 0 | A_XG != 0) %>% 
      dplyr::pull(ID)
    
    tmp_league_list <- vector("list", length(game_ids))
    
    # showing progress
    cat("\n")
    cat(paste0("Importing shots of ", i, " (", season, ")..."))
    cat("\n")
    pb <- txtProgressBar(min = 0, 
                         max = length(tmp_league_list), 
                         initial = 0,
                         style = 3) 
    
    # loop over games
    for (j in 1:length(tmp_league_list)) {
      tmp_league_list[[j]] <- scrape_shots(game_id = game_ids[j])
      setTxtProgressBar(pb, j)
    }
    
    # name list elements with game id
    names(tmp_league_list) <- game_ids
    
    # convert list to data frame
    tmp_league_df <- bind_rows(tmp_league_list, .id = "column_label")
    
    # add league's data frame to list
    tmp_list[[i]] <- tmp_league_df
  }
  
  # export list
  saveRDS(tmp_list, file = file_name)
  
  cat("\n")
  cat(paste0(file_name, " imported."))
  
}






################################################################################
# functions not in use
################################################################################

# get_table_pl <- function() {
#   dat <- 
#     reticulate::py_run_file(file = "pl_current_season.py")$pl_table %>% 
#     as.data.frame()
#   return(dat)
# }