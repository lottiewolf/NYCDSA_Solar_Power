
#install.packages('gdal-config')
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggridges)
library(stringr)

###################eGRID EPA - Total Electricity Generation#####################
#https://www.epa.gov/egrid
#https://www.epa.gov/egrid/data-explorer

setwd("~/Documents/code/NYCDSA/4.5-R Shiny Project")
eGRID_RAW <- read.csv(file = "./data/eGRID-EPA/e-grid.csv")

eGRID_RAW$Region = str_to_title(eGRID_RAW$Region)
head(eGRID_RAW)

#write the cleaned dataframe to file, so it can be loaded by the shiny app
write.csv(eGRID_RAW, "./data/eGrid.csv", row.names=FALSE)

#Group by state and sum
eGrid = eGRID_RAW[,-5] 
head(eGrid)

eGrid %>%
  filter(Year==2018 & Type=="total") %>%
  ggplot(aes(x = reorder(Region, -Generation_Mwh), y = Generation_Mwh)) +
  geom_col(fill = "lightblue") +
  labs(title="Total Generation (MWh) for 2018") +
  xlab("State") +
  ylab("MWh") +
  theme(axis.text.x = element_text(angle = 90))

eGrid %>%
  filter(Year==2021) %>%
  spread("Type", "Generation_Mwh") %>%
  left_join(state_pop, by=c('Region'='state')) %>%
  mutate(gap=((total-solar)/state_pop)) %>%
  ggplot(aes(x = reorder(Region, -Generation_Mwh), y = Generation_Mwh)) +
  geom_col(fill = "lightblue") +
  labs(title="Difference between total and solar power generation (MWh) for 2021") +
  xlab("State") +
  ylab("MWh") +
  theme(axis.text.x = element_text(angle = 90))


####################Tracking the Sun - Solar Generation Capacity################
#load the raw data from the csv from the website
#   https://emp.lbl.gov/tracking-the-sun

setwd("~/Documents/code/NYCDSA/4.5-R Shiny Project")
track_sun_RAW <- read.csv(file = "./data/Tracking-the-Sun/TTS_LBNL_public_file_07-Sep-2022_all.csv")

#from the raw data, keep only necessary columns, 
#   drop missing data (no missing data for state, .5% of system_size_DC is missing - 13,341 rows of 2,362,537)
track_sun = track_sun_RAW %>%
  select(state, system_size_DC) %>%
  filter(system_size_DC>=0)
summary(track_sun)

#Group by state and sum the capacity per state
track_sun_by_state = track_sun %>%
  group_by(state) %>%
  summarise(tot_capacity = sum(system_size_DC))
summary(track_sun_by_state)

#write the cleaned dataframe to file, so it can be loaded by the shiny app
write.csv(track_sun_by_state, "./data/track_sun.csv", row.names=FALSE)


###################GEI - Avg retail electricity price###########################
#https://www.globalenergyinstitute.org/average-electricity-retail-prices-map

setwd("~/Documents/code/NYCDSA/4.5-R Shiny Project")
gei_price_RAW <- read.csv(file = "./data/GEI/GlobalEnergyInstitute-avg-electricity-retail-prices-2021.csv")

#str_split_fixed(gei_price_RAW$state, ' ', 2)
#gei_price_RAW[c('State1', 'State2', 'Cents per kwh')] <- str_split_fixed(gei_price_RAW$state, ' ', 3)
gei_price = gei_price_RAW %>% 
  transmute(squished = str_squish(cents.per.kilowatt.hour)) %>%
  separate(squished, c('State', 'Cents per kwh'), sep="\\s+(?=\\S*$)")
gei_price

#write the cleaned dataframe to file, so it can be loaded by the shiny app
write.csv(gei_price, "./data/gei_price.csv", row.names=FALSE)
gei_price <- read.csv(file = "./data/gei_price.csv")

gei_price %>%
  mutate(highlight = ifelse(State == "California", "1", "0")) %>%
  ggplot(aes(x = reorder(State, -Cents.per.kwh), y = Cents.per.kwh, fill=highlight)) + 
  geom_bar(stat="identity") +
  ggtitle("Average Retail Electricity Price (Cents per kilowatt hour) by state for 2021") +
  xlab("State") +
  ylab("Cents per kilowatt hour") +
  theme(axis.text.x = element_text(angle = 90)) +
  scale_fill_manual( values = c( "1"="darkblue", "0"="lightblue" ),guide = FALSE )
gei_price


#######################zip code, state code#####################################
#https://simplemaps.com/data/us-zips

setwd("~/Documents/code/NYCDSA/4.5-R Shiny Project")
uszips_RAW <- read.csv(file = "./data/state-zip/simplemaps_uszips_basicv1.82/uszips.csv")

state_pop = uszips_RAW %>%
  select(zip, state_id, state_name, population, county_names_all) %>%
  group_by(state_id) %>%
  summarise(state_pop=sum(population), state=unique(str_to_title(state_name))) %>%
  filter(!is.na(state_pop))
print(state_pop, n=55)

#write the cleaned dataframe to file, so it can be loaded by the shiny app
write.csv(state_pop, "./data/state_pop.csv", row.names=FALSE)


##############################further possibilities#############################

#https://www.nerc.com/pa/RAPA/ESD/Pages/default.aspx
#https://github.com/owid/energy-data
#https://github.com/catalyst-cooperative/pudl
#nasa solar radiation dataset
#https://power.larc.nasa.gov/data-access-viewer/
