library(htmltools)
library(xml2)
library(officer)

template_path <- "certs/template.pptx"
output_dir <- "certs/certs_new/"
roster <- read.csv("certs/roster.csv",
                   stringsAsFactors = FALSE) %>% 
  mutate(BadgeId = gsub("\\?.*", "", BadgeId))

ppt <- read_pptx(template_path)

layout_properties(ppt)

ph_with2 <- function (x, value, location, ...) {
  slide <- x$slide$get_slide(x$cursor)
  location <- fortify_location2(location, doc = x)
  new_ph <- officer:::gen_ph_str(left = location$left, top = location$top,
                       width = location$width, height = location$height, label = location$ph_label,
                       ph = location$ph, rot = location$rotation, bg = location$bg)
  pars <- paste0("<a:p><a:r><a:rPr/><a:t>", htmlEscape(value),
                 "</a:t></a:r></a:p>", collapse = "")
  xml_elt <- paste0(officer:::pml_with_ns("p:sp"), new_ph, "<p:txBody><a:bodyPr/><a:lstStyle/>",
                    pars, "</p:txBody></p:sp>")
  node <- as_xml_document(xml_elt)
  xml_add_child(xml_find_first(slide$get(), "//p:spTree"),
                node)
  slide$fortify_id()
  x
}

# ppt2 <- ph_with2(ppt, "Nate", 14)

for(i in seq_along(roster$Name)) {
  rn = roster$Name[i]
  re = roster$BadgeId[i]
  x <- read_pptx(template_path)
  out <- ph_with2(x, rn, 14)
  out <- ph_with2(x, re, 17)
  print(out, glue::glue("{output_dir}{gsub(' ', '_', rn)}.pptx"))
}

office_shot <- function(file, out_dir){
  cmd_ <- glue::glue(
    "/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf --outdir {out_dir} {file}",
    )
  system(cmd_)
}

dir("certs/certs_new/", full.names = TRUE) %>% 
  walk(~ office_shot(., "certs/certs_new/"))

roster$cert_path <- glue::glue("{output_dir}{gsub(' ', '_', roster$Name)}.pdf")
write_csv(roster, "certs/roster.csv")
