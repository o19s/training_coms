## Certificates, Surveys and Emails oh my

All OSC trainings involve personalized communication, whether that's the welcome email or course certificate. This repo is a collection of R scripts to help automate some of that.

This repo is a work in progress.

### Emails

Handled in the `emails.R` script. 

Requires:

* Hand formating the email body using HTML (links) in the script
* Class roster with email address
* Ability to authenticate your OSC Gmail account via browser

### Certificates

Generate a batch of certificates as PDF files outputted to `certs_new/`

Requires: 

* Certificate template in PowerPoint: template.ppt
* Hand editting the template to show the proper class and completion date
* Class roster with a united Name (First & Last), BadgeID URL, field: croster.csv

Getting R to properly edit the PowerPoint is finicky, so change things carefully.

