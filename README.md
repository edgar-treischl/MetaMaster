
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MetaMaster

<!-- badges: start -->
<!-- badges: end -->

The MetaMaster package creates the *master meta data*. The latter are
meta data for Lime Survey which are reproducible, tested, and - in
consequence - error-free. To this end, the package provides functions to
exchange data via the Lime Survey API (`LS_*`) and functions to work
with a PostgreSQL (`DB_*`) database. Furthermore, the package implements
functions to perform consistency checks and further helpers to automate
the process to build meta data for Lime Survey.

## Installation

You can install the development version of MetaMaster like:

``` r
# install_local from installs the package and its dependencies
remotes::install_local("MetaMaster.gz",
                       dependencies = TRUE)
```

## Meta Master in a Nutshell

Build the MetaMaster:

``` r
MetaMaster::build(send_report = TRUE)

# ℹ Starting the build process...
# ℹ Fetching raw meta data from Lime Survey
# ✔ Raw meta data exported.                          
# ℹ Building metadata for the master data...
# ✔ MetaMaster exported.                                                              
# ℹ Sending the report...
#   The email message was sent successfully.                            
# ✔ By the power of Grayskull: Building process completed.
```

Read the *Get Started* vignette for more details how MetaMaster works.
