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

welcome_tlre_no_book <- glue::glue(
  "Hi {roster$first},
  <br><br>
  We are excited to have you join us for Think Like A Relevance Engineer next week. Class will run 9a-1p EST with office half-hour following. All sessions will be recorded, to make it easy to catch up if you have to step out for life or your day job.
  <br><br>
  We will use Zoom for video conferencing and a private Slack channel for coms during class. G-Cal event (with Zoom details) and Slack channel invites will follow shortly.
  <br><br>
  To make the class interactive, we will have a sandbox environment. If you have Docker on your personal computer, you are good to go. If you don't ping me, and I will set up a remote machine for you to use during class. Docker on your local is better because you can keep playing in the sandbox after class, relevance recess never ends.
  <br><br>
  Reach out with any questions (email or slack),
  <br>
  {email_signature}
  "
)

follow_tlre <- glue::glue(
  "Hi {roster$first},
  <br>
  <br>
  Thanks for coming to TLRE last week and learning with me and Max. Attached is your certificate for completing the class. We use badgr.io to manage these, there is a link to the digital award on the certificate.  If you'd like to share it on LinkedIn, see these <a href='https://docs.google.com/document/d/1edUjY0kmVpD2J6cDYQIYPXBnwK-pnQ2I0Rb0chqj3hM/edit#heading=h.ny6kcqir2tgd'>instructions</a> here.
  <br>
  <br>
  There is an anonymous <a href = 'https://docs.google.com/forms/d/e/1FAIpQLScflsdF-0zC03Q9u2684P0cOWdvdZaRxqF03QRavoY9oij4eg/viewform'>survey</a> for any feedback you have about the class. Hope to see you on <a href='https://relevancy.slack.com'>Relevancy Slack</a> and at an in-person search conference soon.
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
  Thanks for coming to LTR training this Spring, it was great learning with you.
  <br>
  <br>
  Attached is your certificate for completing the class. We use badgr.io to manage these, there is a link to the digital award on the certificate.  If you'd like to share it on LinkedIn, see the <a href='https://docs.google.com/document/d/1edUjY0kmVpD2J6cDYQIYPXBnwK-pnQ2I0Rb0chqj3hM/edit#heading=h.ny6kcqir2tgd'>instructions</a> here.
  <br>
  <br>
  There is an anonymous <a href = 'https://docs.google.com/forms/d/e/1FAIpQLScflsdF-0zC03Q9u2684P0cOWdvdZaRxqF03QRavoY9oij4eg/viewform'>survey</a> for any feedback you have about the class. Hope to see you on <a href='https://relevancy.slack.com'>Relevancy Slack</a> and at an in-person search conference soon.
  <br>
  <br>
  Stay relevant,
  <br>
  {email_signature}
  "
)
