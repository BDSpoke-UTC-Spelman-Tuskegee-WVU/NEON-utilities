# update_table_types.R
##############################################################################################
#' @title Update table_types data frame in sysdata.rda

#' @author
#' Christine Laney \email{claney@battelleecology.org}

#' @description
#' Connect to the DPS database, pull in updated information about tables, and save locally.

#' @return A saved .rda file

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

# Changelog and author contributions / copyrights
#   Claire Lunch (2018-10-05) converted to get tables from PDR via the data service
#   Christine Laney (2017-10-19)
##############################################################################################

update_table_types <- function(){
  
  options(stringsAsFactors=F)
  
  # get publication tables from PDR
  req <- httr::GET(Sys.getenv("PUB_TABLES"))
  rawx <- XML::xmlToList(httr::content(req, as="text"))
  
  ids <- substring(unlist(lapply(rawx, '[', "dataProductId")), 15, 27)
  tables <- unlist(lapply(rawx, '[', "tableName"))
  tables <- gsub("_pub", "", tables, fixed=T)
  descs <- unlist(lapply(rawx, '[', "description"))
  typs <- unlist(lapply(rawx, '[', "tableType"))
  temp <- unlist(lapply(rawx, '[', "pubField"))
  tmi <- temp[grep("timeIndex", names(temp))]
  
  table_types <- data.frame(cbind(ids[-length(ids)], tables[-length(tables)],
                                  descs[-length(descs)], typs[-length(typs)], tmi))
  colnames(table_types) <- c("productID", "tableName", "tableDesc", 
                             "tableType", "tableTMI")
  rownames(table_types) <- 1:nrow(table_types)
  
  # term definitions for fields added by stackByTable
  added_fields <- data.frame(cbind(fieldName=c('domainID','siteID','horizontalPosition',
                                               'verticalPosition','publicationDate'),
                                   description=c('Unique identifier of the NEON domain',
                                                 'NEON site code',
                                                 'Index of horizontal location at a NEON site',
                                                 'Index of vertical location at a NEON site',
                                                 'Date of data publication on the NEON data portal'),
                                   dataType=c(rep('string',4),'dateTime'),
                                   units=rep(NA,5),
                                   downloadPkg=rep('appended by stackByTable',5)))
  
  usethis::use_data(table_types, added_fields, shared_flights, internal=TRUE, overwrite=TRUE)
  
}

update_table_types()
