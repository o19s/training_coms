library(googlesheets4)
library(magrittr)
library(httr)
library(tidyverse)

source("params.R")

#' Authenticate yourself to the Badgr API
#' 
#' @param user Email address of associated account
#' @param password Password for associate account
badgr_auth <- function(user, password) {
  httr::POST(
    "https://api.badgr.io/o/token",
    body = list("username" = user,
                "password" = password),
    encode = "form"
  )
}

resp <- badgr_auth(user, password)
token <- content(resp)$access_token

#' Return a named list of entityIds to be used in other API calls
#' 
#' @value `character` Names show free form text ID (class name), values show entityIDs
available_classes <- function() {
  GET(
    'https://api.badgr.io/v2/badgeclasses',
    add_headers(Authorization = paste("Bearer", token))
  ) %>% 
    content() %>% 
    .[["result"]] %>% 
    map(function(x) x$entityId %>% set_names(x$name)) %>%
    unlist()
}

classes <- available_classes()
classes

#' Award an individual badge based on email address
#' 
#' @param email `character` email address used by awardee
#' @param class `character` entityID representing the course, from `available_classes()`
#' @value `character` URL for proof of certificate
award_badge <- function(email, class) {
  
  # construct body
  body_li <- list("recipient" =
                    list("identity" = email,
                         "type" = "email")) %>% 
    jsonlite::toJSON(auto_unbox = TRUE) # prevents making everything an array, which would cause API error
  
  POST(
    glue::glue('https://api.badgr.io/v2/badgeclasses/{class}/assertions'),
    body = body_li,
    content_type_json(),
    add_headers(Authorization = paste("Bearer", token))
  ) %>% 
    content() %>% 
    .[["result"]] %>%
    unlist() %>%
    .['openBadgeId']
  
}

# award_badge("nathancday@gmail.com", classes[2])
# save this returned value back into roster for use in `certificates.R`


# Award and record --------------------------------------------------------
# This is where the magic happens

class_of_interest <- classes[3]
class_of_interest

gs4_auth(user)
roster <- read_sheet(sheet_url) # interactive in console
roster

roster %<>% 
  rowwise() %>% 
  mutate(badger_id = unname(award_badge(email, class_of_interest)))

write_sheet(roster, sheet_url, 1)

