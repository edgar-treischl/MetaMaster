% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DB_fun.R
\name{DB_Table}
\alias{DB_Table}
\title{Get a Table from the Database}
\usage{
DB_Table(table = NULL)
}
\arguments{
\item{table}{The name of the table.}
}
\value{
A data frame with the table data or a list of available tables.

A data frame with the table data or a list of available tables
}
\description{
This function fetches a table from the database and returns it as a data frame.
 If no table is specified, it returns a list of all available tables.
}
\examples{
\dontrun{
DB_Table()
}
}
