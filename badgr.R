library(googlesheets4)
library(httr)
library(tidyverse)

source("functions.R")
source("params.R")


# Auth and setup ----------------------------------------------------------
# manual adjustment req'd

# get the roster
gs4_auth(user)
roster <- read_sheet(sheet_url)
roster

# ping the BadgrAPI
resp <- badgr_auth(user, password)
token <- content(resp)$access_token

classes <- available_classes()
classes

class_of_interest <- classes[2]
class_of_interest

# this is a test...
# award_badge("nathancday@gmail.com", class_of_interest)

# Award and record --------------------------------------------------------
# This is where the magic happens

roster <- roster %>% 
  rowwise() %>% 
  mutate(badger_id = unname(award_badge(email, class_of_interest)))

write_sheet(roster, sheet_url, 1)

