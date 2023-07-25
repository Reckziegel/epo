#' @keywords internal
tbl_to_mtx <- function(x) as.matrix(dplyr::select(x, where(is.numeric)))

