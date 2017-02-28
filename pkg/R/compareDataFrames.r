##compareDataframes.r
##2017-20-27 dmontaner@gmail.common
## compare two tables


##' Compare two data frames
##'
##' The function compares two data.frames.
##'
##' Details...
##' 
##' @aliases dfcomp
##'
##' @param old first   data.frame to be compared.
##' @param new second data.frame to be compared.
##' @param rowKeys a character vector with the column names which identify unique rows.
##' @param sort.rows.first see details
##' @param keepRowTag see details
##' @param row.tag    see details
##' @param verbose verbose
##'
##' @return An S3 object with class "dfcomp" (data.frame comparison).
##' Basically a list with the following items (all of them data.frames):
##' "del.cols"
##' "new.cols"
##' "dif.col.class"
##' "dup.rows.old"
##' "dup.rows.new"
##' "del.rows"
##' "new.rows"
##' "dif.cells"
##'
##' @export

compareDataFrames <- function (old, new,
                               rowKeys,
                               sort.rows.first = TRUE,
                               keepRowTag = FALSE, row.tag = "my.row.tag_",
                               verbose = TRUE) { 
    
    ## #########################################################################    
    ## some CHECKS
    ## #########################################################################    
    
    ## for now just work with data.frames
    if (!is.data.frame (old)) stop ("old is not a data.frame")
    if (!is.data.frame (new)) stop ("new is not a data.frame")
    
    ## check ID columns existence
    no.old <- !rowKeys %in% colnames (old); if (any (no.old)) stop (rowKeys[no.old], " is not a valid ID column for old")
    no.new <- !rowKeys %in% colnames (new); if (any (no.new)) stop (rowKeys[no.new], " is not a valid ID column for new")
    
    ## reorder ID columns to the beginning
    old <- old[c (rowKeys, setdiff (colnames (old), rowKeys))]
    new <- new[c (rowKeys, setdiff (colnames (new), rowKeys))]
    
    ## check ID columns missing values
    if (verbose) if (any (is.na (old[rowKeys]))) cat ("NOTE: some rowKeys values in old are missing", fill = TRUE)
    if (verbose) if (any (is.na (old[rowKeys]))) cat ("NOTE: some rowKeys values in new are missing", fill = TRUE)
    
    ## duplicated rows
    if (verbose) if (any (duplicated (old))) cat ("NOTE: completely duplicated rows found in old", fill = TRUE)
    if (verbose) if (any (duplicated (new))) cat ("NOTE: completely duplicated rows found in new", fill = TRUE)
    
    
    ## #########################################################################    
    ## compare COLUMNS
    ## #########################################################################    
    
    ## old & new COLUMNS 
    colnames.old <- colnames (old)
    colnames.new <- colnames (new)
    
    del.cols <- sort (setdiff (colnames.old, colnames.new))   ## deleted columns
    new.cols <- sort (setdiff (colnames.new, colnames.old))   ## new     columns
    com.cols <- sort (intersect (colnames.old, colnames.new)) ## common  columns
    ##
    com.cols <- c (rowKeys, setdiff (com.cols, rowKeys))      ## organize rowKeys columns at the beginning
    
    ## keep just the common columns in the same order for both data.frames
    old <- old[com.cols]
    new <- new[com.cols]
    
    ## column class
    old.class <- sapply (lapply (old, class), "[", 1)
    new.class <- sapply (lapply (new, class), "[", 1)
    
    dif.col.class <- data.frame (column = com.cols, old.class, new.class, stringsAsFactors = FALSE)
    dif.col.class <- dif.col.class[dif.col.class$old.class != dif.col.class$new.class,]
    rownames (dif.col.class) <- NULL
    
    
    ## #########################################################################    
    ## compare ROWS
    ## #########################################################################    
    
    ## row tag
    old[,row.tag] <- apply (old[rowKeys], 1, paste, collapse = "__")
    new[,row.tag] <- apply (new[rowKeys], 1, paste, collapse = "__")
    
    ## report duplicated rows (in their ids)
    old.dup <- duplicated (old[,row.tag]) | duplicated (old[,row.tag], fromLast = TRUE)
    new.dup <- duplicated (new[,row.tag]) | duplicated (new[,row.tag], fromLast = TRUE)
    ##
    dup.rows.old <- old[old.dup,]
    dup.rows.new <- new[new.dup,]
    ##
    dup.rows.old <- dup.rows.old[order (dup.rows.old[,row.tag]),]
    dup.rows.new <- dup.rows.new[order (dup.rows.new[,row.tag]),]
    
    ## keep unique rows
    old <- old[!old.dup,]
    new <- new[!new.dup,]
    
    ## old and new rows
    old.id <- setdiff (old[,row.tag], new[,row.tag])
    new.id <- setdiff (new[,row.tag], old[,row.tag])
    ##
    old.r <- which (old[,row.tag] %in% old.id)
    new.r <- which (new[,row.tag] %in% new.id)
    ##
    del.rows <- old[old.r,]
    new.rows <- new[new.r,]
    ##
    del.rows <- del.rows[order (del.rows[,row.tag]),]
    new.rows <- new.rows[order (new.rows[,row.tag]),]
    
    ## keep just common rows
    if (length (old.r) > 0)  old <- old[-old.r,]
    if (length (new.r) > 0)  new <- new[-new.r,]
    
    
    ## #########################################################################    
    ## compare CELLS
    ## #########################################################################    
    
    if (nrow (old) == 0) {
        
        columnas <- matrix (c (rowKeys, "column", "old", "new"))
        dif.cells <- as.data.frame (matrix (nrow = 0, ncol = length (columnas)))
        colnames (dif.cells) <- columnas
        
    } else {
        
        ## revise column order
        if (any (colnames (old) != colnames (new))) stop ("old and new columns are not in the same order")
        
        ## arrange rows
        mt <- match (old[,row.tag], new[,row.tag]) ##; old[,row.tag] == new[mt, row.tag]
        new <- new[mt,]
        
        if (any (old[,row.tag] != new[,row.tag])) stop ("old and new rows are not in the same order")
        
        ## character version of the datasets. NA to text to asses differences
        old.t <- sapply (old, as.character)
        new.t <- sapply (new, as.character)
        ##
        old.t[is.na (old.t)] <- "NA"
        new.t[is.na (new.t)] <- "NA"
        
        dif <- old.t != new.t
        ##
        touse.row <- apply (dif, 1, any)
        touse.col <- apply (dif, 2, any)
        Nr <- sum (touse.row) ## number of columns
        Nc <- sum (touse.col) ## number of columns
        
        dif.cells <- data.frame (lapply (old[touse.row, c (rowKeys, row.tag)], rep, times = Nc), stringsAsFactors = FALSE)
        
        dif.cells[,"column"] <- rep (colnames (old)[touse.col], each = Nr)
        ##
        ##dif.cells[,"old"] <- unlist (old[touse.row, touse.col])
        ##dif.cells[,"new"] <- unlist (new[touse.row, touse.col])
        dif.cells[,"old"] <- as.vector (old.t[touse.row, touse.col])
        dif.cells[,"new"] <- as.vector (new.t[touse.row, touse.col])
        
        dif.cells <- dif.cells[as.vector (dif[touse.row, touse.col]),]
        
    
        ## #########################################################################    
        ## order and format
        ## #########################################################################    
        
        ## order
        if (sort.rows.first) {
            orden <- order (dif.cells[,row.tag], dif.cells[,"column"])
            dif.cells <- dif.cells[orden,]
        } else {
            orden <- order (dif.cells[,"column"], dif.cells[,row.tag])
            dif.cells <- dif.cells[orden,]
        }
    }
    
    
    ## set deleted and new columns as data frames
    del.cols <- data.frame (del.cols = del.cols, stringsAsFactors = FALSE)
    new.cols <- data.frame (new.cols = new.cols, stringsAsFactors = FALSE)
    
    
    ## OUTPUT    
    ret <- list (del.cols = del.cols,
                 new.cols = new.cols,
                 dif.col.class = dif.col.class,
                 ##
                 dup.rows.old = dup.rows.old, 
                 dup.rows.new = dup.rows.new,
                 ##
                 del.rows = del.rows,
                 new.rows = new.rows,
                 dif.cells = dif.cells)
    
    ## eliminate row tag column 
    if (!keepRowTag) {
        es.df <- which (sapply (ret, is.data.frame))
        for (d in es.df) {
            touse <- colnames (ret[[d]]) != row.tag
            ret[[d]] <- ret[[d]][touse]
        }
    }

    ## clear rownames of all generated data.frames
    ret <- lapply (ret, "rownames<-", NULL)
    
    ## keep rowKeys as an attribute
    attr (ret, "rowKeys") <- rowKeys
    
    ## nice names for the report and interpretation in an attribute
    attr (ret, "niceNames") <- c (    
        "del.cols"       = "Deleted Columns",
        "new.cols"       = "New Columns",
        "dif.col.class"  = "Changed Column Classes",
        "dup.rows.old"   = "Duplicated Rows Old Table",
        "dup.rows.new"   = "Duplicated Rows New Table",
        "del.rows"       = "Deleted Rows",
        "new.rows"       = "New Rows",
        "dif.cells"      = "Changed Cells")

    ## add S3 class
    class (ret) <- "dfcomp"
        
    ## return
    return (ret)
}

################################################################################

## Should these two functions be methods?

## return rowKeys from attributes
rowKeys <- function (x) {
    attr (x, "rowKeys")
}

## return niceNames from attributes
niceNames <- function (x) {
    nn <- attr (x, "niceNames")
    nn
}

## something like this is not useful without slicing
## niceNames <- function (x) {
##     nn <- attr (x, "niceNames")
##     nn[names (x)]
## }

################################################################################

##' summary method for a dfcomp list
##'
##' @param x a dfcomp element created by compareDataFrames.
##' @param verbose verbose.
##' @param report.dif.col.class if TRUE differences in the class of the columns of the data frames are reported.
##'
##' @seealso compareDataFrames
##' 
##' @export

summary.dfcomp <- function (x, verbose = TRUE, report.dif.col.class = TRUE) {
    
    ## attributes need to be extracted before slicing
    rk <- rowKeys (x)
    Nrk <- length (rk)
    nn <- niceNames (x)
    
    ## exclude dif.col.class from the report
    if (!report.dif.col.class) {
        x["dif.col.class"] <- NULL    
    }
    
    ## mat to store results
    mat <- matrix ("", nrow = 1, ncol = 2)
    
    ## rowKeys
    lin <- cbind ("Number of rowKeys used in this table:", Nrk)
    mat <- rbind (mat, lin)
    ##
    lin <- cbind ("rowKey:", rk)
    mat <- rbind (mat, lin)
    
    ## Deleted Columns
    for (na in names (x)) {
        lin <- cbind ("", "")
        mat <- rbind (mat, lin)
        ##
        lin <- cbind (paste0 ("Number of ", nn[na], ":"), nrow (x[[na]]))
        mat <- rbind (mat, lin)
    }

    ## names (not important)
    colnames (mat) <- c ("SUMMARY REPORT", " ")
    ## print report
    if (verbose) {
        ## cat ("", fill = TRUE)
        ## cat ("SUMMARY REPORT", fill = TRUE)
        ## cat ("--------------", fill = TRUE)
        
        for (i in 1:nrow (mat)) {
            cat (mat[i,], fill = TRUE)
        }
        cat ("", fill = TRUE)
    }
    
    mat <- as.data.frame (mat, stringsAsFactors = FALSE)    
    invisible (mat)
}

################################################################################

##' print method for a dfcomp list
##' 
##' @param x a "dfcomp" object created by compareDataFrames.
##' @param report.dif.col.class if TRUE differences in the class of the columns of the data frames are reported.
##'
##' @seealso compareDataFrames
##' 
##' @export

print.dfcomp <- function (x, report.dif.col.class = FALSE, niceNames = TRUE) {
    
    if (!report.dif.col.class) {
        x["dif.col.class"] <- NULL    
    }
    
    if (niceNames) {
        nn <- niceNames (x)[names (x)]
    } else {
        nn <- paste0 ("$", names (x))
        names (nn) <- names (x)
    }
    
    for (ta in names (x)) {
        cat ("", fill = TRUE)
        cat (nn[ta], fill = TRUE)
        print (x[[ta]])
    }
}

################################################################################

##' export dfcomp to an xls file
##' 
##' @param x a "dfcomp" object created by compareDataFrames.
##' @param file the name of the xls or xlsx to be written; the extension must be provided.
##' @param verbose verbose.
##' @param report.dif.col.class if TRUE differences in the class of the columns of the data frames are reported.
##' @param niceNames if TRUE nice names are used for the tabs of the xls.
##' @param colWidths as in openxlsx::write.xlsx.
##' @param ... arguments to be pasted to openxlsx::write.xlsx.
##' 
##' @seealso compareDataFrames, openxlsx::write.xlsx
##' 
##' @import openxlsx
##' @export

dfcomp2xlsx <- function (x, file, verbose = FALSE, report.dif.col.class = FALSE, niceNames = TRUE, colWidths = "auto", ...) {

    ## summary report
    s <- list (SUMMARY = summary (x, verbose = verbose, report.dif.col.class = report.dif.col.class))
    
    ## exclude dif.col.class from the report
    if (!report.dif.col.class) {
        x["dif.col.class"] <- NULL
    }
    
    ## nice names
    if (niceNames) {
        names (x) <- gsub (" ", "_", niceNames (x)[names (x)])
    }

    ## include summary
    x <- c (s, x)
    
    ## ## patch for the 0 row "POSIXct" "POSIXt" columns
    ## ## there is a bug in the write.xlsx function
    ## ## https://github.com/awalker89/openxlsx/issues/267
    ## ## not needed for openxlsx >= "4.0.9"
    ## for (ta in names (x)) {
    ##     if (nrow (x[[ta]]) == 0) {
    ##         clases <- sapply (lapply (x[[ta]], class), "[", 1)
    ##         posix <- which (clases == "POSIXct")
    ##         for (co in posix) {
    ##             ##print ("cambiando")
    ##             x[[ta]][,co] <- as.character (x[[ta]][,co])
    ##         }
    ##     }
    ## }
    
    ##write.xlsx
    write.xlsx (x, file = file, colWidths = colWidths, ...)
}

################################################################################

## ## Vignette

## ## create unique index variable
## iris0 <- iris1 <- cbind (iris, N = 1:50)

## ## add some cell differences
## iris1[4, 1] <- 80
## iris1[5, 2] <- 90
## iris1[6, 3:4] <- 100 

## ## delete some rows
## iris0 <- iris0[-(1:3),]
## iris1 <- iris1[-150]

## ## add extra columns
## iris0[,"mycol0"] <- "A"
## iris1[,c ("mycol1", "mycol2")] <- "B"

## ## add duplicated rows (duplicated ids)
## iris0 <- rbind (iris0, iris0[10,])
## iris1 <- rbind (iris1, iris1[20:21,])

## head (iris0)
## head (iris1)

## dif <- compareDataFrames (iris0, iris1, rowKeys = c ("N", "Species"))

## class (dif)
## is.list (dif)
## summary (dif)

## dfcomp2xlsx (dif, file = "dif_report.xlsx")

## ### end vignette and more tests

## s <- summary.dfcomp (dif, verbose = FALSE)

## print (dif, niceNames = FALSE)

## print (dif, TRUE)

## dfcomp2xlsx (dif, file = "salida.xls")
## dfcomp2xlsx (dif, file = "salida.xlsx")

## dfcomp2xlsx (dif, file = "salida.xlsx", asTable = TRUE)

## dfcomp2xlsx (dif, file = "salida")

## names (dif)

## rowKeys (dif)

## head (iris0)
