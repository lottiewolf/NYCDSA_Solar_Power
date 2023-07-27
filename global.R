
library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggridges)
library(usmap)
library(maps)
library(RColorBrewer)
library(ggiraph)
library(DT)

eGrid <- read.csv(file = "./data/eGrid.csv")
track_sun <- read.csv(file = "./data/track_sun.csv")
gei_price <- read.csv(file = "./data/gei_price.csv")
state_pop <- read.csv(file = "./data/state_pop.csv")

