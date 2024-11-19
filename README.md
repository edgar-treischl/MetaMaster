
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MetaMaster

<!-- badges: start -->

<!-- badges: end -->

The goal of the MetaMaster package is to create meta data for LimeSurvey
which are reproducible, tested, and, in consequence, error-free. The
package provides functions to retrieve data via the LimeSurvey API: Get
template names, survey questions, and text. Furthermore, the packages
implements functions to perform consistency checks, which also increase
the reliability of the meta data and it includes further HTML methods,
for example, to upload survey templates via the API.

## Installation

You can install the development version of MetaMaster like:

``` r
# install_local from installs the package and its dependencies
remotes::install_local("MetaMaster.gz",
                       dependencies = TRUE)
```

## Set up

In order to use the package, you must provide credentials and other
parameters which are needed to get access to the LimeSurvey API (user
name, LimeSurvey instance, etc.). The MetaMaster packages relies on the
`conig` packages to get access to these parameters. All parameters that
are necessary to retrieve data need to be available in the `config.yml`
file of your working directory. The next console shows an example file.

``` yaml
default:
  tmp.server: "Name"
  api_url: "URL"
  tmp.user: "user"
  tmp.credential: "Password"
  
production:
  tmp.server: "Name"
  api_url: "URL"
  tmp.user: "user"
  tmp.credential: "Password"
```

By default, the config package returns the default parameters. Suppose
you want to retrieve data from a test or a production system. To use
parameters to retrieve data from the `production`, set the environmental
variable `R_CONFIG_ACTIVE` to `test` before running.

``` r
Sys.setenv(R_CONFIG_ACTIVE = "test")
```

## Get Functions

Use one of the get function retrieve data from the API. The
`Limer_GetMasterTemplates()` function returns the survey ID (`sid`) and
the name of the survey (`surveyls_title`) for all the master template
from Lime Survey. The function picks survey templates which name start
with the string `master_`. As the next output highlights, the function
adds the corresponding the survey template if the `template` argument is
set to `TRUE`.

``` r
#Let's get started
library(MetaMaster)
Sys.setenv(R_CONFIG_ACTIVE = "test")
df <- Limer_GetMasterTemplates(template = TRUE)
head(df)

# A tibble: 6 × 3
#      sid surveyls_title                       template                       
#    <int> <chr>                                <chr>                          
# 1 197865 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_allg_gm_elt_00_2022_p1
# 2 197865 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_allg_gm_elt_00_2022_p3
# 3 197865 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_allg_rs_elt_00_2022_p1
# 4 197865 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_beru_ws_elt_00_2022_p1
# 5 943467 master_02_bfr_allg_gm_elt_01_2022_v4 tmpl_bfr_allg_gm_elt_01_2022_p2
# 6 943467 master_02_bfr_allg_gm_elt_01_2022_v4 tmpl_bfr_allg_gm_elt_01_2022_p4
```

Next, we can retrieve survey questions and texts via the API. The
function `Limer_GetMasterQuesions()` returns the plot, variable, and
text for survey questions of a given master template. The function needs
the survey ID (`sid`) and the name of the master template (`name`).

``` r
Limer_GetMasterQuesions(id = df$sid[1], name = df$surveyls_title[1])

# A tibble: 29 × 5
#    surveyID template                             plot  variable  text                   
#       <int> <chr>                                <chr> <chr>     <chr>                  
#  1   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B131W124E An dieser Schule herrs…
#  2   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132a     Mein Sohn/meine Tochte…
#  3   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132c     Die Räume der Schule b…
#  4   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B133b     Die Schule ist ein sic…
#  5   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125a An dieser Schule wird …
#  6   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125b Wenn es Konflikte gibt…
#  7   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B333      Mein Sohn/meine Tochte…
#  8   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A632e     Mein Sohn/meine Tochte…
#  9   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A633e     Mein Sohn/meine Tochte…
# 10   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A631      Mein Sohn/meine Tochte…
# ℹ 19 more rows
# ℹ Use `print(n = ...)` to see more rows
```

## Send and Delete

The `Limer_sendSurvey()` function sends a survey template to LimeSurvey.
The function needs the path to the survey template and the name of the
survey template. It expects the survey template to be in the LimeSurvey
LSS format.

``` r
Limer_sendSurvey(lss = "limesurveyMod.lss",
                 name = "mastertemplate")
```

The function `Limer_sendSurveys()` is a convenient wrapper around
`Limer_sendSurvey()`. It sends all survey templates in the working
directory to LimeSurvey.

``` r
Limer_sendSurveys()
```

Finally, the `Limer_DeleteSurvey()` function deletes a survey template
from LimeSurvey. The function needs the survey ID of the survey
template. Be careful, there is no way to restore a deleted survey
template.

``` r
Limer_DeleteSurvey(sid = "123456")
```

Consider to read the vignette for more details how MetaMaster works.
