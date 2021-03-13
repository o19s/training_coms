library(gmailr)
library(googlesheets4)
library(tidyverse)

source("params.R")

gm_auth_configure()
gm_auth(user) # may require console interaction

gs4_auth(user)
roster <- read_sheet(sheet_url)
# ^^^^ Run interactive for auth porpoises ^^^^ -----------------------------------------------

source("body_templates.R")

# Set up ------------------------------------------------------------

# choose which one to use; has to be here b/c glue (or I could get tidy-eval-fancy)
roster$body <- eval(parse(text = email_body))

#' Create Gmail to save as draft or send. Also can attach certificates.
#' 
#' @param roster `data.frame` with class roster
#' @param draft `logical` Should emails be saved as a draft (TRUE) or sent
#' @param cert `logical` Should a certificate be attached
#' directly (FALSE)
make_email <- function(roster, draft = TRUE, cert = FALSE) {
  
  mime <- gm_mime() %>%
    gm_to(roster$email) %>%
    # the account you authenticated earlier
    gm_from(user) %>%
    gm_subject(email_subject) %>%
    gm_html_body(roster$body)
  
  if (cert){
    mime <- gm_attach_file(mime, roster$cert_path)
  }

  if (draft) { # create a draft
    gm_create_draft(mime)
  } else { # or send direct
    gm_send_message(mime)
  }
}


# Send it -----------------------------------------------------------------

sent <- roster %>%
  split(1:nrow(.)) %>%
  map(~ make_email(., draft = F, cert = F))
# sometimes this hangs, but running on a fresh restart seems to resolve
# so restart the R-session --> Re-auth --> Pray

