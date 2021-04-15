
################################################################################
# imports
################################################################################

# load libraries
packages <- c("dplyr", "lubridate", "reticulate", "shiny", "shinydashboard",
              "ggplot2", "plotly")

suppressMessages(
  suppressWarnings(
    lapply(packages, require, character.only = TRUE)
  )
)

# source python functions
reticulate::source_python("functions/functions.py")




################################################################################
# for import_data.R
################################################################################

#' Import games and players data of a seasons from the five leagues. For 
#' current season don't define season argument!
#' 
#' @param summary string - "games", "teams" or "players"
#' @param season numeric value, e.g. 2019 for season 2020/21
#' @return list containing 5 data frames (1 per league)
import_summary <- function(summary, season = NULL) {
  
  if (is.null(season)) {
    current_date <- Sys.Date()
    current_month <- lubridate::month(current_date)
    current_year <- lubridate::year(current_date)
    season <- if (current_month > 7) current_year else current_year - 1
  }
  
  leagues <- c("EPL", "La_liga", "Bundesliga", "Serie_A", "Ligue_1")
  
  file_name <- paste0("data/", summary, "-", season, ".rds")
  
  tmp_list <- list()
  
  # loop over leagues
  for (i in leagues) {
    
    cat("\n")
    cat(paste0("Importing ", summary, " of ", i, " (", season, ")..."))
    
    if (summary == "games") {
      tmp_list[[i]] <- scrape_games(league = i, season = season)
    }
    
    if (summary == "teams") {
      tmp_list[[i]] <- scrape_teams(league = i, season = season)
    }
    
    if (summary == "players") {
      tmp_list[[i]] <- scrape_players(league = i, season = season)
    }
  }
  
  saveRDS(tmp_list, file = file_name)
  
  cat("\n")
  cat("\n")
  cat(paste0(file_name, " imported."))
  cat("\n")
  cat("\n")
}




#' Import stats of all the seasons' games from the five leagues. For current 
#' season don't define season argument. Choose rosters or shots as stats.
#' 
#' @param stats string - "rosters" or "shots"
#' @param season numeric value, e.g. 2019 for season 2019/20, NULL for current 
#' season update
#' @return list containing 5 data frames (1 per league)
import_stats <- function(stats, season = NULL) {
  
  # set update = TRUE if season is NULL
  update <- if (is.null(season)) TRUE else FALSE
  no_update_avbl <- 0
  
  # grab current season for update of most recent data
  if (update) {
    current_date <- Sys.Date()
    current_month <- lubridate::month(current_date)
    current_year <- lubridate::year(current_date)
    season <- if (current_month > 7) current_year else current_year - 1
  }
  
  tmp_games <- readRDS(paste0("data/games-", season, ".rds"))
  
  leagues <- c("EPL", "La_liga", "Bundesliga", "Serie_A", "Ligue_1")
  
  file_name <- paste0("data/", stats, "-", season,".rds")
  
  tmp_list <- list()
  
  # loop over leagues
  for (i in leagues) {
    
    all_games <- tmp_games[[i]]
    
    if (update) {
      
      # read in stats table we have already
      avbl_league_list <- readRDS(file_name)[[i]]
      
      # check which played games stats are imported already
      avbl_ids <- unique(avbl_league_list$MATCH_ID)
      
      # only keep the games that are not there yet
      all_games <- all_games %>% 
        dplyr::filter(!ID %in% avbl_ids)
      
    }
    
    # grab league's game ids
    game_ids <- all_games %>% 
      # keep played games only
      dplyr::filter(ISRESULT) %>%
      # remove if game doesn't have any stats (url doesn't provide any stats)
      dplyr::filter(H_XG != 0 | A_XG != 0) %>% 
      dplyr::pull(ID)
    
    tmp_league_list <- vector("list", length(game_ids))
    
    cat("\n")
    cat(paste0("Importing ", stats, " of ", i, " (", season, ")..."))
    cat("\n")
    
    # jump to next iteration if no updates are available
    if (length(game_ids) == 0) {
      
      no_update_avbl <- no_update_avbl + 1
      cat("No updates available!")
      cat("\n")
      
    } else {
      
      # showing progress
      pb <- txtProgressBar(
        min = 0, 
        max = length(tmp_league_list),
        initial = 0,
        style = 3
      ) 
      
      # loop over games
      for (j in 1:length(tmp_league_list)) {
        
        if (stats == "rosters") {
          tmp_league_list[[j]] <- scrape_rosters(game_id = game_ids[j])
        }
        
        if (stats == "shots") {
          tmp_league_list[[j]] <- scrape_shots(game_id = game_ids[j])
        }
        
        setTxtProgressBar(pb, j)
      }
      
      # name list elements with game id
      names(tmp_league_list) <- game_ids
      
      # convert list to data frame
      tmp_league_df <- dplyr::bind_rows(tmp_league_list)
    }
    
    # add league's data frame to list
    if (update & length(game_ids) != 0) {
      
      tmp_list[[i]] <- rbind(avbl_league_list, tmp_league_df)
      
    } else if (update & length(game_ids) == 0) {
      
      tmp_list[[i]] <- avbl_league_list
      
    } else {
      
      tmp_list[[i]] <- tmp_league_df
      
    }
  }
  
  # export list
  if (no_update_avbl != 5) {
    
    saveRDS(tmp_list, file = file_name)
    
    cat("\n")
    cat("\n")
    cat(paste0(file_name, " imported."))
    cat("\n")
    cat("\n")
  }
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