# All helper functions live here in a happy outline

# badgr.R ---------------------------------------------------------------

#' Authenticate yourself to the Badgr API
#' 
#' @param user Email address of associated account
#' @param password Password for associate account
#' @value `response` library(httr)'s response object
badgr_auth <- function(user, password) {
  httr::POST(
    "https://api.badgr.io/o/token",
    body = list("username" = user,
                "password" = password),
    encode = "form"
  )
}

#' Return a named list of entityIds to be used in other API calls
#' 
#' @value `character` URL for proof of certificate
available_classes <- function() {
  GET(
    'https://api.badgr.io/v2/badgeclasses',
    add_headers(Authorization = paste("Bearer", token))
  ) %>% 
    content() %>% 
    .[["result"]] %>% 
    map(function(x) x$entityId %>% set_names(x$name)) %>%
    unlist()
}

#' Award an individual badge based on email address
#' 
#' @param email `character` email address used by awardee
#' @param class `character` entityID representing the course, from `available_classes()`
#' @value `character` URL for proof of certificate
award_badge <- function(email, class) {
  
  # construct body
  body_li <- list("recipient" =
                    list("identity" = email,
                         "type" = "email")) %>% 
    jsonlite::toJSON(auto_unbox = TRUE) # prevents making everything an array, which would cause API error
  
  POST(
    glue::glue('https://api.badgr.io/v2/badgeclasses/{class}/assertions'),
    body = body_li,
    content_type_json(),
    add_headers(Authorization = paste("Bearer", token))
  ) %>% 
    content() %>% 
    .[["result"]] %>%
    unlist() %>%
    .['openBadgeId']
}

# certificates.R ----------------------------------------------------------
# These a small derivatives from respectice library(officr) functions

# ppt <- read_pptx(template_path)
# layout_properties(ppt)

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

#' Generate multiple .pptx certificates from a class roster
#' 
#' @param roster column `name` must be present with participants full name
#' @param template_path path to .pptx template, set in `params.R`
#' @param output_dir path to output directory, set in `params.R`
#' @value Output directory with a .pptx certificate for each participant.
certs_from_roster <- function(roster, template_path, output_dir) {
  for(i in seq_along(roster$name)) {
    rn = roster$name[i]
    re = roster$badger_id[i]
    
    x <- read_pptx(template_path)
    
    out <- ph_with2(x, rn, 14)
    out <- ph_with2(out, re, 17)
    
    print(out, glue::glue("{output_dir}{gsub(' ', '_', rn)}.pptx")) # return for officer 
  }
}

#' Convert .pptx files into .pdf ones
convert_to_pdf <- function(file, out_dir) {
  # works with LibreOffice v6.3.6
  # https://www.libreoffice.org/download/download/
  glue::glue(
    "/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf --outdir {out_dir} {file}",
  ) %>% 
    system()
}


# emails.R -----------------------------------------------------------------

#' Create Gmail to save as draft or send. Also can attach certificates.
#' 
#' @param roster `data.frame` with class roster
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
