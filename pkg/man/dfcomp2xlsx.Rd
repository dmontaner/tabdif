% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compareDataFrames.r
\name{dfcomp2xlsx}
\alias{dfcomp2xlsx}
\title{export dfcomp to an xls file}
\usage{
dfcomp2xlsx(x, file, verbose = FALSE, report.dif.col.class = FALSE,
  niceNames = TRUE, colWidths = "auto", ...)
}
\arguments{
\item{x}{a "dfcomp" object created by compareDataFrames.}

\item{file}{the name of the xls or xlsx to be written; the extension must be provided.}

\item{verbose}{verbose.}

\item{report.dif.col.class}{if TRUE differences in the class of the columns of the data frames are reported.}

\item{niceNames}{if TRUE nice names are used for the tabs of the xls.}

\item{colWidths}{as in openxlsx::write.xlsx.}

\item{...}{arguments to be pasted to openxlsx::write.xlsx.}
}
\description{
export dfcomp to an xls file
}
\seealso{
compareDataFrames, openxlsx::write.xlsx
}
