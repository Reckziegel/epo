
<!-- README.md is generated from README.Rmd. Please edit that file -->

# epo

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

The **Enhanced Portfolio Optimization (EPO)** offers a new explanation
to why traditional portfolio optimization performs poorly out-of-sample.
In EPO, portfolio returns are analysed based in their Principal
Components (PC) and the least important components (ranked by their
variance) are labelled “problem portfolios”. Incidentaly, these “problem
portfolios” are exactly the ones that load heavily in the traditional
Mean-Variance Optimization (MVO). Why? Because as the number of
components grow in size, volatilities fall faster than returns, which
“inflates” the Sharpe Ratios of the least important components.

To fix this problem, **EPO** pursues a very simple strategy: it shrinks
the correlation matrix… and that’s it!

While shrinkage is not new, *Pedersen, Babu and Levine (2021)*
contribution is to show that reducing *ex-ante* correlations towards
zero is equivalent to increasing the volatilities of the “problem
portfolios” (that is, it shrinks their Sharpe Ratios). Therefore, in
this approach - called the “Simple EPO” - shrinkage plays a dual role
of: (i) trimming errors in risk *and* expected returns; (ii) boost
Sharpe-Ratios out-of-sample. It shrinks, then optimizes.

The idea that risk-adjusted returns are measured with uncertainty allows
**Enhanced Portfolio Optimization (EPO)** to connect different strands
of the research, such as: the Classical Mean-Variance Optimization
(MVO), Reverse Optimization, Bayesian Optimization (Black-Litterman) and
Robust Optimization.

More surprisingly, all the theories connect under a simple closed form
solution that requires the investor to keep track of a single parameter,
$w \in [0, 1]$.

When, $w=0$, no shrinkage is found and the **EPO** solution is identical
to the classical MVO. When $w=1$, the correlations are ignored and the
final result resembles $1/N$ like portfolios that do not optimize.

In real world applications, however, there is always a risk that the
final portfolio will end up too far from a reference point (benchmark).
As no surprise, EPO can deal with these cases too. But now, the $w$
parameter gets an additional role: (i) it shrinks the corraltion matrix
*and* how close (or how far) the final solution stays from the *prior*
allocation. This is called the “Anchored EPO”.

In the “Anchored EPO”, a $w=0$ yields the classical MVO and a $w=1$
matches the “anchor” exactly. Given the theorical formulation, when
$w > 0$ and $w<1$ the output resembles the Bayesian Allocation
(Black-Litterman model) where the confidence in the prior is given by
$w$. However, in the “Anchored EPO” the reference point plays a more
general role were the benchmark does not necessarily means the “Market
Portfolio”.

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
s <- colMeans(x) # it could be any signal 
                 # I use the mean returns for simplicity

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

# Somewhere between the two worlds
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
