library(googlesheets4)
library(officer)
library(tidyverse)

source("functions.R")
source("params.R")

# get the roster from G-Drive
gs4_auth(user)
roster <- read_sheet(sheet_url)

# maybe the roster needs `name` or some touch ups
roster <- roster %>% mutate(name = paste(first, last))

## !!!
## change date & class name in template.pptx before going further
## !!!

# Create ------------------------------------------------------------------

# clear out existing certs
dir(output_dir, full.names = T) %>% file.remove() 

roster %>% certs_from_roster(template_path, output_dir)

dir(output_dir, full.names = TRUE) %>% 
  walk(~ convert_to_pdf(., "certs_new/"))
# takes a second, should send message 'impress_pdf_Export' in Console

# remove pptx if the pdfs look gud
dir(output_dir, "pptx", full.names = TRUE) %>% file.remove()

roster$cert_path <- glue::glue("{output_dir}{gsub(' ', '_', roster$name)}.pdf")

write_sheet(roster, sheet_url, 1)

