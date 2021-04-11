
################################################################################
# imports
################################################################################

import requests
from bs4 import BeautifulSoup
import json
import pandas as pd
import re
import numpy as np



################################################################################
# for functions.R (used in import_data.R)
################################################################################

def scrape_games(league, season):
  """
  Scrape seasons' games of a league.
  
  Keyword arguments:
  league -- (str) league name: EPL, La_liga, Bundesliga, Serie_A, Ligue_1
  season -- (int) season, e.g. 2020 for 2020/21
  
  Returns:
  data frame
  """
  
  # ----------------------------------------------------------------------------
  # setup and scrape
  # ----------------------------------------------------------------------------
  
  season = int(season)
  url = 'https://understat.com/league/' + str(league) + '/' + str(season)
  r = requests.get(url)
  soup = BeautifulSoup(r.content, 'lxml')
  scripts = soup.find_all('script')
  
  # get dates data
  strings = scripts[1].string
  
  # strip symbols so we only have json data
  ind_start = strings.index("('") + 2
  ind_end = strings.index("')")
  
  json_data = strings[ind_start : ind_end]
  json_data = json_data.encode('utf8').decode('unicode_escape')
  
  # convert string to json format
  data = json.loads(json_data)
  
  
  # ----------------------------------------------------------------------------
  # build data frame and format
  # ----------------------------------------------------------------------------
  
  # build dataframe
  df = pd.DataFrame.from_dict(data)
  
  # column names to upper case
  df.columns = map(str.upper, df.columns)
  
  # add league and season column
  df['LEAGUE'] = league
  df['SEASON'] = season
  
  # remove forecast column
  df = df.drop(['FORECAST'], axis = 1)
  
  # unlist list columns and remove originals
  df[['H_ID','H_TITLE', 'H_SHORT_TITLE']] = pd.DataFrame(df.H.tolist(), index = df.index)
  df[['A_ID','A_TITLE', 'A_SHORT_TITLE']] = pd.DataFrame(df.A.tolist(), index = df.index)
  df[['H_GOALS','A_GOALS']] = pd.DataFrame(df.GOALS.tolist(), index = df.index)
  df[['H_XG','A_XG']] = pd.DataFrame(df.XG.tolist(), index = df.index)
  df.drop(['H', 'A', 'GOALS', 'XG'], axis=1, inplace=True)
  
  # convert columns to numeric if possible
  df = df.apply(pd.to_numeric, errors='ignore')
  
  return df




def scrape_players(league, season):
  """
  Scrape seasons' players data of a league.
  
  Keyword arguments:
  league -- (str) league name: EPL, La_liga, Bundesliga, Serie_A, Ligue_1
  season -- (int) season, e.g. 2020 for 2020/21
  
  Returns:
  data frame
  """
  
  # ----------------------------------------------------------------------------
  # setup and scrape
  # ----------------------------------------------------------------------------
  
  season = int(season)
  url = 'https://understat.com/league/' + str(league) + '/' + str(season)
  r = requests.get(url)
  soup = BeautifulSoup(r.content, 'lxml')
  scripts = soup.find_all('script')
  
  # get dates data
  strings = scripts[3].string
  
  # strip symbols so we only have json data
  ind_start = strings.index("('") + 2
  ind_end = strings.index("')")
  
  json_data = strings[ind_start : ind_end]
  json_data = json_data.encode('utf8').decode('unicode_escape')
  
  # convert string to json format
  data = json.loads(json_data)
  
  
  # ----------------------------------------------------------------------------
  # build data frame and format
  # ----------------------------------------------------------------------------
  
  # build dataframe
  df = pd.DataFrame.from_dict(data)
  
  # column names to upper case
  df.columns = map(str.upper, df.columns)
  
  # add league and season column
  df['LEAGUE'] = league
  df['SEASON'] = season
  
  # convert columns to numeric if possible
  df = df.apply(pd.to_numeric, errors='ignore')
  
  return df





def scrape_rosters(game_id):
  """
  Scrape rosters of a game.
  
  Keyword arguments:
  game_id -- (int) id of the game
  
  Returns:
  data frame
  """
  
  # ----------------------------------------------------------------------------
  # setup and scrape
  # ----------------------------------------------------------------------------
  
  game_id = int(game_id)
  url = 'https://understat.com/match/' + str(game_id)
  r = requests.get(url)
  soup = BeautifulSoup(r.content, 'lxml')
  scripts = soup.find_all('script')
  
  # get rosters data
  strings = scripts[2].string
  
  # strip symbols so we only have json data
  ind_start = strings.index("('") + 2
  ind_end = strings.index("')")
  
  json_data = strings[ind_start : ind_end]
  json_data = json_data.encode('utf8').decode('unicode_escape')
  
  # convert string to json format
  data = json.loads(json_data)
  
  
  # ----------------------------------------------------------------------------
  # build data frame and format
  # ----------------------------------------------------------------------------
  
  # build data frame, separated for h and a (home/away)
  df = pd.concat({k: pd.DataFrame(v).T for k, v in data.items()}, axis=0)
  
  # column names to upper case
  df.columns = map(str.upper, df.columns)
  
  # add match id
  df['MATCH_ID'] = game_id
  
  # convert columns to numeric if possible
  df = df.apply(pd.to_numeric, errors='ignore')
  
  return df





def scrape_shots(game_id):
  """
  Scrape all shots of a game.
  
  Keyword arguments:
  game_id -- (int) id of the game
  
  Returns:
  data frame
  """
  
  # ----------------------------------------------------------------------------
  # setup and scrape
  # ----------------------------------------------------------------------------
  
  game_id = int(game_id)
  url = 'https://understat.com/match/' + str(game_id)
  r = requests.get(url)
  soup = BeautifulSoup(r.content, 'lxml')
  scripts = soup.find_all('script')
  
  # get shots data
  strings = scripts[1].string
  
  # strip symbols so we only have json data
  ind_start = strings.index("('") + 2
  ind_end = strings.index("')")
  
  json_data = strings[ind_start : ind_end]
  json_data = json_data.encode('utf8').decode('unicode_escape')
  
  # convert string to json format
  data = json.loads(json_data)
  
  
  # ----------------------------------------------------------------------------
  # build data frame and format
  # ----------------------------------------------------------------------------
  
  # build data frame, separated for h and a (home/away)
  df = pd.concat({k: pd.DataFrame(v) for k, v in data.items()}, axis=0)
  
  # column names to upper case
  df.columns = map(str.upper, df.columns)
  
  # add column with the team owning the shot
  df['TEAM'] = np.where(df['H_A']=='h', df.H_TEAM.unique(), df.A_TEAM.unique())
  
  # unlist the PLAYER_ASSISTED column
  df['PLAYER_ASSISTED'] = df['PLAYER_ASSISTED'].apply(str)
  
  # convert columns to numeric if possible
  df = df.apply(pd.to_numeric, errors='ignore')
  
  return df





################################################################################
# functions not in use
################################################################################

def get_table(season, league):
  
  import requests
  from bs4 import BeautifulSoup
  import pandas as pd
  
  
  league = league.lower().replace(' ', '-')
  
  url = 'https://www.skysports.com/' + league + '-table/' + season
  
  r = requests.get(url)
  
  soup = BeautifulSoup(r.text, 'html.parser')
  
  league_table = soup.find('table', class_ = 'standing-table__table callfn')
  
  table_output = []
  
  # loop over teams
  for team in league_table.find_all('tbody'):
    rows = team.find_all('tr')
    
    # loop over rows
    for row in rows:
      league_season = str(season) + '/' + str(season + 1)[2:]
      league_rank = int(row.find_all('td', class_ = 'standing-table__cell')[0].text)
      league_team = row.find('td', class_ = 'standing-table__cell standing-table__cell--name').text.strip()
      league_games = int(row.find_all('td', class_ = 'standing-table__cell')[2].text)
      league_won = int(row.find_all('td', class_ = 'standing-table__cell')[3].text)
      league_draw = int(row.find_all('td', class_ = 'standing-table__cell')[4].text)
      league_lost = int(row.find_all('td', class_ = 'standing-table__cell')[5].text)
      league_goalsfor = int(row.find_all('td', class_ = 'standing-table__cell')[6].text)
      league_goalsagainst = int(row.find_all('td', class_ = 'standing-table__cell')[7].text)
      league_goaldiff = league_goalsfor - league_goalsagainst
      league_points = int(row.find_all('td', class_ = 'standing-table__cell')[9].text)
      
      # fill table
      table_output.append(
        {
          'SEASON': league_season,
          'RK': league_rank,
          'TEAM': league_team,
          'MP': league_games,
          'W': league_won,
          'D': league_draw,
          'L': league_lost,
          'GF': league_goalsfor,
          'GA': league_goalsagainst,
          'GD': league_goaldiff,
          'PTS': league_points,
        }
      )
  
  table_output = pd.DataFrame(table_output)
  
  return table_output
