library(officer)
library(tidyverse)

roster_path <- "roster.csv"
template_path <- "template.pptx"
output_dir <- "certs_new/"

roster <- read_csv(roster_path) %>% 
  mutate(BadgeId = gsub("\\?.*", "", BadgeId))

ppt <- read_pptx(template_path)

# layout_properties(ppt)

# Tweaks to officr functions ---------------------------------------------
ph_with2 <- function (x, value, location, ...) {
  slide <- x$slide$get_slide(x$cursor)
  location <- fortify_location2(location, doc = x)
  new_ph <- officer:::sh_props_pml(left = location$left, top = location$top,
                       width = location$width, height = location$height, label = location$ph_label,
                       ph = location$ph, rot = location$rotation, bg = location$bg)
  pars <- paste0("<a:p><a:r><a:rPr/><a:t>", htmltools::htmlEscape(value),
                 "</a:t></a:r></a:p>", collapse = "")
  xml_elt <- paste0(officer:::psp_ns_yes, new_ph,
                    "<p:txBody><a:bodyPr/><a:lstStyle/>",
                    pars, "</p:txBody></p:sp>")
  node <- xml2::as_xml_document(xml_elt)
  xml2::xml_add_child(xml2::xml_find_first(slide$get(), "//p:spTree"),
                node)
  slide$fortify_id()
  x
}

fortify_location2 <- function(id, doc, ...) {
  
  slide <- doc$slide$get_slide(doc$cursor)
  xfrm <- slide$get_xfrm()
  
  layout <- unique(xfrm$name)
  master <- unique(xfrm$master_name)
  
  props <- layout_properties( doc, layout = layout, master = master )
  # props <- props[props$ph_label %in% x, , drop = FALSE]
  props <- props[props$id == id, , drop = FALSE]
  
  
  if( nrow(props) < 1) {
    stop("no selected row")
  }
  
  if( nrow(props) > 1) {
    warning("more than a row have been selected")
  }
  
  props <- props[, c("offx", "offy", "cx", "cy", "ph_label", "ph", "type")]
  names(props) <- c("left", "top", "width", "height", "ph_label", "ph", "type")
  row.names(props) <- NULL
  out <- officer:::as_ph_location(props)
  out
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

convert_to_pdf <- function(file, out_dir){
  glue::glue(
    "/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf --outdir {out_dir} {file}",
  ) %>% 
  system()
}

dir("certs_new/", full.names = TRUE) %>% 
  walk(~ convert_to_pdf(., "certs_new/"))
# takes a second, should send message 'impress_pdf_Export' in Console

roster$cert_path <- glue::glue("{output_dir}{gsub(' ', '_', roster$Name)}.pdf")
write_csv(roster, "roster.csv") # for use in emails.R

