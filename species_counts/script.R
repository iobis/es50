library(dplyr)

sp <- read.csv("species_counts.csv", stringsAsFactors = FALSE, na.strings = "")

stats <- sp %>%
  filter(!is.na(gr)) %>%
  mutate(nrecords = ifelse(count == 1, 1, "more")) %>%
  group_by(gr, nrecords) %>%
  summarize(nspecies = n())
