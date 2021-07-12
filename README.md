## Training Communications

All OSC trainings involve personalized communication, whether that's the welcome email or course certificate. This repo is a collection of R scripts to help automate some of that. It resolves around a `roster` file that has names and emails of attendees.

The general flow is:

1. Get class roster from EventBee/G-Drive
2. Send welcome email with `emails.R`
3. Use `badgr.R` to issue certificates
4. Generate certificates with `certificates.R`
5. Send follow-up email and attach certificate with `emails.R`

### roster

This is essentially the export report from Eventbee, but stored on G-Drive. It must include the columns `first`, `last` and `email` and will be updated by the scripts in this repo.

### params.R

Special R script that houses any configurable variables that will be used across scripts. Things like ClassName, Email Signature and the URL for the roster file on G-Drive are set here. 

### emails.R

Send a personalized template ("Welcome" or "Follow-up") to all attendees at once from your Gmail account. These can include personalized text and/or attachments. You can also create emails as drafts in your Gmail account instead, if you want to check that everything looks good before you press go/send.

Requires:

* Hand formatting the email body using HTML
* Class roster with columns `email`, `first` and `book_code`(TLRE only)
* Ability to authenticate your OSC G-Mail account via browser (so no remote machines)

### badgr.R

Use `badrgr.R` to interact with the Badgr API and generate new certificates based on the `roster`. The Badgr response includes the certificate ID/link that is saved back into the `roster` for certificate generation.

### certificates.R

Generate a batch of certificates as PDF files outputted to `certs_new/`. This personalizes a certificate `template.pptx` with the R library `officr` before calling LibreOffice's `soffice` command line tool to convert `PPTX` to `PDF`. Relies on the stable version of [LibreOffice](https://www.libreoffice.org/download/download/) being installed on your MacOS as an Application.

Requires: 

* `badgr.R` being run to update `roster` with certificate URLs.
* Certificate template in PowerPoint: `template.ppt`
* Hand editing the template to show the proper class and completion date

Getting R to properly edit the PowerPoint is finicky, so change things carefully and with great trepidation.

### Limitations

This is designed to work on MacOS, and the adaptions to port to Windows are likely large.
