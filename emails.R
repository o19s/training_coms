library(gmailr)
library(tidyverse)

gm_auth_configure()
gm_auth() # require console interaction

roster <- read_csv("roster.csv")

trainers_signature <- "Doug and Nate"

# Body templates ----------------------------------------------------------
# this allows customization based on the other column values in roster.csv
welcome_body <- glue::glue(
  "Hi {roster$first},
  <br><br>
  Doug and I are looking forward to learning about Learning to Rank with you next week as part of Tech Fredrick's training.
  <br><br>
  To make the class interactive, we've built out a repo with lab exercises as Jupyter notebooks <a href='https://github.com/o19s/hello-ltr'>here.</a>
  Please follow the instructions there to get set-up before class starts on Monday. If you hit any snags or just want to say hello, please come to office hours on Friday 1-2p EDT, ZoomID: 82467195696.
  We will also set up a private Slack channel for coms during class.
  <br><br>
  I'll also send out the G-Cal and Slack invites shortly.
  <br><br>
  Reach out with any questions,
  <br>
  Nate
  "
)

welcome_book_body <- glue::glue(
  "Hi {roster$First}
  <br><br>
  Doug and I are looking forward to learning about Learning to Rank with you next week as part of Tech Fredrick's training.
  <br><br>
  To make the class interactive, we've built out a repo with lab exercises as Jupyter notebooks <a href='https://github.com/o19s/hello-ltr'>here.</a>
  Please follow the instructions there to get set-up before class starts on Monday. If you hit any snags or just want to say hello, please come to office hours on Friday 1-2p EDT, ZoomID: 82467195696.
  We will also bet setting up a private Slack channel for coms during class.
  <br><br>
  I'll also send out the G-Cal and Slack invites shortly.
  <br><br>
  Reach out with any questions,
  Nate
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

roster$body = welcome_body # choose which one to use

#' Create Gmail to save as draft or send
#' 
#' @param roster `character` valid path to CSV
#' @param draft `logical` Should emails be saved as a draft (TRUE) or sent
#' @param cert `logical` Should a certificate be attached
#' directly (FALSE)
make_email <- function(roster, draft = TRUE, cert = FALSE) {
  
  mime <- gm_mime() %>%
    gm_to(roster$Email) %>%
    # the account you authenticated earlier
    gm_from("nday@o19s.com") %>%
    # adjust the subject line as needed
    gm_subject("Hello LTR training next week") %>%
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

sent <- roster %>% split(1:nrow(.)) %>% map(~ make_email(., FALSE))
# sometimes this hangs, but running on a fresh restart seems to resolve
# so restart the R-session --> Re-auth --> Pray

