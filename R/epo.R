#' Enhanced Portfolio Optimization (EPO)
#'
#' Computes the optimal portfolio allocation using the Enhanced Portfolio
#' Optimization (EPO) method of Pedersen, Babu, and Levine (2021).
#'
#' @details
#' Standard mean-variance optimization (MVO) is highly sensitive to
#' estimation error in the correlation matrix and in expected returns. This
#' error is concentrated in the least important principal components of the
#' correlation matrix (the "problem portfolios"), whose risk tends to be
#' underestimated and whose expected return tends to be overestimated. EPO
#' fixes this by shrinking the off-diagonal correlations toward zero by a
#' factor `w` before running MVO, which increases the estimated volatility
#' (and lowers the implied Sharpe ratio) of exactly the problem portfolios.
#'
#' Two flavors of EPO are implemented, both governed by a single shrinkage
#' parameter, `w`, between `0` (no shrinkage, i.e. standard MVO) and `1`
#' (maximum shrinkage):
#'
#' \itemize{
#'   \item `method = "simple"` implements the "Simple EPO" (paper's equation 16).
#'   The allocation is given by \eqn{x = \frac{1}{\lambda} \Sigma_w^{-1} s},
#'   where \eqn{\Sigma_w} is the variance-covariance matrix rebuilt from the
#'   shrunk correlation matrix \eqn{\Omega_w = (1 - w) \Omega + w I}. At
#'   `w = 1` all correlations are set to zero, which is equivalent (up to scaling)
#'   to not optimizing at all.
#'   \item `method = "anchored"` implements the "Anchored EPO" (paper's equation 17),
#'   which pulls the solution toward a reference/benchmark portfolio, the `anchor`.
#'   At `w = 0` the solution is standard MVO; at `w = 1` the solution collapses
#'   onto the `anchor`; values in between produce Black-Litterman-style portfolios
#'   in which `w` controls the confidence placed in the anchor relative to the
#'   `signal`. Unlike Black-Litterman, the anchor need not be the market portfolio.
#' }
#'
#' @param x A data-set with asset returns. It should be a \code{tibble}, a \code{xts}
#' or a \code{matrix}.
#' @param signal A \code{double} vector with the investor's beliefs about
#' expected returns (signals, forecasts) for each asset in `x`.
#' @param lambda A \code{double} with the investor's (absolute) risk-aversion
#' coefficient, as in the paper's notation. For `method = "simple"`, the
#' resulting portfolio's Sharpe ratio does not depend on `lambda`, so any
#' positive value works when `normalize = TRUE`. For `method = "anchored"`
#' with `endogenous = TRUE`, this argument is ignored because the
#' risk-aversion coefficient is calibrated internally.
#' @param method A \code{character}. One of: `"simple"` or `"anchored"`.
#' @param w A \code{double} between \code{0} and \code{1}. The EPO shrinkage
#' parameter: `0` yields standard mean-variance optimization (no shrinkage)
#' and `1` yields maximum shrinkage (the anchor portfolio, for
#' `method = "anchored"`, or an unoptimized portfolio, for
#' `method = "simple"`). In practice, `w` is often chosen empirically, e.g.
#' by picking the value that would have maximized the realized Sharpe ratio
#' using only past (out-of-sample) data.
#' @param anchor A \code{double} vector with the anchor (benchmark) portfolio
#' that the allocation should not deviate too much from (e.g. a strategic
#' asset allocation, a market-cap benchmark, or the 1/N portfolio). Only used
#' when `method = "anchored"`.
#' @param normalize A \code{boolean} indicating whether the allocation should be
#' normalized to sum \code{1} (full-investment constraint). The default is `normalize = TRUE`.
#' @param endogenous A \code{boolean} indicating whether the risk-aversion
#' parameter should be calibrated endogenously from the `anchor` and
#' `signal` (paper's footnote 13), rather than taken from `lambda`. Only used
#' when `method = "anchored"`. The default is `endogenous = TRUE`.
#'
#' @return A numeric vector with the optimal portfolio weights, one per
#' column of `x`.
#'
#' @references
#' Pedersen, L. H., Babu, A., and Levine, A. (2021). Enhanced Portfolio
#' Optimization. \emph{Financial Analysts Journal}, 77(2), 124-151.
#' \doi{10.1080/0015198X.2020.1854543}
#'
#' @export
#'
#' @examples
#' x <- diff(log(EuStockMarkets)) # stock returns
#' s <- colMeans(x) # it could be any signal
#'
#' ##################
#' ### Simple EPO ###
#' ##################
#'
#' # Traditional Mean-Variance Analysis
#' epo(x = x, signal = s, lambda = 10, method = "simple", w = 0)
#'
#' # 100% Shrinkage
#' epo(x = x, signal = s, lambda = 10, method = "simple", w = 1)
#'
#' # 50% Classical MVO and 50% Shrinkage
#' epo(x = x, signal = s, lambda = 10, method = "simple", w = 0.5)
#'
#' ####################
#' ### Anchored EPO ###
#' ####################
#'
#' benchmark <- rep(0.25, 4) # 1/N Portfolio
#'
#' # Traditional Mean-Variance Analysis
#' epo(x = x, signal = s, lambda = 10, method = "anchored", w = 0.0, anchor = benchmark)
#'
#' # 100% on the Anchor portfolio
#' epo(x = x, signal = s, lambda = 10, method = "anchored", w = 1.0, anchor = benchmark)
#'
#' # Somewhere between the two worlds
#' epo(x = x, signal = s, lambda = 10, method = "anchored", w = 0.5, anchor = benchmark)
epo <- function(x, signal, lambda, method = c("simple", "anchored"), w, anchor = NULL, normalize = TRUE, endogenous = TRUE) {

  UseMethod("epo", x)

}

#' @rdname epo
#' @export
epo.default <- function(x, signal, lambda, method = c("simple", "anchored"), w, anchor = NULL, normalize = TRUE, endogenous = TRUE) {

  rlang::abort("`x` must be a tibble, xts or a matrix.")

}

#' @rdname epo
#' @export
epo.tbl <- function(x, signal, lambda, method = c("simple", "anchored"), w, anchor = NULL, normalize = TRUE, endogenous = TRUE) {

  epo_(x = tbl_to_mtx(x), signal = signal, lambda = lambda, method = method, w = w, anchor = anchor, normalize = normalize, endogenous = endogenous)

}

#' @rdname epo
#' @export
epo.xts <- function(x, signal, lambda, method = c("simple", "anchored"), w, anchor = NULL, normalize = TRUE, endogenous = TRUE) {

  epo_(x = as.matrix(x), signal = signal, lambda = lambda, method = method, w = w, anchor = anchor, normalize = normalize, endogenous = endogenous)

}

#' @rdname epo
#' @export
epo.matrix <- function(x, signal, lambda, method = c("simple", "anchored"), w, anchor = NULL, normalize = TRUE, endogenous = TRUE) {

  epo_(x = x, signal = signal, lambda = lambda, method = method, w = w, anchor = anchor, normalize = normalize, endogenous = endogenous)

}

#' @keywords internal
epo_ <- function(x, signal, lambda, method = c("simple", "anchored"), w, anchor = NULL, normalize = TRUE, endogenous = TRUE) {

  # Error Handling
  assertthat::assert_that(assertthat::is.string(method))
  assertthat::assert_that(assertthat::is.number(lambda))
  assertthat::assert_that(assertthat::is.number(w))
  assertthat::assert_that(assertthat::is.flag(normalize))

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

    .epo <- (1 / lambda) * inv_shrunk_cov %*% signal # equation 16

  # The anchored EPO
  } else if (method == "anchored") {

    if (endogenous) {

      # footnote 13
      .gamma <- c((sqrt(t(a) %*% cov_tilde %*% a) / sqrt(t(s) %*% inv_shrunk_cov %*% cov_tilde %*% inv_shrunk_cov %*% s)))
      # equation 17
      .epo <- inv_shrunk_cov %*% (((1 - w) * .gamma * s) + ((w * I %*% V %*% a)))

    } else {

      .epo <- inv_shrunk_cov %*% (((1 - w) * (1 / lambda) * s) + ((w * I %*% V %*% a)))

    }

  # Error
  } else {

    rlang::abort("`method` not accepted. Try `simple` or `anchored` instead.")

  }

  if (normalize) {

    # Force full-investment constraint
    .epo <- as.double(.epo / sum(.epo))

  }

  .epo

}

