library(gmailr)
library(googlesheets4)
library(tidyverse)

gm_auth_configure()
gm_auth() # require console interaction

# roster <- read_csv("roster.csv")
roster <- read_sheet("https://docs.google.com/spreadsheets/d/1-JVYjjSVnQsJ4C_LfEH1wx6tWvxlai-84WQMGvxFm48/edit#gid=0")

trainers_signature <- "Max and Nate"

# Body templates ----------------------------------------------------------
# this allows customization based on the other column values in roster.csv
welcome_body <- glue::glue(
  "Hi {roster$first},
  <br><br>
  Doug and I are looking forward to learning about Learning to Rank with you next week as part of Tech Fredrick's training.
  <br><br>
  To make the class interactive, we've built out a repo with lab exercises as Jupyter notebooks <a href='https://github.com/o19s/hello-ltr'>here.</a>
  Please follow the instructions there to get set-up before class starts on Monday. If you hit any snags or just want to say hello, please come to office hours on Friday (10th) or Monday (13th) 1-2p EDT, ZoomID: 85208661829.
  We will also set up a private Slack channel for coms during class.
  <br><br>
  You should recieve G-Cal and Slack invites shortly, reach out if you don't.
  <br><br>
  See you very soon,
  <br>
  {trainers_signature}
  "
)

welcome_book_body <- glue::glue(
  "Hi {roster$first}
  <br><br>
  We are looking forward to having your join us for Think Like A Relevance Engineer (Elasticsearch) next week.
  <br><br>
  Because this class is tightly coupled to the book <a href='https://www.manning.com/books/relevant-search'>Relevant Search</a> we've worked with Manning to create promo codes, that include a free personal copy and shipping.
  <br><br>
  Your book code is : {roster$book_code}
  <br><br>
  In the past we've had issues where the checkout will attempt to charge shipping, please reach out to us if that happens, it's a bug.
  <br><br>
  To make the class interactive, we have an sandbox setup <a href='https://github.com/o19s/es-tmdb'>here.</a>
  Please follow the instructions in that repo to get set-up before class starts on Tuesday.
  <br><br>
  If you hit any snags or just want to say hello, join us in office hours on Friday (10th) or Monday (13th) 1-2p EDT.
  <br>
  ZoomID: 85208661829
  <br><br>
  We will also bet setting up a private Slack channel for coms during class. G-Cal and Slack invites will follow shortly.
  <br><br>
  Reach out with any questions,
  <br>
  {trainers_signature}
  "
)


follow_up_body <- glue::glue(
  "Hi {roster$First},
  <br>
  <br>
  Thanks so much for coming to the training last week.  It was great learning with you.
  <br>
  <br>
  Attached is your certificate!  We use badgr.io to manage these, there is a link to the digital award on the certificante.  If you'd like to share it on LinkedIn, see the <a href='https://docs.google.com/document/d/1edUjY0kmVpD2J6cDYQIYPXBnwK-pnQ2I0Rb0chqj3hM/edit#heading=h.ny6kcqir2tgd'>instructions</a> here.
  <br>
  <br>
  Also as you know we are just getting started with our remote training. If you'd be comfortable sharing a quote/testimonial about your experience we'd appreciate it! There is also an anonymous <a href = 'https://docs.google.com/forms/d/e/1FAIpQLScflsdF-0zC03Q9u2684P0cOWdvdZaRxqF03QRavoY9oij4eg/viewform'>survey</a> if you'd like to share your feedback that way.
  <br>
  <br>
  Please give me a shout if you have any questions.  Hope to see you on https://relevancy.slack.com or perhaps at another training session or conference.
  <br>
  <br>
  Stay relevant,
  <br>
  {trainers_signature}"
)

roster$body = welcome_book_body # choose which one to use

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
    gm_from("nday@o19s.com") %>%
    # adjust the subject line as needed
    gm_subject("TLRE (Elasticsearch) training next week") %>%
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

sent <- roster %>%
  split(1:nrow(.)) %>%
  map(~ make_email(., FALSE))
# sometimes this hangs, but running on a fresh restart seems to resolve
# so restart the R-session --> Re-auth --> Pray

