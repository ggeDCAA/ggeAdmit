#' A function to generate an incomplete block experimental design that pairs applicants with reviewers
#'
#' @param number.alternatives Number of applicants
#' @param number.blocks Number of reviewers
#' @param alternatives.per.block The desired number of applicants that will be assigned to each reviewer (default = 14)
#' @param n.repeats Number of times algDesign::optBlock() is repeated (default = 1)
#' @param nReps Number of replicates performed within algDesign::optBlock (default = 300)
#' @return A list with 6 components, one of which is the "design." The design has two components, blockID, which refers to row number of that reviewer in the source data, and alternative, which referes to the number of applicants to be reviewed.
#' @examples
#' \dontshow{
#' sample.design <- assignReviewers(number.alternatives = 30, 
#'                                  number.blocks = 20,
#'                                  nReps = 10)
#'
#'
#' }
#' \dontrun{
#'
#' sample.design <- assignReviewers(number.alternatives = n.applics, 
#'                                  number.blocks = n.sr)
#' 
#' }
#' @import AlgDesign
#' @export
# 

assignReviewers <- function(number.alternatives, 
                            number.blocks, 
                            alternatives.per.block = 14, 
                            n.repeats = 1, 
                            nReps = 300){
  # Check that the parameters are appropriate
  # Sawtooth recommends that number.blocks >= 3 * number.alternatives / alternatives.per.block
  
  if (number.blocks < 3 * number.alternatives / alternatives.per.block)
    warning("It is recommended that number.blocks >= 3 * number.alternatives / alternatives.per.block");
  best.result = NULL
  best.D = -Inf
  for (i in 1:n.repeats) {
    alg.results <- optBlock(~.,
                            withinData = factor(1:number.alternatives),
                            blocksizes = rep(alternatives.per.block,number.blocks), 
                            nRepeats = nReps) #BIB
    if (alg.results$D > best.D) {
      best.result = alg.results 
      best.D = alg.results$D
    }
  }
  # this is the number of that application being assigned (?)
  design <- matrix(NA,
                   number.blocks,
                   alternatives.per.block, 
                   dimnames = list(block = 1:number.blocks, 
                                   Alternative = 1:alternatives.per.block))
  # this is whether the reviewer is student of faculty (?)
  binary.design <- matrix(0,
                          number.blocks,
                          number.alternatives, 
                          dimnames = list(block = 1:number.blocks, 
                                          alternative = 1:number.alternatives))
  counter <- 0
  for (block in best.result$Blocks) {
    counter <- counter + 1
    blck <- unlist(block)
    design[counter,] <- blck
    for (a in blck)
      binary.design[counter,a] <- 1
  }
  n.appearances.per.alternative <- table(as.numeric(design))
  combinations.of.alternatives <- crossprod(table(c(rep(1:number.blocks, 
                                                        rep(alternatives.per.block,
                                                            number.blocks))), 
                                                  best.result$design[,1]))
  list(binary.design = t(binary.design), 
       design = t(design), 
       frequencies = n.appearances.per.alternative, 
       pairwise.frequencies = combinations.of.alternatives, 
       binary.correlations = round(cor(binary.design),2),
       optAlgD = best.D)
}
# *Note: In the future, potentially include "illegal pairs" (conflicts of interest). In other words, tell the function not to allow some pairings. Use https://stackoverflow.com/questions/38020958/coerce-optblock-in-algdesign-r-package-to-only-show-certain-treatments-per-row-o

