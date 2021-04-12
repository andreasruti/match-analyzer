
################################################################################
# source functions
################################################################################
source("functions/functions.R")



################################################################################
# import games
################################################################################

# # import all games
# years <- 2014:2020
# for (i in years){
#   import_summary(summary = "games", season = i)
# }

import_summary(summary = "games")
# games2020 <- readRDS("data/games-2020.rds")
# View(games2020$EPL)



################################################################################
# import teams data
################################################################################

# # import all players data
# years <- 2014:2020
# for (i in years){
#   import_summary(summary = "teams", season = i)
# }

import_summary(summary = "teams")
# teams2020 <- readRDS("data/teams-2020.rds")
# View(teams2020$Ligue_1)


################################################################################
# import players data
################################################################################

# # import all players data
# years <- 2014:2020
# for (i in years){
#   import_summary(summary = "players", season = i)
# }

import_summary(summary = "players")
# players2020 <- readRDS("data/players-2020.rds")
# View(players2020$Ligue_1)



################################################################################
# import rosters
################################################################################

# # import all rosters
# years <- 2014:2020
# for (i in years){
#   import_stats("rosters", i)
# }

import_stats(stats = "rosters", season = NULL)
# import_stats(stats = "rosters", season = 2020)
# rosters2020 <- readRDS("data/rosters-2020.rds")
# View(rosters2020$Bundesliga)




################################################################################
# import shots
################################################################################

# # import all shots
# years <- 2014:2020
# for (i in years){
#   import_stats("shots", i)
# }

import_stats(stats = "shots", season = NULL)
# shots2015 <- readRDS("data/shots-2015.rds")
# shots2020 <- readRDS("data/shots-2020.rds")
# shots2017 <- readRDS("data/shots-2017.rds")




################################################################################
# get tables - TEST
################################################################################

table_pl_2021 <- get_table(season = 2020, league = "Premier League")
table_pl_0809 <- get_table(season = 2008, league = "Premier League")

table_bl_2021 <- get_table(season = 2020, league = "Bundesliga")
table_bl_0809 <- get_table(season = 2008, league = "Bundesliga")

table_ll_0809 <- get_table(season = 2008, league = "La Liga")

table_sa_1011 <- get_table(season = 2010, league = "Serie A")

table_l1_1314 <- get_table(season = 2013, league = "Ligue 1")
























# EPL <- list()
# La_liga <- list()
# Bundesliga <- list()
# Serie_A <- list()
# Ligue_1 <- list()
# 
# for (i in seasons) {
#   EPL[[i]] <- get_games(league = "EPL", season = i)
#   La_liga[[i]] <- get_games(league = "La_liga", season = i)
#   Bundesliga[[i]] <- get_games(league = "Bundesliga", season = i)
#   Serie_A[[i]] <- get_games(league = "Serie_A", season = i)
#   Ligue_1[[i]] <- get_games(league = "Ligue_1", season = i)
#   
#   save(EPL, file = "data/games_epl.RData")
#   save(La_liga, file = "data/games_laliga.RData")
#   save(Bundesliga, file = "data/games_bundesliga.RData")
#   save(Serie_A, file = "data/games_seriea.RData")
#   save(Ligue_1, file = "data/games_ligue1.RData")
# }



################################################################################
# Get games tries
################################################################################


# for (i in seasons) {
#   
#   assign(x = i, sapply(leagues, function(x) NULL))
#   
#   for (j in leagues) {
#     
#     tmp_df <- get_games(league = j, season = i)
#     tmp_name <- j
#     assign(x = tmp_name, tmp_df)
#     
#   }
# }

# for (i in seasons) {
#   
#   for (j in leagues) {
#     
#     tmp_df <- get_games(league = j, season = i)
#     tmp_name <- paste(j, i, sep = "_")
#     
#     print(paste0(tmp_name, "..."))
#     assign(x = tmp_name, tmp_df)
# 
#   }
# }

# for (i in seasons) {
#   
#   tmp_name <- paste0("season_", i)
#   assign(x = tmp_name, sapply(leagues, function(x) NULL))
#   
#   for (j in leagues) {
#     tmp_df <- get_games(league = j, season = i)
#     print(head(tmp_df))
#     # tmp[[j]] <- tmp_df
#     assign(tmp_name[[j]], tmp_df)
#   }
# }

# for (i in seasons) {
#   for (j in leagues) {
#     tmp_name <- paste("season", i, j, sep = "_")
#     assign(x = tmp_name, sapply(leagues, function(x) get_games(league = j, season = i)))
#   }
# }
