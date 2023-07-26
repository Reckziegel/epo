
<!-- README.md is generated from README.Rmd. Please edit that file -->

# epo

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/Reckziegel/epo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Reckziegel/epo/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/Reckziegel/epo/branch/main/graph/badge.svg)](https://app.codecov.io/gh/Reckziegel/epo?branch=main)

<!-- badges: end -->

The Enhanced Portfolio Optimization (EPO) method presents a
groundbreaking approach to portfolio optimization, offering a unifying
theory that builds upon Principal Component Analysis (PCA), as proposed
by Pedersen, Babu, and Levine (2021). This innovative method effectively
addresses the issue of “problem portfolios,” referring to Principal
Components with the least significance ranked by their variance, which
often cause complications in traditional Mean-Variance Optimization
(MVO).

To tackle this problem, EPO introduces a straightforward yet powerful
strategy: it shrinks correlations! The key insight from Pedersen, Babu,
and Levine (2021) is that by reducing *ex-ante* correlations close to
zero, the volatilities of these “problem portfolios” can be effectively
increased. Consequently, the method stabilizes MVO by adjusting downward
the Sharpe-Ratios of the least important components.

The elegance of the EPO approach lies in its connection to three major
optimization methods: MVO, Bayesian Optimization, and Robust
Optimization. By incorporating a closed-form solution with a single
shrinkage parameter, denoted as $w \in \{0, 1\}$, the investor can
seamlessly navigate through the optimization process. When $w=0$, the
EPO solution coincides with the classical MVO. Conversely, setting $w=1$
disregards correlations, resulting in a portfolio similar to a
non-optimized $1/N$ allocation.

In real-world applications, it is crucial to consider the potential
deviation from a reference point or benchmark. EPO effectively handles
this concern through the “Anchored EPO” approach. When $w=0$, it aligns
with the classical MVO, while a $w=1$ precisely matches the benchmark.
The most intriguing outcomes arise when $0 < w < 1$, leading to
portfolios resembling the Black-Litterman model. Here, the shrinking
parameter, $w$, tunes the confidence in the *prior*, offering a flexible
and dynamic optimization process. It is important to note that unlike
Black-Litterman, the “Anchored EPO” does not restrict the reference
point to the “Market Portfolio,” making it more general and widely
applicable.

Overall, the Enhanced Portfolio Optimization (EPO) method presents a
novel, efficient, and adaptable framework for portfolio optimization.
Its ability to address the limitations of traditional methods while
incorporating various optimization approaches through a single
preference parameter makes it a powerful tool for investors seeking more
stable and well-tailored portfolios.

## Installation

Install the official version from CRAN with:

``` r
install.packages("epo")
```

Install the development version from github with:

``` r
# install.packages("devtools")
devtools::install_github("Reckziegel/epo")
```

## Example

``` r
library(epo)

x <- diff(log(EuStockMarkets)) # stock returns
s <- colMeans(x) # it could be any signal 

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
  SSRN: <https://www.ssrn.com/abstract=3530390> or [http://dx.doi.org/10.2139/ssrn.3530390](https://dx.doi.org/10.2139/ssrn.3530390)
