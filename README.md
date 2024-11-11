
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

## Test the meta data

Test the meta data by running a test. A test run implies that all
variables from the LimeSurvey API are matched with the meta data and
only the variables that can’t be matched are returned. Thus, a test run
creates a list of unmatched variables per master and survey template
that will result in an error. First, load the package and run the
`get_templates()` function. It return unique names of survey templates.
This information comes from the master to template file.

``` r
#Get the names all unique survey templates
# templates <- get_templates()
# head(templates)
library(MetaMaster)
Sys.setenv(R_CONFIG_ACTIVE = "test")
df <- Limer_GetMaster(template = TRUE)
head(df)
#> # A tibble: 6 × 3
#>      sid surveyls_title                       template                       
#>    <int> <chr>                                <chr>                          
#> 1 197865 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_allg_gm_elt_00_2022_p1
#> 2 197865 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_allg_rs_elt_00_2022_p1
#> 3 197865 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_beru_ws_elt_00_2022_p1
#> 4 943467 master_02_bfr_allg_gm_elt_01_2022_v4 tmpl_bfr_allg_gm_elt_01_2022_p2
#> 5 866667 master_03_bfr_allg_gm_leh_00_2022_v4 tmpl_bfr_allg_gm_leh_00_2022_p1
#> 6 866667 master_03_bfr_allg_gm_leh_00_2022_v4 tmpl_bfr_allg_gm_leh_00_2022_p2
```

A master template can be used more than once, which is why we start with
the survey template and we match it with the master template. The
function `get_master()` returns the name of the master template for a
survey template. This function also relies on the master to template
file. Thus, we need to take care that all mastertemplates are listed in
the master to template file and that all survey templates are correctly
matched.

``` r
#mastername <- get_master(templatename = "tmpl_bfr_allg_gm_elt_00_2022_p1")
#mastername
```

Since we know the master template, we can retrieve survey question via
the API. The function `get_masters()` is a wrapper function for these
steps. It returns a list of all survey templates and the corresponding
master templates.

``` r
mastertemplatesList <- get_masters()
#Survey templates
#head(mastertemplatesList$template)
```

``` r
#Master templates
head(mastertemplatesList$master)
#> [1] "master_01_bfr_allg_gm_elt_00_2022_v4"
#> [2] "master_01_bfr_allg_gm_elt_00_2022_v4"
#> [3] "master_01_bfr_allg_gm_elt_00_2022_v4"
#> [4] "master_02_bfr_allg_gm_elt_01_2022_v4"
#> [5] "master_03_bfr_allg_gm_leh_00_2022_v4"
#> [6] "master_03_bfr_allg_gm_leh_00_2022_v4"
```

The function `get_TemplateDF()` returns question variables (vars) of a
given master template.

``` r
master <- get_TemplateDF(mastername = "master_01_bfr_allg_gm_elt_00_2022_v4")
master
```

Internally, it picks the survey ID (`sid`) from the
`allMastersLimeSurvey.xlsx` file. Make sure this file is up to date.
Create a new file with the `update_allMastersLimeSurvey()` function. The
latter runs `get_MasterTemplate()` which returns all masters templates
and saves the result as an Excel file.

``` r
get_MasterTemplate()
#> # A tibble: 38 × 2
#>       sid surveyls_title                      
#>     <int> <chr>                               
#>  1 197865 master_01_bfr_allg_gm_elt_00_2022_v4
#>  2 943467 master_02_bfr_allg_gm_elt_01_2022_v4
#>  3 866667 master_03_bfr_allg_gm_leh_00_2022_v4
#>  4 383484 master_04_bfr_allg_gs_elt_00_2022_v4
#>  5 687118 master_05_bfr_allg_gs_elt_01_2022_v4
#>  6 661758 master_06_bfr_allg_gs_leh_00_2022_v4
#>  7 386673 master_07_bfr_allg_gs_sus_00_2022_v4
#>  8 956526 master_08_bfr_allg_gs_sus_02_2022_v4
#>  9 533711 master_09_bfr_allg_gy_elt_00_2022_v4
#> 10 197211 master_10_bfr_allg_gy_elt_01_2022_v4
#> # ℹ 28 more rows
```

To match the result from the LimeSurvey API, we need the manually
created meta data. The function `gisela_report()` returns the variable
list of a report for a given survey template.

``` r
gisela_report(template = "tmpl_bfr_allg_gm_elt_00_2022_p1")
```

Finally, there are two wrapper function to create a test run. First, we
need to match the results from the API with the meta data. The function
`joinMetaGisela()` does this. Moreover, the function `testrun()` takes
the input of the list of survey templates and master templates and
merges the results as a list.

``` r
testrun(export = TRUE)
```

The latter is wrapper function around `purrr::map2()` and
`joinMetaGisela()`, as the next console shows for the first five survey
and master templates.

``` r
#Join the meta data with the LimeSurvey API for all survey and master templates
purrr::map2(mastertemplatesList$template[1:5],
            mastertemplatesList$master[1:5],
            joinMetaGisela)
```

Share the results of the test run with the `send_testrun()` function.
This function sends the results of the test run via email.

``` r
#Send the test run
send_testrun(sendto = "john.doe@johndoe.com")
```
