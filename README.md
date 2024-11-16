
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MetaMaster

<!-- badges: start -->

<!-- badges: end -->

The goal of the MetaMaster package is to create meta data for LimeSurvey
which are reproducible, tested, and in consequence error-free. The
package provides functions to get the names of the master templates, the
data of the master template, and to create new surveys based on a
template.

## Installation

You can install the development version of MetaMaster like so:

``` r
# install_local from installs the package and its dependencies
remotes::install_local("MetaMaster.gz",
                       dependencies = TRUE)
```

## Build meta data

The `Limer_GetMaster()` function returns the master template from
LimeSurvey. The function returns all survey templates declared as
`master_` in the limesurvey instance. Moreover, set the `template`
argument to `TRUE` to get the survey templates. The latter comes from
the meta to data list.

``` r
#Let's get started
library(MetaMaster)
Sys.setenv(R_CONFIG_ACTIVE = "test")
df <- Limer_GetMasterTemplates(template = TRUE)
head(df)
```

Since we know the master template, we can retrieve survey question via
the API. The function `get_MasterMeta()` returns the survey questions of
a given master template. The function takes the survey ID (`sid`) and
the name of the survey (`name`) as function argument.

``` r
get_MasterMeta(id = df$sid[1], 
               name = df$surveyls_title[1])
```

Moreover, the function `testrun()` takes the input of the list of survey
templates and master templates and merges the results as a list.

``` r
testrun(export = TRUE)
```

The latter is wrapper function around `purrr::map2()` and
`joinMetaGisela()`, as the next console shows for the first five survey
and master templates.

``` r
#Join the meta data with the LimeSurvey API for all survey and master templates
purrr::map2(df$sid[1:5],
            df$surveyls_title[1:5],
            get_MasterMeta)
```

Share the results of the test run with the `send_testrun()` function.
This function sends the results of the test run via email.

``` r
#Send the test run
send_testrun(sendto = "john.doe@johndoe.com")
```

## TBD

Create a new file with the `update_allMastersLimeSurvey()` function. The
latter runs `get_MasterTemplate()` which returns all masters templates
and saves the result as an Excel file.

``` r
Limer_GetMasterData(export = TRUE)
buildMetaMaster(path = "MasterData_2024_11_11.xlsx", export = TRUE)
send_testrun(sendto = "johndoe@doe.com")
```
