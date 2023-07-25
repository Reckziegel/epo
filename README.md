
<!-- README.md is generated from README.Rmd. Please edit that file -->

# epo

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/Reckziegel/epo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Reckziegel/epo/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/Reckziegel/epo/branch/main/graph/badge.svg)](https://app.codecov.io/gh/Reckziegel/epo?branch=main)

<!-- badges: end -->

The Enhanced Portfolio Optimization (EPO) method delivers a unifying
theory on portfolio optimization. From the perspective of Principal
Component Analysis (PCA), *Pedersen, Babu and Levine (2021)* design a
new approach to identify and correct “problem portfolios”: the least
important Principal Components, ranked by their variance. Incidentally,
these “problem portfolios” are exactly the ones that load heavily in the
traditional Mean-Variance Optimization (MVO).

To fix this issue, EPO pursues a very simple strategy: it shrinks
correlations… and that’s it!

While shrinkage is not new, *Pedersen, Babu and Levine (2021)* main
contribution is to show that reducing *ex-ante* correlations towards
zero is equivalent to increasing the volatilities of the “problem
portfolios”. That is, the least important components Sharpe-Ratios are
adjusted downward reducing the instability in MVO.

More surprisingly, the Enhanced Portfolio Optimization (EPO) method
connects the MVO, Bayesian Optimization and Robust Optimization under a
closed form solution that requires the investor to keep track of just
one parameter, $w\in [0, 1]$.

When, $w=0$, no shrinkage is found, and the EPO solution is identical to
the classical MVO. When $w=1$, the correlations are ignored, and the
final result resembles $1/N$ like portfolios that do not optimize.

In real world applications, however, there is always a risk that the
final portfolio will end up being too far from a reference point
(benchmark). As no surprise, EPO can deal with these cases too: this is
called the “Anchored EPO”.

In the “Anchored EPO”, a $w=0$ yields the classical MVO and a $w=1$
matches the benchmark exactly. The interesting case happens when
$0 < w < 1$, where the output resembles the Black-Litterman model and
the confidence in the *prior* is tuned (again) by $w$. However,
differently from Black-Litterman, in the “Anchored EPO” the reference
point is more general does not necessarily means the “Market Portfolio”.

## Installation

You can install the development version of `epo` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Reckziegel/epo")
```

## Example

``` r
library(epo)

x <- diff(log(EuStockMarkets))
s <- colMeans(x) # it could be any signal (I use the mean for simplicity)

##################
### The Simple EPO
##################

# Traditional Mean-Variance Analysis
epo(x = x, signal = s, method = "simple", w = 0)
#> [1]  0.1914569  0.9894828 -0.3681779  0.1872382

# 100% Shrinkage
epo(x = x, signal = s, method = "simple", w = 1)
#> [1] 0.2352863 0.3659986 0.1375249 0.2611902

# 50% Classical MVO and 50% Shrinkage
epo(x = x, signal = s, method = "simple", w = 0.5)
#> [1]  0.223281853  0.564005906 -0.009868083  0.222580324

####################
### The Anchored EPO 
####################

benchmark <- rep(0.25, 4) # 1/N Portfolio

# Traditional Mean-Variance Analysis
epo(x = x, signal = s, method = "anchored", w = 0.0, anchor = benchmark)
#> [1]  0.1914569  0.9894828 -0.3681779  0.1872382

# 100% on the Anchor portfolio
epo(x = x, signal = s, method = "anchored", w = 1.0, anchor = benchmark)
#> [1] 0.25 0.25 0.25 0.25

# 50% on Mean-Variance Analysis and 50% on the Anchor Portfolio
epo(x = x, signal = s, method = "anchored", w = 0.5, anchor = benchmark)
#> [1] 0.2374674 0.4557503 0.1004711 0.2063111
```

## References

- Pedersen, Lasse Heje and Babu, Abhilash and Levine, Ari, Enhanced
  Portfolio Optimization (January 2, 2020). Lasse Heje Pedersen,
  Abhilash Babu, and Ari Levine (2021), Enhanced Portfolio Optimization,
  Financial Analysts Journal, 77:2, 124-151, DOI:
  10.1080/0015198X.2020.1854543 , Available at
  SSRN: <https://ssrn.com/abstract=3530390> or [http://dx.doi.org/10.2139/ssrn.3530390](https://dx.doi.org/10.2139/ssrn.3530390)
