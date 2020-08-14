library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(leaflet)
library(shiny)
library(shinythemes)
library(stringr)
library(leaflet) 
library(lubridate) 
library(rgdal)  # for transforming spatial data
library(scales) # for axis labels on plot

# MAIN DATA SET FROM ZILLOW
oneBed <- read_csv("http://files.zillowstatic.com/research/public/County/County_Zhvi_1bedroom.csv")
twoBed <- read_csv("http://files.zillowstatic.com/research/public/County/County_Zhvi_2bedroom.csv")
threeBed <- read_csv("http://files.zillowstatic.com/research/public/County/County_Zhvi_3bedroom.csv")
fourBed <- read_csv("http://files.zillowstatic.com/research/public/County/County_Zhvi_4bedroom.csv")
fiveBed <- read_csv("http://files.zillowstatic.com/research/public/County/County_Zhvi_5BedroomOrMore.csv")

combined_data <- bind_rows(oneBed, twoBed, threeBed, fourBed, fiveBed, .id="source")

homeValueLong <- combined_data %>% 
  rename(Bedrooms = source) %>%
  transform(Bedrooms = factor(Bedrooms, labels=c("One", "Two", "Three", "Four", "Five+"))) %>%       # releveling to informative labels
  mutate(FIPS = paste0(StateCodeFIPS, MunicipalCodeFIPS)) %>%                                        # combining two FIPS codes into the full code - for spatial matching
  select(-c("SizeRank", "RegionType", "RegionID", "StateName", "MunicipalCodeFIPS", "StateCodeFIPS")) %>%       # removing extra variables
  pivot_longer(-c("Bedrooms", "RegionName", "State", "Metro", "FIPS"), names_to = "Date", values_to = "HomeValue")   %>% # reshaping to long format
  transform(Date = as.Date(str_sub(Date, 2, -1), format="%Y.%m.%d"))

            
# SPATIAL DATA
countyData <- tigris::counties(cb=TRUE) %>%
  spTransform(CRS("+init=epsg:4326"))


# SAVING/LOADING DATA LOCALLY IF WEB SOURCES ARE UNAVAILABLE
# saveRDS(homeValueLong, "homeValueLong")
# saveRDS(countyData, "countyData")
 
#  homeValueLong <- readRDS("homeValueLong")
#  countyData <- readRDS("countyData")
