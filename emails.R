library(gmailr)
library(tidyverse)

gm_auth_configure()
gm_auth()

roster <- read_csv("certs/roster.csv") %>% 
  mutate(First = gsub(" .*", "", Name),
         BadgeId = gsub("\\?.*", "", BadgeId))

after_body <- glue::glue(
  "Hi {roster$First},
  <br>
  <br>
  Thanks so much for coming to the training last week.  It was great learning with you.
  <br>
  <br>
  Attached is your certificate!  You should have received a separate email from badgr.io that has a digital award you can use and share on LinkedIn.  See <a href='https://docs.google.com/document/d/1edUjY0kmVpD2J6cDYQIYPXBnwK-pnQ2I0Rb0chqj3hM'>instructions</a> here.
  <br>
  <br>
  Also as you know we are just getting started with our remote training. If you'd be comfortable sharing a quote/testimonial about your experience we'd really appreciate it! There is also an annonymous <a href = 'https://docs.google.com/forms/d/e/1FAIpQLScflsdF-0zC03Q9u2684P0cOWdvdZaRxqF03QRavoY9oij4eg/viewform'>suvery</a> if you'd like to share your feedback that way.
  <br>
  <br>
  Please give me a shout if you have any questions.  Hope to see you on https://relevancy.slack.com or perhaps at another training session or conference.
  <br>
  <br>
  Stay relevant, <br>
  Dan, Max and Nate"
)

roster$body = after_body

make_email <- function(roster, draft = TRUE) {
  
  print(roster)
  
  mime <- gm_mime() %>%
    gm_to(roster$Email) %>%
    gm_from("nday@o19s.com") %>%
    gm_subject("TLRE follow up") %>%
    gm_html_body(roster$body) %>% 
    gm_attach_file(roster$cert_path)
  
    if (draft) {
      gm_create_draft(mime)
    } else {
      gm_send_message(mime)
    }
}

sent <- roster %>% split(1:nrow(.)) %>% map(make_email, FALSE)
# sometimes this hangs, so restart the R-session --> Re-auth --> Pray

