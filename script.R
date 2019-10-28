library(dplyr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dggridR)
library(viridis)
library(gsl)
library(ggplot2)
library(ggpubr)
source("lib.R")

# config

datafile_name <- "taxonomy_grouped_20191027"
res <- 5

# construct discrete global grid system

dggs <- dgconstruct(projection = "ISEA", topology = "HEXAGON", res = res)

# download from OBIS, read occurrence data, and filter

dir.create("temp")
url <- paste0("https://download.obis.org/export/", datafile_name, ".zip")
zip_path <- paste0("temp/", datafile_name, ".zip")
csv_path <- paste0("temp/", datafile_name, ".csv")
if (!file.exists(zip_path)) {
  download.file(url, zip_path)
  unzip(zipfile = zip_path, exdir = "temp")
}
df <- read.csv(csv_path, stringsAsFactors = FALSE)

# add cell IDs, calculate metrics, add polygons

metrics <- df %>%
  add_cell(dggs) %>%
  calc(50) %>%
  add_polygons(dggs)

# write to shapefile

dir.create("shapefiles")
st_write(metrics, "shapefiles/grid.shp", delete_layer = TRUE)  

# plot

filter_geometry <- function(geometry) {
  lons <- geometry[[1]][,1]
  if (any(abs(diff(lons)) > 180)) {
    return(FALSE)
  }
  return(TRUE)
}

ok <- unlist(lapply(metrics$geometry, filter_geometry))
create_map(metrics[ok,], "es")
ggsave(filename = paste0("maps/es50.png"), height = 7, width = 12, dpi = 300, scale = 1.4)

# subsets

subsets <- list(
  mammalia = df %>% filter(classid == 1837),
  aves = df %>% filter(classid == 1836),
  actinopterygii = df %>% filter(classid == 10194),
  malacostraca = df %>% filter(classid == 1071),
  gastropoda = df %>% filter(classid == 101),
  elasmobranchii = df %>% filter(classid == 10193),
  cnidaria = df %>% filter(phylumid == 1267),
  annelida = df %>% filter(phylumid == 882),
  reptilia = df %>% filter(classid == 1838),
  arachnida = df %>% filter(classid == 1300)
)

for (name in names(subsets)) {
  message(name)
  metrics <- subsets[[name]] %>%
    add_cell(dggs) %>%
    calc(50) %>%
    add_polygons(dggs)
  dir.create("shapefiles")
  st_write(metrics, paste0("shapefiles/", name, ".shp"), delete_layer = TRUE)  
  ok <- unlist(lapply(metrics$geometry, filter_geometry))
  create_map(metrics[ok,], "es")
  ggsave(filename = paste0("maps/", name, ".png"), height = 7, width = 12, dpi = 300, scale = 1.4)
}
