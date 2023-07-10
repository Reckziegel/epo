x <- diff(log(EuStockMarkets))
x <- matrix(x, nrow = nrow(x), ncol = ncol(x))
colnames(x) <- colnames(EuStockMarkets)
s <- colMeans(x)

# Traditional Mean-Variance Analysis
simple_zero_shrinkage <- epo(x = x, signal = s, method = "simple", w = 0)
# 100% Shrinkage
simple_full_shrinkage <- epo(x = x, signal = s, method = "simple", w = 1)
# 50% Classical MVO and 50% Shrinkage
simple_half_way <- epo(x = x, signal = s, method = "simple", w = 0.5)

test_that("Simple EPO works", {

  expect_type(simple_zero_shrinkage, "double")
  expect_length(simple_zero_shrinkage, 4L)
  expect_equal(sum(simple_zero_shrinkage), 1L)

  expect_type(simple_full_shrinkage, "double")
  expect_length(simple_full_shrinkage, 4L)
  expect_equal(sum(simple_full_shrinkage), 1L)

  expect_type(simple_half_way, "double")
  expect_length(simple_half_way, 4L)
  expect_equal(sum(simple_half_way), 1L)

})


benchmark <- rep(0.25, 4) # 1/N Portfolio

# Traditional Mean-Variance Analysis
anchored_zero_shrinkage <- epo(x = x, signal = s, method = "anchored", w = 0.0, anchor = benchmark)
# 100% on the Anchor portfolio
anchored_full_shrinkage <- epo(x = x, signal = s, method = "anchored", w = 1.0, anchor = benchmark)
# Somewhere between the two worlds
anchored_half_way <- epo(x = x, signal = s, method = "anchored", w = 0.5, anchor = benchmark)


test_that("Anchored EPO works", {

  expect_type(anchored_zero_shrinkage, "double")
  expect_length(anchored_zero_shrinkage, 4L)
  expect_equal(sum(anchored_zero_shrinkage), 1L)

  expect_type(anchored_full_shrinkage, "double")
  expect_length(anchored_full_shrinkage, 4L)
  expect_equal(sum(anchored_full_shrinkage), 1L)

  expect_type(anchored_half_way, "double")
  expect_length(anchored_half_way, 4L)
  expect_equal(sum(anchored_half_way), 1L)

})


test_that("Simple and Anchored are equal on the extremes", {

  # Full shrinkage in EPO yields the reference allocation
  expect_equal(anchored_full_shrinkage, benchmark)

  # Zero shrinkage yields the MVO
  expect_equal(simple_zero_shrinkage, anchored_zero_shrinkage)

})
