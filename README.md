## Training Communications

All OSC trainings involve personalized communication, whether that's the welcome email or course certificate. This repo is a collection of R scripts to help automate some of that. It resolves around a `roster.csv` file that has names and emails of attendees.

This repo is a workflow in progress.

1. Get class roster from EventBee/G-Drive
2. Send welcome email with `emails.R`
3. Use `badgr.R` to issue certificates
4. Generate certificates with `certificates.R`
5. Send follow-up email and attach certificate with `emails.R`

### Emails

Send a personalized template ("Welcome" or "Follow-up") to all atendees. These can include personalized text and attachments. You can also create emails as drafts in your Gmail account instead, if you want to check that everything looks good before you press go/send.

Requires:

* Hand formating the email body using HTML
* Class roster with columns `email`, `first` and `book_code`(TLRE only)
* Ability to authenticate your OSC Gmail account via browser (so no remote machines)

### Badges

Use `badrgr.R` to interact with the Badgr API and generate new certificates based on the `roster`. The Badgr response includes the certifcate ID/link that is saved back into the `roster` for certificate generation.

### Certificates

Generate a batch of certificates as PDF files outputted to `certs_new/`. This personalizes a certificate `template.pptx` with the R library `officr` before calling LibreOffice's `soffice` command line tool to convert `PPTX` to `PDF`.

Requires: 

* Certificate template in PowerPoint: `template.ppt`
* Hand editting the template to show the proper class and completion date
* Manually perform a bulk upload on Badgr for certificates, then retrieve assertion urls for each learner in `roster.csv`
* Class roster with a field `full_name` (First & Last), BadgeID URL, field: croster.csv

Getting R to properly edit the PowerPoint is finicky, so change things carefully.
