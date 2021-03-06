% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/findConflicts.R
\name{findConflicts}
\alias{findConflicts}
\title{An intermediate function for conflicts of interest identification}
\usage{
findConflicts(conflictsDF, assignmentsDF)
}
\arguments{
\item{conflictsDF}{A data.frame() containing conflicts of interest with columns for applicant's "Name" (format "Lastname, Firstname") and "Faculty.Member.1" through "Faculty.Member.6"}

\item{assignmentsDF}{The complete reviewer assignments dataset (as generated by combineOutputs)}
}
\value{
A matrix with boolean values indicating where assigned reviewer/applicant pairs constitute a conflict of interest (TRUE = a conflict of interest was detected).
}
\description{
An intermediate function for conflicts of interest identification
}
\examples{
\dontrun{
complete.design = combineOutputs(reviewers = reviewers,
assignments1 = s.des.names,
assignments2 = f.des.names)
}
}
