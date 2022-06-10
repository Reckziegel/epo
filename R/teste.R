# library(tidyverse)
# library(rsample)
#
# x <- diff(log(EuStockMarkets))
# x <- matrix(x, nrow = nrow(x), ncol = ncol(x))
# colnames(x) <- colnames(EuStockMarkets)
#
# roll <- rolling_origin(data = x, initial = 252 * 5, cumulative = FALSE)
# roll <- roll |>
#   mutate(.analysis   = map(.x = splits, .f = analysis),
#          .assessment = map(.x = splits, .f = assessment))
#
# teste <- function(.tbl) {
#
#   egn <- eigen(cov(.tbl))
#   out <- vector("numeric", 100)
#
#   num_assets <- ncol(sigma_w)
#
#   # Full investment constraint
#   Aeq  <- matrix(1, 1, num_assets)
#   beq  <- 1
#
#   A <- rbind(-diag(num_assets), diag(num_assets))
#   b <- c(-rep(0.4, num_assets), rep(0, num_assets))
#
#   Amat <- rbind(Aeq, A)
#   bvec <- c(beq, b)
#
#   # View
#   s <- apply(x, 2, \(.tbl) tail(.tbl, 1))
#   # lambda <- as.double(
#   #   sqrt(t(s) %*% solve(sigma_w) %*% sigma_tilde %*% solve(sigma_w) %*% s) /
#   #     sqrt(t(colMeans(.tbl)) %*% sigma_tilde %*% colMeans(.tbl))
#   # )
#
#   for (w in seq_along(out)) {
#
#     w <- w / 100
#
#     shrink <- (1 - w) * cor(.tbl) + w * diag(4)
#     sigma_tilde <- diag(sqrt(egn$values)) %*% shrink %*% diag(sqrt(egn$values))
#     sigma_w <- (1 - w) * sigma_tilde + w * diag(egn$values)
#
#     weights <- quadprog::solve.QP(
#       Dmat = 2 * sigma_w,
#       dvec = (1 - w) * s + w * egn$values * colMeans(.tbl),
#       Amat = t(Amat),
#       bvec = bvec,
#       meq  = length(beq)
#     )$solution
#
#     out[[w * 100]] <- as.double(s %*% weights) / sd(.tbl %*% weights)
#
#   }
#
#   out
#
# }
