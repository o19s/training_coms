library(magrittr)
library(httr)
library(tidyverse)

password <- Sys.getenv("BADGER_PW")

badgr_auth <- function(user, password) {
  POST(
    "https://api.badgr.io/o/token",
    body = list("username" = user,
                "password" = password),
    encode = "form"
  )
}

resp <- badgr_auth("nday@opensourceconnections.com", password)
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
    'https://api.badgr.io/v2/badgeclasses/y9tZlxwnTimdkQ_oI2DpKw/assertions',
    body = body_li,
    content_type_json(),
    add_headers(Authorization = paste("Bearer", token))
  ) %>% 
    content() %>% 
    .[["result"]] %>%
    unlist() %>%
    .['openBadgeId']
  
}

#award_badge("nathancday@gmail.com", classes[2])
# save this returned value back into roster for use in `certificates.R`


# Award and record --------------------------------------------------------
# This is where the magic happens

class_of_interest <- classes[2]

roster <- read_csv("roster.csv")
roster %<>% 
  rowwise() %>% 
  mutate(badger_id = unname(award_badge(Email, class_of_interest)))

write_csv(roster, "roster.csv")


# API sandbox -------------------------------------------------------------

GET(
  'https://api.badgr.io/v2/users/self',
  add_headers(Authorization = paste("Bearer", token))
)

# get a list of Badge entity_id
GET(
  'https://api.badgr.io/v2/badgeclasses',
  add_headers(Authorization = paste("Bearer", token))
) %>% 
  content()

# TLRE-ES
GET(
  'https://api.badgr.io/v2/badgeclasses/y9tZlxwnTimdkQ_oI2DpKw/assertions',
  add_headers(Authorization = paste("Bearer", token))
) %>% 
  content()
