#' Identifying missing persons
#'
#' @param reviewersDF A data.frame() containing reviewers
#' @param applicantsDF A data.frame() containing applicants' faculty of interest, in columns "Faculty.Member.1" through "Faculty.Member.6"
#' @return If all faculty reviewer names match applicants' listed faculty of interest, returns a message indicating that the names match and returns `NULL`. Otherwise, prints a message indicating that some names are not present in the reviewer dataset and a vector of faculty names from the `applicantsDF` that are not present in `reviewersDF`.
#' @examples
#' \dontrun{
#' missingFaculty = checkPI(reviewersDF = reviewers, applicantsDF = applicants)
#' }
#' @import dplyr
#' @export
# 

# A function to identify cases where a professor was listed by an applicant
# but is not present in the reviewer dataset
checkPI = function(reviewersDF,
                   applicantsDF){
  # Generate list of applicants' faculty of interest names
  applicantsDF %>%
    select(Faculty.Member.1)
  appProfs = applicantsDF[,c("Faculty.Member.1", "Faculty.Member.2", "Faculty.Member.3", 
                             "Faculty.Member.4", "Faculty.Member.5", "Faculty.Member.6")]
  FOI = unlist(appProfs)
  names(FOI) <- NULL
  
  # Generate list of faculty names
  RevNames = reviewersDF$Name[reviewersDF$type == "Faculty"]
  RevNames = unlist(RevNames)
  
  revPresence = RevNames %in% FOI # Faculty reviewer has been listed as Faculty of Interest
  appPresence = FOI %in% RevNames # Faculty of interest is present in reviewer list
  
  # Figure out who is *not* present
  absentRev = RevNames[!revPresence]
  absentFOI = FOI[!appPresence]
  absentFOI = absentFOI[!is.na(absentFOI)]
  
  if (length(absentFOI) == 0) {
    message("All faculty of interest are present in list of reviewers")
    return(NULL)
  }
  else {
    message("Some faculty of interest are not present in reviewers dataset")
    return(absentFOI)
  }
}
