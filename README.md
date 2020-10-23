# ggeAdmit

## Streamlining the holistic review process

This package contains scripts for administering the holistic review process in graduate admissions. Holistic review entails evaluating the "total applicant" - that is, the experiences, abilities, and contributions of the person applying, rather than a test score or two. Ultimately this package will include functions for reviewer assignments and applicant ranking. 

Two populations underlie any admissions scenario: *Reviewers* are the people who read through application materials and score each application. *Applicants* comprise the full body of students who applied to join the program in a particular calendar year. In the Graduate Group in Ecology at UC Davis (GGE), faculty and current graduate students can be reviewers. 

`ggeAdmit` is the product of years of work by the Admissions and Awards subcommittee of the GGE's Diversity Committee. The current version of the workflow would not have been possible without the help of generations of both students and faculty in numerous departments affiliated with the GGE.

## Installation

To install, use the `devtools` package and clone from github. This may be possible using devtools:

```
devtools::install_github("ggeDCAA/ggeAdmit")
```

If that fails, installation can also be done using a command line approach:

```
$ git clone https://github.com/ggeDCAA/ggeAdmit
$ R CMD Build ggeAdmit
$ R CMD INSTALL ggeAdmit_0.0.1.9000.tar.gz
```

If properly installed, the package can then be imported in R using:

```
library(ggeAdmit)
```

## Reviewer assignment

Reviewers assignment uses an incomplete block design to statistically "spread" reviewers across applicants. Because the GGE allows both faculty and current graduate students to serve as reviewers, we suggest performing two reviewer assignment steps: one series of matching faculty reviewers with applicants, and one series matching graduate student reviewers with applicants. This spreads the influence of faculty vs student reviews approximately evenly across the applicant population.

Reviewer assignment can follow a relatively straightforward workflow. First, import a reviewers and applicants dataset. The reviewers dataset should columns with Name ("Lastname, Firstname"), Email, and type (type indicates "Student" or "Faculty"). The applicants dataset should contain columns `Name` ("Lastname, Firstname"), `Email`, and then 6 columns for Faculty Members with whom applicants are interested in working (each called `Faculty.Member.i` where i takes a value from 1 to 6). Note: The names for `Faculty.Member.i` should be in the format "Lastname, Firstname" and those names MUST match the names in the reviewers dataset. For example, a link between Reviewer Charles Darwin and Applicant's Faculty.Member.1 interest "Darwin, Charlie" cannot be inferred by ggeAdmit.

```
reviewersFP = system.file("extdata", 
  "sampleReviewers.csv", 
  package = "ggeAdmit")
applicantsFP = system.file("extdata", 
  "sampleApplicants.csv", 
  package = "ggeAdmit")

reviewers = read.csv(reviewersFP, stringsAsFactors = FALSE)
applicants = read.csv(applicantsFP, stringsAsFactors = FALSE)
```

A demographic summary is required to inform the alorithmic incomplete block design. Specifically, we need to know how many reviewers in each type there are, and how many applicants comprise the applicant pool. Every application is reviewed!

```
## Demographic summary - necessary for incomplete block design
# How many reviewers are there?
n.sr <- sum(reviewers$type == "Student")
n.fr <- sum(reviewers$type == "Faculty")
# How many applicants are there?
n.applics <- length(unique(applicants$Name)) # Total number of applications
```

Use `assignReviewers()` to pair reviewers with applicants. Recall that we suggest doing this separately for Student reviewers and Faculty reviewers. For GGE reviewer assignments, it is likely that `assignReviewers()` will return a warning message: 

>"In assignReviewers(number.alternatives = n.applics, number.blocks = n.sr,  :It is recommended that number.blocks >= 3 * number.alternatives / alternatives.per.block"

Because of how many people need to be reviewed, and how many people typically sign up to review, and how many times applicants will be reviewed, and how many applications we can reasonably expect a reviewer to review, it's impossible to achieve this recommendation. Optimal designs can be found more quickly when that condition is satisfied, but we have to get by with the resources that are available to us. 

The incomplete block design takes a *long* time to complete! For an actual admissions scenario we recommend at least 200-300 replicates based on an analysis of assignment optimality across different replicate sizes. The default value for `nReps` is 300. However, to simplify and expedite the example code, we set `nReps = 10` here.

```
## Run the incomplete block design for grad student reviewers
student.design <- assignReviewers(number.alternatives = n.applics, 
                                  number.blocks = n.sr,
                                  nReps = 10)
## Run the incomplete block design for faculty reviewers
faculty.design <- assignReviewers(number.alternatives = n.applics, 
                                  number.blocks = n.fr,
                                  nReps = 10)
```

`assignReviewers()` returns a list of 6 elements. For the simple purpose of assigning reviewers to applicants, the element `$design` is of the most immediate importance. Use the function `getAssignments()` to extract identities of applicants ("Alternatives") and reviewers ("Blocks") from the incomplete block design.

```
s.des.names = getAssignments(x = student.design,
                             appNames = applicantNames)
f.des.names = getAssignments(x = faculty.design,
                             appNames = applicantNames)
```

Compile the reviewer assignments to a single cohesive datset.

```
complete.design = combineOutputs(reviewers = reviewers,
                                 assignments1 = s.des.names,
                                 assignments2 = f.des.names)
```

Checking for conflicts of interest is post-hoc and can be useful for identifying cases where manual shifting of reviewer assignments may be required. To check for conflicts of interest:

```
## Compile all conflicts of interest
conflictsOfInterest = applicants %>% select(Name, 
  `Faculty.Member.1`, `Faculty.Member.2`, 
  `Faculty.Member.3`, `Faculty.Member.4`, 
  `Faculty.Member.5`, `Faculty.Member.6`)

## Identify cases where COI pairs were assigned by the incomplete block design
conflictsSummary = summarizeConflicts(COIs = conflictsOfInterest,
                                      ASSIGNs = complete.design)
conflictsSummary
```

Other summaries of the data can be useful to inspect. For example, tabulate the number of student and faculty reviewers assigned to each applicant:

```
# Generate data frame that summarizes the number of reviews assigned to each applicant, 
# broken down by student and faculty reviewers
n.revs.per.app <- data.frame(appID = 1:n.applics, 
                             appName = applicantNames,
                             student.revs = apply(student.reviewers$binary.design,1,sum), 
                             faculty.revs = apply(faculty.reviewers$binary.design,1,sum))
```

Don't forget to save outputs! `assignReviewers()` takes a long time and it would be a shame to lose all of your hard work.

```
write.table(complete.design, "Assignments_GGE.csv",
            row.names = FALSE, col.names = TRUE, sep = ",")
write.table(conflictsOfInterest, "applicant_COIs.csv",
            row.names = FALSE, col.names = TRUE, sep = ",")
write.table(conflictsSummary, "Assignments_COIs.csv",
            row.names = FALSE, col.names = TRUE, sep = ",")
write.table(n.revs.per.app, "n_revs_per_app.csv",
            row.names = FALSE, col.names = TRUE, sep = ",")
```

## Applicant ranking

Applicants are ranked using the holistic scores generated by faculty and student reviewers. 


