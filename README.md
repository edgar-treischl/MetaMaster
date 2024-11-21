
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MetaMaster

<!-- badges: start -->

<!-- badges: end -->

The goal of the MetaMaster package is to create meta data for LimeSurvey
which are reproducible, tested, and, in consequence, error-free. The
package provides functions to retrieve data via the Lime Survey API
(`LS_*`); functions to work with a PostgreSQL (`DB_*`) database; and
functions to build the *Master Meta Data*. Furthermore, the package
implements functions to perform consistency checks and further helpers,
for example, to upload survey templates via the API.

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
# ✔ Master Data exported.                            
# ℹ Building metadata for the master data...
# ✔ MetaMaster exported.                                                                # ℹ Sending the report...
#   The email message was sent successfully.                            
# ✔ By the power of Grayskull: Building process completed.
```

Read the *Get Started* vignette for more details how MetaMaster works.
