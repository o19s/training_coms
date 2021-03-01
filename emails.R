library(gmailr)
library(googlesheets4)
library(tidyverse)

source("params.R")

gm_auth_configure()
gm_auth(user) # require console interaction

gs4_auth(user)
roster <- read_sheet(sheet_url)
# ^^^^ Run interactive for auth porpoises ^^^^ -----------------------------------------------


# Body templates ----------------------------------------------------------
# this allows customization based on the other column values in roster.csv
welcome_ltr <- glue::glue(
  "Hi {roster$first},
  <br><br>
  Max and I are looking forward to learning about Learning to Rank with you on Tuesday.
  <br><br>
  To make the class interactive, we've built a repo with lab exercises as Jupyter notebooks <a href='https://github.com/o19s/hello-ltr'>here.</a>
  Please try to set up the lab environment before coming to class. I highly recommend using the Docker option if available. Reach out via email if you hit any snags.
  <br><br>
  You will have recieved G-Cal (with Zoom details) and Slack (for in-class chat) invites shortly. 
  <br><br>
  See you soon,
  <br>
  {email_signature}
  "
)

welcome_tlre <- glue::glue(
  "Hi {roster$first},
  <br><br>
  We are excited to have you join us for Think Like A Relevance Engineer (Elasticsearch) next week.
  <br><br>
  Because this class is tightly coupled to the book <a href='https://www.manning.com/books/relevant-search'>Relevant Search</a> we've worked with Manning to create promo codes, that include a free personal copy and shipping.
  <br><br>
  Your book code is : {roster$book_code}
  <br><br>
  In the past we've had issues where the checkout will attempt to charge shipping, please reach out to us if that happens, it's a bug.
  <br><br>
  To make the class interactive, we have a sandbox setup <a href='https://github.com/o19s/es-tmdb'>here</a>.
  Please follow the instructions in that repo to get set-up before we start class on the third day (Thursday).
  <br><br>
  If you have any questions we will have office half-hours after each day.
  <br><br>
  We will use Zoom for video conferencing.
  <br><br>
  Meeting ID: 872 8959 6306
  <br>
  Passcode: 810540
  <br><br>
  There will also be a private Slack channel for coms during class. G-Cal (with Zoom details) and Slack invites will follow shortly.
  <br><br>
  Reach out with any questions,
  <br>
  {email_signature}
  "
)

follow_tlre <- glue::glue(
  "Hi {roster$first},
  <br>
  <br>
  Thanks so much for coming to TLRE training last month. Sorry it's taken me a while to send this, I hope you've already gotten your 'Relevant Search' book in the post.
  <br>
  <br>
  Attached is your certificate for completing the class! We use badgr.io to manage these, there is a link to the digital award on the certificate.  If you'd like to share it on LinkedIn, see the <a href='https://docs.google.com/document/d/1edUjY0kmVpD2J6cDYQIYPXBnwK-pnQ2I0Rb0chqj3hM/edit#heading=h.ny6kcqir2tgd'>instructions</a> here.
  <br>
  <br>
  If you can share a positive quote/testimonial about your training experience, I'll send you some socks and stickers as a bribe! There is also an anonymous <a href = 'https://docs.google.com/forms/d/e/1FAIpQLScflsdF-0zC03Q9u2684P0cOWdvdZaRxqF03QRavoY9oij4eg/viewform'>survey</a> if you'd like to share any feedback that way.
  <br>
  <br>
  Please give us a shout if you have any questions.  Hope to see you on <a href='https://relevancy.slack.com'>Relevancy Slack</a> and at an in-person search conference soon.
  <br>
  <br>
  Stay relevant,
  <br>
  {email_signature}
  "
)

follow_ltr <- glue::glue(
  "Hi {roster$first},
  <br>
  <br>
  Thanks so much for coming to LTR training last week, it was great learning with you.
  <br>
  <br>
  Attached is your certificate for completing the class. We use badgr.io to manage these, there is a link to the digital award on the certificate.  If you'd like to share it on LinkedIn, see the <a href='https://docs.google.com/document/d/1edUjY0kmVpD2J6cDYQIYPXBnwK-pnQ2I0Rb0chqj3hM/edit#heading=h.ny6kcqir2tgd'>instructions</a> here.
  <br>
  <br>
  If you can share a positive quote/testimonial about your training experience, I'll send you socks and stickers as a bribe.
  <br>
  <br>
  Please give us a shout if you have any questions.  Hope to see you on <a href='https://relevancy.slack.com'>Relevancy Slack</a> or at a search conference soon.
  <br>
  <br>
  Stay relevant,
  <br>
  {email_signature}
  "
)

# Set up ------------------------------------------------------------

# choose which one to use; has to be here b/c glue (or I could get tidy-eval-fancy)
roster$body <- follow_tlre

#' Create Gmail to save as draft or send
#' 
#' @param roster `character` valid path to CSV
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
  map(~ make_email(., T, T))
# sometimes this hangs, but running on a fresh restart seems to resolve
# so restart the R-session --> Re-auth --> Pray

