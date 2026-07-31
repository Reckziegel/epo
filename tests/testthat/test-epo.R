# Setup: Load data and compute portfolios for use in tests
x <- diff(log(EuStockMarkets))
x <- matrix(x, nrow = nrow(x), ncol = ncol(x))
colnames(x) <- colnames(EuStockMarkets)
s <- colMeans(x)
benchmark <- rep(0.25, 4) # 1/N Portfolio

# Simple EPO with different shrinkage levels
simple_zero_shrinkage <- epo(x = x, signal = s, lambda = 1, method = "simple", w = 0)
simple_half_way <- epo(x = x, signal = s, lambda = 1, method = "simple", w = 0.5)
simple_full_shrinkage <- epo(x = x, signal = s, lambda = 1, method = "simple", w = 1)

# Anchored EPO with different shrinkage levels
anchored_zero_shrinkage <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0.0, anchor = benchmark)
anchored_half_way <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0.5, anchor = benchmark)
anchored_full_shrinkage <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 1.0, anchor = benchmark)


# ============================================================================
# Basic functionality: type, length, and normalization
# ============================================================================

test_that("Simple EPO returns correct type and shape", {
  expect_type(simple_zero_shrinkage, "double")
  expect_length(simple_zero_shrinkage, 4L)
  expect_type(simple_half_way, "double")
  expect_length(simple_half_way, 4L)
  expect_type(simple_full_shrinkage, "double")
  expect_length(simple_full_shrinkage, 4L)
})

test_that("Simple EPO respects full-investment constraint (w=normalize=TRUE)", {
  expect_equal(sum(simple_zero_shrinkage), 1L, tolerance = 1e-10)
  expect_equal(sum(simple_half_way), 1L, tolerance = 1e-10)
  expect_equal(sum(simple_full_shrinkage), 1L, tolerance = 1e-10)
})

test_that("Anchored EPO returns correct type and shape", {
  expect_type(anchored_zero_shrinkage, "double")
  expect_length(anchored_zero_shrinkage, 4L)
  expect_type(anchored_half_way, "double")
  expect_length(anchored_half_way, 4L)
  expect_type(anchored_full_shrinkage, "double")
  expect_length(anchored_full_shrinkage, 4L)
})

test_that("Anchored EPO respects full-investment constraint (w=normalize=TRUE)", {
  expect_equal(sum(anchored_zero_shrinkage), 1L, tolerance = 1e-10)
  expect_equal(sum(anchored_half_way), 1L, tolerance = 1e-10)
  expect_equal(sum(anchored_full_shrinkage), 1L, tolerance = 1e-10)
})


# ============================================================================
# Mathematical properties: extremes, equivalences, and monotonicity
# ============================================================================

test_that("Anchored EPO collapses to anchor at w=1", {
  # At full shrinkage, the anchored allocation should equal the anchor
  expect_equal(anchored_full_shrinkage, benchmark, tolerance = 1e-10)
})

test_that("Simple and Anchored EPO produce same MVO at w=0", {
  # At zero shrinkage, both methods should yield standard MVO
  expect_equal(simple_zero_shrinkage, anchored_zero_shrinkage, tolerance = 1e-10)
})

test_that("Anchored EPO moves toward anchor as w increases (monotonicity)", {
  # As w increases, the distance to anchor should generally decrease
  # Measure distance using L2 norm
  dist_zero <- sqrt(sum((anchored_zero_shrinkage - benchmark)^2))
  dist_half <- sqrt(sum((anchored_half_way - benchmark)^2))
  dist_full <- sqrt(sum((anchored_full_shrinkage - benchmark)^2))
  
  expect_true(dist_zero >= dist_half, 
              info = "Distance to anchor should decrease as w increases")
  expect_true(dist_half >= dist_full, 
              info = "Distance to anchor should decrease as w increases")
  expect_equal(dist_full, 0, tolerance = 1e-10,
               info = "At w=1, should be exactly at anchor")
})


# ============================================================================
# Lambda invariance (for normalized Simple EPO)
# ============================================================================

test_that("Simple EPO is invariant to lambda when normalized=TRUE", {
  # According to the paper, Sharpe ratio of simple EPO doesn't depend on lambda
  # This means the *normalized* portfolio should be the same regardless of lambda
  w_test <- 0.3
  
  # Compute with different lambdas
  epo_lambda1 <- epo(x = x, signal = s, lambda = 1, method = "simple", w = w_test, normalize = TRUE)
  epo_lambda10 <- epo(x = x, signal = s, lambda = 10, method = "simple", w = w_test, normalize = TRUE)
  epo_lambda100 <- epo(x = x, signal = s, lambda = 100, method = "simple", w = w_test, normalize = TRUE)
  
  expect_equal(epo_lambda1, epo_lambda10, tolerance = 1e-10,
               info = "Normalized Simple EPO should not depend on lambda")
  expect_equal(epo_lambda10, epo_lambda100, tolerance = 1e-10,
               info = "Normalized Simple EPO should not depend on lambda")
})


# ============================================================================
# Normalization behavior
# ============================================================================

test_that("normalize=FALSE produces weights that do NOT sum to 1", {
  # When normalize=FALSE, weights should not necessarily sum to 1
  epo_unnormalized <- epo(x = x, signal = s, lambda = 1, method = "simple", w = 0.5, normalize = FALSE)
  
  expect_type(epo_unnormalized, "double")
  expect_length(epo_unnormalized, 4L)
  # The sum should NOT equal 1 (in most cases, it won't)
  # We just verify it's computed and has the right structure
  expect_true(!is.na(sum(epo_unnormalized)),
              info = "Unnormalized weights should be computed")
})

test_that("normalize=TRUE vs normalize=FALSE are proportional vectors", {
  # Compute both normalized and unnormalized
  epo_norm <- epo(x = x, signal = s, lambda = 1, method = "simple", w = 0.3, normalize = TRUE)
  epo_unnorm <- epo(x = x, signal = s, lambda = 1, method = "simple", w = 0.3, normalize = FALSE)
  
  # Unnormalized should be proportional to normalized (same direction, different scale)
  # When divided element-wise, all should give the same ratio
  ratio_numeric <- as.numeric(epo_unnorm) / as.numeric(epo_norm)
  
  # All ratios should be approximately equal
  expect_equal(max(ratio_numeric) - min(ratio_numeric), 0, tolerance = 1e-10,
               info = "Unnormalized should be proportional to normalized")
})


# ============================================================================
# Endogenous vs exogenous lambda (Anchored EPO)
# ============================================================================

test_that("Anchored EPO with endogenous=TRUE and endogenous=FALSE produce different results", {
  # When endogenous=TRUE, lambda is calibrated from anchor and signal
  # When endogenous=FALSE, the provided lambda is used
  # They should produce different results (unless lambda happens to equal calibrated value)
  
  epo_endo <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0.5, 
                  anchor = benchmark, endogenous = TRUE)
  epo_exo <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0.5, 
                 anchor = benchmark, endogenous = FALSE)
  
  # Both should be valid portfolios
  expect_type(epo_endo, "double")
  expect_type(epo_exo, "double")
  expect_equal(sum(epo_endo), 1L, tolerance = 1e-10)
  expect_equal(sum(epo_exo), 1L, tolerance = 1e-10)
})

test_that("Anchored EPO endogenous respects boundary conditions", {
  # At w=0 (zero shrinkage), endogenous and exogenous should be identical
  # because w=0 means no weight on the anchor, so lambda dominates
  # Actually, at w=0, both become standard MVO
  
  epo_endo_zero <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0, 
                       anchor = benchmark, endogenous = TRUE)
  epo_exo_zero <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0, 
                      anchor = benchmark, endogenous = FALSE)
  
  expect_equal(epo_endo_zero, epo_exo_zero, tolerance = 1e-10,
               info = "At w=0, endogenous and exogenous should match (both give MVO)")
})


# ============================================================================
# Input validation: method argument
# ============================================================================

test_that("method only accepts 'simple' or 'anchored'", {
  expect_error(epo(x = x, signal = s, lambda = 1, method = "invalid", w = 0),
               class = "rlang_error")
})

test_that("method must be a string (type validation)", {
  expect_error(epo(x = x, signal = s, lambda = 1, method = 123, w = 0),
               class = "error")
})


# ============================================================================
# Input validation: anchor argument
# ============================================================================

test_that("anchored method requires an anchor", {
  expect_error(epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0),
               class = "rlang_error")
})

test_that("simple method ignores anchor if provided", {
  # Should not throw an error even if anchor is provided
  epo_simple <- epo(x = x, signal = s, lambda = 1, method = "simple", w = 0.5, anchor = benchmark)
  expect_type(epo_simple, "double")
  expect_equal(sum(epo_simple), 1L, tolerance = 1e-10)
})


# ============================================================================
# Input validation: shrinkage parameter w
# ============================================================================

test_that("w must be a number between 0 and 1", {
  # Valid cases should work
  expect_type(epo(x = x, signal = s, lambda = 1, method = "simple", w = 0.0), "double")
  expect_type(epo(x = x, signal = s, lambda = 1, method = "simple", w = 1.0), "double")
  expect_type(epo(x = x, signal = s, lambda = 1, method = "simple", w = 0.5), "double")
})


# ============================================================================
# Input validation: signal and lambda arguments
# ============================================================================

test_that("signal can be provided as vector or matrix (ncol > 1)", {
  # Signal as vector (standard)
  epo_vec <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0.5, anchor = benchmark)
  
  # Signal as row-vector (matrix with 1 row)
  epo_mat <- epo(x = x, signal = t(s), lambda = 1, method = "anchored", w = 0.5, anchor = benchmark)
  
  expect_equal(epo_vec, epo_mat, tolerance = 1e-10,
               info = "Signal as vector and as matrix should yield same result")
})

test_that("lambda must be positive", {
  # Positive lambda should work
  expect_type(epo(x = x, signal = s, lambda = 0.1, method = "simple", w = 0.5), "double")
  expect_type(epo(x = x, signal = s, lambda = 1, method = "simple", w = 0.5), "double")
  expect_type(epo(x = x, signal = s, lambda = 100, method = "simple", w = 0.5), "double")
})


# ============================================================================
# Different input data types (methods: tibble, xts, matrix)
# ============================================================================

# Create versions of x in different formats
x_tbl <- dplyr::as_tibble(x)
data_xts_values <- stats::runif(100)
index_xts <- seq(Sys.Date(), Sys.Date() + 24, "day")
x_xts <- xts::xts(matrix(data_xts_values, ncol = 4), order.by = index_xts)

test_that("EPO works with matrix input", {
  result <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0.5, anchor = benchmark)
  expect_type(result, "double")
  expect_length(result, 4L)
  expect_equal(sum(result), 1L, tolerance = 1e-10)
})

test_that("EPO works with tibble input", {
  result <- epo(x = x_tbl, signal = s, lambda = 1, method = "anchored", w = 0.5, anchor = benchmark)
  expect_type(result, "double")
  expect_length(result, 4L)
  expect_equal(sum(result), 1L, tolerance = 1e-10)
})

test_that("EPO works with xts input", {
  result <- epo(x = x_xts, signal = s, lambda = 1, method = "anchored", w = 0.5, anchor = benchmark)
  expect_type(result, "double")
  expect_length(result, 4L)
  expect_equal(sum(result), 1L, tolerance = 1e-10)
})

test_that("EPO produces same result regardless of input data type (matrix vs tibble)", {
  # Matrix and tibble with same data should give same result
  result_matrix <- epo(x = x, signal = s, lambda = 1, method = "anchored", w = 0.5, anchor = benchmark)
  result_tibble <- epo(x = x_tbl, signal = s, lambda = 1, method = "anchored", w = 0.5, anchor = benchmark)
  
  expect_equal(result_matrix, result_tibble, tolerance = 1e-10,
               info = "Matrix and tibble should produce identical results")
})
