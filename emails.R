library(gmailr)
library(tidyverse)

gm_auth_configure()
gm_auth() # require console interaction

roster <- read_csv("roster.csv") %>% 
  mutate(First = gsub(" .*", "", Name),
         BadgeId = gsub("\\?.*", "", BadgeId))

trainers_signature <- "Eric, Max and Nate"

# Body templates ----------------------------------------------------------
# this allows customization based on the other column values in roster.csv
welcome_body <- glue::glue(
 "Hi {roster$First},
 <br>
 <br>
 TDB
 " 
)

follow_up_body <- glue::glue(
  "Hi {roster$First},
  <br>
  <br>
  Thanks so much for coming to the training last week.  It was great learning with you.
  <br>
  <br>
  Attached is your certificate!  You should have received a separate email from badgr.io that has a digital award you can use and share on LinkedIn.  See <a href='https://docs.google.com/document/d/1edUjY0kmVpD2J6cDYQIYPXBnwK-pnQ2I0Rb0chqj3hM/edit#heading=h.ny6kcqir2tgd'>instructions</a> here.
  <br>
  <br>
  Also as you know we are just getting started with our remote training. If you'd be comfortable sharing a quote/testimonial about your experience we'd really appreciate it! There is also an anonymous <a href = 'https://docs.google.com/forms/d/e/1FAIpQLScflsdF-0zC03Q9u2684P0cOWdvdZaRxqF03QRavoY9oij4eg/viewform'>survey</a> if you'd like to share your feedback that way.
  <br>
  <br>
  Please give me a shout if you have any questions.  Hope to see you on https://relevancy.slack.com or perhaps at another training session or conference.
  <br>
  <br>
  Stay relevant,
  <br>
  {trainers_signature}"
)

roster$body = follow_up_body # choose which one to use

#' Create Gmail to save as draft or send
#' 
#' @param roster `character` valid path to CSV
#' @param drafte `logical` Should emails be saved as a draft (TRUE) or sent
#' directly (FALSE)
make_email <- function(roster, draft = TRUE) {
  
  mime <- gm_mime() %>%
    gm_to(roster$Email) %>%
    # the account you authenticated earlier
    gm_from("nday@o19s.com") %>%
    # adjust the subject line as needed
    gm_subject("TLRE follow up") %>%
    gm_html_body(roster$body) %>% 
    # attach files as needed
    gm_attach_file(roster$cert_path) 

    if (draft) { # create a draft
      gm_create_draft(mime)
    } else { # or send direct
      gm_send_message(mime)
    }
}

sent <- roster %>% split(1:nrow(.)) %>% map(make_email, FALSE)
# sometimes this hangs, but running on a fresh restart seems to resolve
# so restart the R-session --> Re-auth --> Pray

