#' Enhanced Portfolio Optimization (EPO)
#'
#' Computes the optimal portfolio allocation using the EPO method with full-investment
#' constraint.
#'
#' @param x A data-set with asset returns. It should be a \code{tibble}, an \code{xts}
#' or a \code{matrix}.
#' @param signal A \code{double} with the investor's belief's (signals, forecasts).
#' @param method A \code{character}. One of: `simple` or `anchored`.
#' @param w A \code{double} between \code{0} and \code{1}. The shrinkage level
#' increases from 0 to 1.
#' @param anchor A \code{double} with the investor anchor (benchmark), in which
#' the allocation should not deviate too much from. Only used when `method = "anchored"`.
#'
#' @return A optimal allocation vector.
#' @export
#'
#' @examples
#' x <- diff(log(EuStockMarkets))
#' s <- colMeans(x) # it could be any signal
#'
#' ##################
#' ### Simple EPO ###
#' ##################
#'
#' # Traditional Mean-Variance Analysis
#' epo(x = x, signal = s, method = "simple", w = 0)
#'
#' # 100% Shrinkage
#' epo(x = x, signal = s, method = "simple", w = 1)
#'
#' # 50% Classical MVO and 50% Shrinkage
#' epo(x = x, signal = s, method = "simple", w = 0.5)
#'
#' ####################
#' ### Anchored EPO ###
#' ####################
#'
#' benchmark <- rep(0.25, 4) # 1/N Portfolio
#'
#' # Traditional Mean-Variance Analysis
#' epo(x = x, signal = s, method = "anchored", w = 0.0, anchor = benchmark)
#'
#' # 100% on the Anchor portfolio
#' epo(x = x, signal = s, method = "anchored", w = 1.0, anchor = benchmark)
#'
#' # Somewhere between the two worlds
#' epo(x = x, signal = s, method = "anchored", w = 0.5, anchor = benchmark)
epo <- function(x, signal, method = c("simple", "anchored"), w, anchor = NULL) {

  UseMethod("epo", x)

}

#' @rdname epo
#' @export
epo.default <- function(x, signal, method = c("simple", "anchored"), w, anchor = NULL) {

  rlang::abort("`x` must be a tibble, xts or a matrix.")

}

#' @rdname epo
#' @export
epo.tbl <- function(x, signal, method = c("simple", "anchored"), w, anchor = NULL) {

  epo_(x = tbl_to_mtx(x), signal = signal, method = method, w = w, anchor = anchor)

}

#' @rdname epo
#' @export
epo.xts <- function(x, signal, method = c("simple", "anchored"), w, anchor = NULL) {

  epo_(x = as.matrix(x), signal = signal, method = method, w = w, anchor = anchor)

}

#' @rdname epo
#' @export
epo.matrix <- function(x, signal, method = c("simple", "anchored"), w, anchor = NULL) {

  epo_(x = x, signal = signal, method = method, w = w, anchor = anchor)

}

#' @keywords internal
epo_ <- function(x, signal, method = c("simple", "anchored"), w, anchor = NULL) {

  # Error Handling
  assertthat::assert_that(assertthat::is.string(method))
  assertthat::assert_that(assertthat::is.number(w))

  if (NCOL(signal) > 1) {
    signal <- matrix(signal)
  }

  if (method == "anchored" & is.null(anchor)) {
    rlang::abort("When the `anchored` method is chosen the `anchor` can't be `NULL`.")
  }

  if (method == "anchored" & NCOL(anchor) > 1) {
    anchor <- matrix(anchor)
  }


  # Begin Computation
  n <- NCOL(x)
  vcov <- stats::cov(x)
  corr <- stats::cor(x)
  I <- diag(n)
  V <- matrix(0, n, n)
  diag(V) <- diag(vcov)
  std <- sqrt(V)
  s <- signal
  a <- anchor

  shrunk_cor <- ((1 - w) * I %*% corr) + (w * I) # equation 7
  cov_tilde  <- std %*% shrunk_cor %*% std # topic 2.II: page 11
  #shrunk_cov <- (1 - w) * cov_tilde + w * V # equation 15
  inv_shrunk_cov <- solve(cov_tilde)

  # ps: the equation 15 could also be written as
  # shrunk_cov <- std %*% ((((1 - w) * I) %*% shrunk_cor) + (w * I)) %*% std


  # The simple EPO
  if (method == "simple") {

    .epo <- inv_shrunk_cov %*% signal # equation 16

  # The anchored EPO
  } else if (method == "anchored") {

    # footnote 13
    .gamma <- c((sqrt(t(a) %*% cov_tilde %*% a) / sqrt(t(s) %*% inv_shrunk_cov %*% cov_tilde %*% inv_shrunk_cov %*% s)))
    # equation 17
    .epo <- inv_shrunk_cov %*% (((1 - w) * .gamma * s) + ((w * I %*% V %*% a)))

  # Error
  } else {

    rlang::abort("`method` not accepted. Try `simple` or `anchored` instead.")

  }

  # Full-Investment constraint
  .epo <- as.double(.epo / sum(.epo))
  .epo

}

