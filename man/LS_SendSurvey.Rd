% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Limer_Post.R
\name{LS_SendSurvey}
\alias{LS_SendSurvey}
\title{Send a Survey Template to Lime Survey}
\usage{
LS_SendSurvey(lss, name = NULL)
}
\arguments{
\item{lss}{Path to the survey template.}

\item{name}{The optional name of the survey. If not provided, the name of
the survey will be extracted from the template.}
}
\value{
Results from the API.
}
\description{
This function sends a survey template to the Lime Survey.
}
\examples{
\dontrun{
LS_SendSurvey(lss = "limesurvey_XXX.lss", name = "MySurvey")
}
}
