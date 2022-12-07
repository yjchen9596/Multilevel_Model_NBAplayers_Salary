

###### Data source##########

# Our season total performance and salary data sets were collected from Basketball Reference (<https://www.basketball-reference.com/>)

# original data cleaning process can be found here: https://github.com/yjchen9596/NBA-Players-Salary-Prediction

library(tidyverse)
library(rjags)
library(coda)
library(superdiag)
library(R2WinBUGS)
library(R2jags)
library(patchwork) ## for ggplots bind
library(foreign)
library(arm)
library(GGally) # for ggpairs
library(magrittr)

salaries_record <- read_csv("salaries_1985to2018.csv") |> 
  dplyr::select(-league)
player16_17 <- read_csv("player16_17.csv")
player17_18 <- read_csv("player17_18.csv")
player17_18 |>  
  dplyr::select(-trans_team) -> player17_18
names(player16_17)<- tolower(names(player16_17))
names(player17_18)<- tolower(names(player17_18))
salaries_record |> 
  filter(season_start == 2017 | season_start == 2016) -> season16to18
player16_17 |> 
  left_join(salaries_record) |> 
  filter(season_start == 2016) -> player16_17_sa
player17_18 |> 
  left_join(salaries_record) |> 
  filter(season_start == 2017) -> player17_18_sa

bind_rows(player16_17_sa, player17_18_sa, .id = "season.1_1611.2_1718") -> NBA_ORG


NBA_ORG <- NBA_ORG |> 
  dplyr::select(player_id, salary, everything(), -season.1_1611.2_1718, -player, -team) |> 
  dplyr::select(-matches("\\%"),-matches("..a$")) |> 
  mutate(age_group = cut(NBA_ORG$age, 3, labels=c('Young', 'Medium', 'Aged')),
         team = as.integer(factor(tm)),
         position = as.integer(factor(pos))) |> 
  mutate(age_group = as.numeric(age_group))


map_df(NBA_ORG, ~sum(is.na(.))) 

NBA_ORG$age %<>% as.numeric()
typeof(NBA_ORG$age) 



write_csv(NBA_ORG,"NBA.csv")
