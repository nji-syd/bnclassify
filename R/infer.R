# x is a bnc_dag
compute_cp <- function(x, dataset) {
  p <- compute_log_joint(x, dataset)
  p <- log_normalize(p)
  stopifnot(are_pdists(p))
  p
}
compute_ll <- function(x, dataset) {
  stop("Not implemented.")
}
# Compute unnormalized log class posterior
compute_log_joint <- function(x, dataset) {
  if (!anyNA(dataset)) {
    compute_log_joint_complete(x, dataset)
  }
  else { 
    ind_complete <- complete.cases(dataset)
    p_complete <- 
      compute_log_joint_complete(x, dataset[ind_complete, , drop = FALSE])
    p_incomplete <- 
      compute_log_joint_incomplete(x, dataset[!ind_complete, , drop = FALSE])
    # put the two together
    p <- matrix(numeric(), nrow = nrow(dataset), ncol = ncol(p_incomplete), 
                   dimnames = list(NULL, dimnames(p_incomplete)[[2]]))
    p[ind_complete, ] <- p_complete
    p[!ind_complete, ] <- p_incomplete
    p
  }
}
compute_log_joint_complete <- function(x, dataset) {
  # Check dataset complete
  stopifnot(!anyNA(dataset))  
  compute_anb_log_joint(x, dataset)
}
compute_log_joint_incomplete <- function(x, dataset) {
  # Check all rows in dataset have missings 
  stopifnot(sum(complete.cases(dataset)) == 0)
  # Check x is a bnc_bn
  check_bnc_bn(x)
  # Get gRain from bnc_bn 
  grain <- as_grain(x)
  # Get class var
  class <- class_var(x)
  # Call grain class posterior
  compute_grain_log_joint(grain, dataset, class)
}