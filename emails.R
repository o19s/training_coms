library(gmailr)
library(googlesheets4)
library(magrittr)
library(tidyverse)

source("functions.R")
source("params.R")

gm_auth_configure()
gm_auth(user) # may require console interaction

gs4_auth(user)
roster <- read_sheet(sheet_url)
# ^^^^ Run interactive for auth porpoises ^^^^ -----------------------------------------------
source("body_templates.R")

# This is one time clean-uppy code for awk rosters, maybe you need it maybe you don't....
# roster %<>%
#   mutate(email = gsub(".*<(.*)>", "\\1", name),
#          name = gsub(" <.*", "", name)) %>% 
#   separate(name, c("first", "last"))

# Set up ------------------------------------------------------------

# choose which template to use; has to be here b/c glue (or I could get tidy-eval-fancy)
roster$body <- eval(parse(text = email_body))

# Send it -----------------------------------------------------------------

sent <- roster %>%
  split(1:nrow(.)) %>%
  map(~ make_email(., draft = F, cert = T))
# sometimes this hangs, but running on a fresh restart seems to resolve
# so restart the R-session --> Re-auth --> Pray

