library(magrittr)
library(googledrive)
library(tidyverse)

drive_auth()

# Where the main files live
main_id <- "1IkMsijn0jQGzJFl1qE9O1m2Wn0jYU-aZ"
main_ls <- drive_ls(as_id(main_id))

# Create a new class inside "Previous Classes" directory
prev_classes_dir <- as_id("1bbHpIBlaOZ1JAyBPv3geuyfC0rh9eYIu")
resp <- drive_mkdir("TLRE_Solr_2020_07_22", prev_classes_dir)

target_id <- resp$id
drive_ls(as_id(target_id)) # visually confirming

# create four folders/days; save ids for later
day_dirs <- paste0("Day", 1:4) %>% 
  purrr::map(~ drive_mkdir(., as_id(target_id)))

# fillet dirs of files for replication
make_ls <- . %>% 
  unlist() %>% 
  as_id() %>% 
  drive_ls() %>% 
  select(-drive_resource) %>% 
  deframe()

# iterate over named array to upload individual files
copy_that <- function(id, target_id) {
  map2(id, names(id),
       ~ drive_cp(as_id(.x), as_id(target_id), .y))
}

d1 <- main_ls[1,2] %>% make_ls()
the_copier(d1, day_dirs[[1]][["id"]])

d2 <- main_ls[4,2] %>% make_ls()
copy_that(d2, day_dirs[[2]][["id"]])

# Day 3 and 4 are messier b/c ES and Solr
messy_ls <- function(x, engine = "Elasticsearch") {
  unlist(x) %>% 
    as_id() %>% 
    drive_ls() %>% 
    filter(name == engine) %>% 
    pull(id) %>% 
    make_ls()
}

d3 <- main_ls[3,2] %>% messy_ls("Solr")
copy_that(d3, day_dirs[[3]][["id"]])

d4 <- main_ls[2,2] %>% messy_ls("Solr")
copy_that(d4, day_dirs[[4]][["id"]])
