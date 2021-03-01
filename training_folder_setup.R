library(magrittr)
library(googledrive)
library(tidyverse)

drive_auth()

# Prep folder tree --------------------------------------------------------

# Where the main files live
tlre_main <- "1IkMsijn0jQGzJFl1qE9O1m2Wn0jYU-aZ"
ltr_main <- "1Xk5bfDO1q-I_DBRIFR0TObF7OZNZYGRM"

main_ls <- drive_ls(as_id(ltr_main)) # swap out as appropriate

# Where the new files go
new_dir <- "Hello_LTR_2020_02_16"

# Create a new class inside "Previous Classes" directory
tlre_prev <- "1bbHpIBlaOZ1JAyBPv3geuyfC0rh9eYIu"
ltr_prev <- "1aHnIMPbr6M1w-0floNQ2z-f62zm0If3u"

prev_classes_dir <- as_id(ltr_prev) # swap out as appropriate
resp <- drive_mkdir(new_dir, prev_classes_dir)

target_id <- resp$id
drive_ls(as_id(target_id)) # visually confirming

# create four folders/days; save ids for later
day_dirs <- paste0("Day", 1:4) %>% 
  purrr::map(~ drive_mkdir(., as_id(target_id)))


# Helper funcs ------------------------------------------------------------

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

# pull out the DriveID for a given folder
pull_id <- function(ls_df, pattern) {
  x <- filter(ls_df, grepl(pattern, name)) %>% 
    pull(id)
  stopifnot(length(x) == 1)
  x
}

# Day 3 and 4 are messier b/c ES and Solr
messy_ls <- function(x, engine = "Elasticsearch") {
  unlist(x) %>% 
    as_id() %>% 
    drive_ls() %>% 
    filter(name == engine) %>% 
    pull(id) %>% 
    make_ls()
}


# Copy folders (actually file by file b/c Drive sux) --------


# * TLRE ------------------------------------------------------------------
eng <- "Elasticsearch"

d1 <- pull_id(main_ls, "Part 1") %>% make_ls()
copy_that(d1, day_dirs[[1]][["id"]])

d2 <- pull_id(main_ls, "Part 2") %>% make_ls()
copy_that(d2, day_dirs[[2]][["id"]])

d3 <- pull_id(main_ls, "Part 3") %>% messy_ls(eng)
copy_that(d3, day_dirs[[3]][["id"]])

d4 <- pull_id(main_ls, "Part 4") %>% messy_ls(eng)
copy_that(d4, day_dirs[[4]][["id"]])

# *Hello LTR ---------------------------------------------------------------


d1 <- pull_id(main_ls, "Day 1") %>% make_ls()
copy_that(d1, day_dirs[[1]][["id"]])

d2 <- pull_id(main_ls, "Day 2") %>% make_ls()
copy_that(d2, day_dirs[[2]][["id"]])

d3 <- pull_id(main_ls, "Day 3") %>% make_ls()
copy_that(d3, day_dirs[[3]][["id"]])

d4 <- pull_id(main_ls, "Day 4") %>% make_ls()
copy_that(d4, day_dirs[[4]][["id"]])
