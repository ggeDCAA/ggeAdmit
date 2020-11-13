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
  appProfs = applicantsDF %>%
    select(c("Faculty.Member.1","Faculty.Member.2","Faculty.Member.3",
             "Faculty.Member.4","Faculty.Member.5","Faculty.Member.6")) %>%
    pull()
  revProfs = reviewersDF %>%
    select("Name") %>%
    pull()
  presenceAbsence = appProfs %in% revProfs
  absentProfs = appProfs[!presenceAbsence]
  missingProfessors = absentProfs[!is.na(absentProfs)]
  if(length(missingProfessors) == 0){
    message("All faculty of interest are present in list of reviewers")
    return(NULL)
  }else{
    message("Some faculty of interest are not present in reviewers dataset")
    return(missingProfessors)
  }
}
