# Enhanced Portfolio Optimization (EPO)

Computes the optimal portfolio allocation using the Enhanced Portfolio
Optimization (EPO) method of Pedersen, Babu, and Levine (2021).

## Usage

``` r
epo(
  x,
  signal,
  lambda,
  method = c("simple", "anchored"),
  w,
  anchor = NULL,
  normalize = TRUE,
  endogenous = TRUE
)

# Default S3 method
epo(
  x,
  signal,
  lambda,
  method = c("simple", "anchored"),
  w,
  anchor = NULL,
  normalize = TRUE,
  endogenous = TRUE
)

# S3 method for class 'tbl'
epo(
  x,
  signal,
  lambda,
  method = c("simple", "anchored"),
  w,
  anchor = NULL,
  normalize = TRUE,
  endogenous = TRUE
)

# S3 method for class 'xts'
epo(
  x,
  signal,
  lambda,
  method = c("simple", "anchored"),
  w,
  anchor = NULL,
  normalize = TRUE,
  endogenous = TRUE
)

# S3 method for class 'matrix'
epo(
  x,
  signal,
  lambda,
  method = c("simple", "anchored"),
  w,
  anchor = NULL,
  normalize = TRUE,
  endogenous = TRUE
)
```

## Arguments

- x:

  A data-set with asset returns. It should be a `tibble`, a `xts` or a
  `matrix`.

- signal:

  A `double` vector with the investor's beliefs about expected returns
  (signals, forecasts) for each asset in `x`.

- lambda:

  A `double` with the investor's (absolute) risk-aversion coefficient,
  as in the paper's notation. For `method = "simple"`, the resulting
  portfolio's Sharpe ratio does not depend on `lambda`, so any positive
  value works when `normalize = TRUE`. For `method = "anchored"` with
  `endogenous = TRUE`, this argument is ignored because the
  risk-aversion coefficient is calibrated internally.

- method:

  A `character`. One of: `"simple"` or `"anchored"`.

- w:

  A `double` between `0` and `1`. The EPO shrinkage parameter: `0`
  yields standard mean-variance optimization (no shrinkage) and `1`
  yields maximum shrinkage (the anchor portfolio, for
  `method = "anchored"`, or an unoptimized portfolio, for
  `method = "simple"`). In practice, `w` is often chosen empirically,
  e.g. by picking the value that would have maximized the realized
  Sharpe ratio using only past (out-of-sample) data.

- anchor:

  A `double` vector with the anchor (benchmark) portfolio that the
  allocation should not deviate too much from (e.g. a strategic asset
  allocation, a market-cap benchmark, or the 1/N portfolio). Only used
  when `method = "anchored"`.

- normalize:

  A `boolean` indicating whether the allocation should be normalized to
  sum `1` (full-investment constraint). The default is
  `normalize = TRUE`.

- endogenous:

  A `boolean` indicating whether the risk-aversion parameter should be
  calibrated endogenously from the `anchor` and `signal` (paper's
  footnote 13), rather than taken from `lambda`. Only used when
  `method = "anchored"`. The default is `endogenous = TRUE`.

## Value

A numeric vector with the optimal portfolio weights, one per column of
`x`.

## Details

Standard mean-variance optimization (MVO) is highly sensitive to
estimation error in the correlation matrix and in expected returns. This
error is concentrated in the least important principal components of the
correlation matrix (the "problem portfolios"), whose risk tends to be
underestimated and whose expected return tends to be overestimated. EPO
fixes this by shrinking the off-diagonal correlations toward zero by a
factor `w` before running MVO, which increases the estimated volatility
(and lowers the implied Sharpe ratio) of exactly the problem portfolios.

Two flavors of EPO are implemented, both governed by a single shrinkage
parameter, `w`, between `0` (no shrinkage, i.e. standard MVO) and `1`
(maximum shrinkage):

- `method = "simple"` implements the "Simple EPO" (paper's equation 16).
  The allocation is given by \\x = \frac{1}{\lambda} \Sigma_w^{-1} s\\,
  where \\\Sigma_w\\ is the variance-covariance matrix rebuilt from the
  shrunk correlation matrix \\\Omega_w = (1 - w) \Omega + w I\\. At
  `w = 1` all correlations are set to zero, which is equivalent (up to
  scaling) to not optimizing at all.

- `method = "anchored"` implements the "Anchored EPO" (paper's equation
  17), which pulls the solution toward a reference/benchmark portfolio,
  the `anchor`. At `w = 0` the solution is standard MVO; at `w = 1` the
  solution collapses onto the `anchor`; values in between produce
  Black-Litterman-style portfolios in which `w` controls the confidence
  placed in the anchor relative to the `signal`. Unlike Black-Litterman,
  the anchor need not be the market portfolio.

## References

Pedersen, L. H., Babu, A., and Levine, A. (2021). Enhanced Portfolio
Optimization. *Financial Analysts Journal*, 77(2), 124-151.
[doi:10.1080/0015198X.2020.1854543](https://doi.org/10.1080/0015198X.2020.1854543)

## Examples

``` r
x <- diff(log(EuStockMarkets)) # stock returns
s <- colMeans(x) # it could be any signal

##################
### Simple EPO ###
##################

# Traditional Mean-Variance Analysis
epo(x = x, signal = s, lambda = 10, method = "simple", w = 0)
#> [1]  0.1914569  0.9894828 -0.3681779  0.1872382

# 100% Shrinkage
epo(x = x, signal = s, lambda = 10, method = "simple", w = 1)
#> [1] 0.2352863 0.3659986 0.1375249 0.2611902

# 50% Classical MVO and 50% Shrinkage
epo(x = x, signal = s, lambda = 10, method = "simple", w = 0.5)
#> [1]  0.223281853  0.564005906 -0.009868083  0.222580324

####################
### Anchored EPO ###
####################

benchmark <- rep(0.25, 4) # 1/N Portfolio

# Traditional Mean-Variance Analysis
epo(x = x, signal = s, lambda = 10, method = "anchored", w = 0.0, anchor = benchmark)
#> [1]  0.1914569  0.9894828 -0.3681779  0.1872382

# 100% on the Anchor portfolio
epo(x = x, signal = s, lambda = 10, method = "anchored", w = 1.0, anchor = benchmark)
#> [1] 0.25 0.25 0.25 0.25

# Somewhere between the two worlds
epo(x = x, signal = s, lambda = 10, method = "anchored", w = 0.5, anchor = benchmark)
#> [1] 0.2374674 0.4557503 0.1004711 0.2063111
```
