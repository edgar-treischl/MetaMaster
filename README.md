
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

Since we know the master template, we can retrieve survey question via
the API. The function `get_MasterMeta()` returns the survey questions of
a given master template. The function takes the survey ID (`sid`) and
the name of the survey (`name`) as function argument.

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
            Limer_GetMasterQuesions)

# [[1]]
# # A tibble: 29 × 5
#    surveyID template                             plot  variable  text                                   
#       <int> <chr>                                <chr> <chr>     <chr>                                  
#  1   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B131W124E An dieser Schule herrscht ein freundli…
#  2   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132a     Mein Sohn/meine Tochter fühlt sich an …
#  3   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132c     Die Räume der Schule bieten eine angen…
#  4   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B133b     Die Schule ist ein sicherer Ort.       
#  5   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125a An dieser Schule wird konsequent gegen…
#  6   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125b Wenn es Konflikte gibt, trägt die Schu…
#  7   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B333      Mein Sohn/meine Tochter lernt an diese…
#  8   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A632e     Mein Sohn/meine Tochter lernt in der S…
#  9   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A633e     Mein Sohn/meine Tochter erfährt in der…
# 10   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A631      Mein Sohn/meine Tochter lernt in der S…
# # ℹ 19 more rows
# # ℹ Use `print(n = ...)` to see more rows
# 
# [[2]]
# # A tibble: 29 × 5
#    surveyID template                             plot  variable  text                                   
#       <int> <chr>                                <chr> <chr>     <chr>                                  
#  1   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B131W124E An dieser Schule herrscht ein freundli…
#  2   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132a     Mein Sohn/meine Tochter fühlt sich an …
#  3   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132c     Die Räume der Schule bieten eine angen…
#  4   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B133b     Die Schule ist ein sicherer Ort.       
#  5   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125a An dieser Schule wird konsequent gegen…
#  6   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125b Wenn es Konflikte gibt, trägt die Schu…
#  7   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B333      Mein Sohn/meine Tochter lernt an diese…
#  8   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A632e     Mein Sohn/meine Tochter lernt in der S…
#  9   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A633e     Mein Sohn/meine Tochter erfährt in der…
# 10   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A631      Mein Sohn/meine Tochter lernt in der S…
# # ℹ 19 more rows
# # ℹ Use `print(n = ...)` to see more rows
# 
# [[3]]
# # A tibble: 29 × 5
#    surveyID template                             plot  variable  text                                   
#       <int> <chr>                                <chr> <chr>     <chr>                                  
#  1   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B131W124E An dieser Schule herrscht ein freundli…
#  2   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132a     Mein Sohn/meine Tochter fühlt sich an …
#  3   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132c     Die Räume der Schule bieten eine angen…
#  4   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B133b     Die Schule ist ein sicherer Ort.       
#  5   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125a An dieser Schule wird konsequent gegen…
#  6   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125b Wenn es Konflikte gibt, trägt die Schu…
#  7   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B333      Mein Sohn/meine Tochter lernt an diese…
#  8   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A632e     Mein Sohn/meine Tochter lernt in der S…
#  9   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A633e     Mein Sohn/meine Tochter erfährt in der…
# 10   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A631      Mein Sohn/meine Tochter lernt in der S…
# # ℹ 19 more rows
# # ℹ Use `print(n = ...)` to see more rows
# 
# [[4]]
# # A tibble: 29 × 5
#    surveyID template                             plot  variable  text                                   
#       <int> <chr>                                <chr> <chr>     <chr>                                  
#  1   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B131W124E An dieser Schule herrscht ein freundli…
#  2   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132a     Mein Sohn/meine Tochter fühlt sich an …
#  3   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B132c     Die Räume der Schule bieten eine angen…
#  4   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E01   B133b     Die Schule ist ein sicherer Ort.       
#  5   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125a An dieser Schule wird konsequent gegen…
#  6   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B334W125b Wenn es Konflikte gibt, trägt die Schu…
#  7   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E02   B333      Mein Sohn/meine Tochter lernt an diese…
#  8   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A632e     Mein Sohn/meine Tochter lernt in der S…
#  9   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A633e     Mein Sohn/meine Tochter erfährt in der…
# 10   197865 master_01_bfr_allg_gm_elt_00_2022_v4 E03   A631      Mein Sohn/meine Tochter lernt in der S…
# # ℹ 19 more rows
# # ℹ Use `print(n = ...)` to see more rows
# 
# [[5]]
# # A tibble: 38 × 5
#    surveyID template                             plot  variable  text                                   
#       <int> <chr>                                <chr> <chr>     <chr>                                  
#  1   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E01   B131W124E An dieser Schule herrscht ein freundli…
#  2   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E01   B132a     Mein Sohn/meine Tochter fühlt sich an …
#  3   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E01   B132c     Die Räume der Schule bieten eine angen…
#  4   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E01   B133b     Die Schule ist ein sicherer Ort.       
#  5   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E02   B334W125a An dieser Schule wird konsequent gegen…
#  6   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E02   B334W125b Wenn es Konflikte gibt, trägt die Schu…
#  7   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E02   B333      Mein Sohn/meine Tochter lernt an diese…
#  8   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E03   A632e     Mein Sohn/meine Tochter lernt in der S…
#  9   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E03   A633e     Mein Sohn/meine Tochter erfährt in der…
# 10   943467 master_02_bfr_allg_gm_elt_01_2022_v4 E03   A631      Mein Sohn/meine Tochter lernt in der S…
# # ℹ 28 more rows
# # ℹ Use `print(n = ...)` to see more rows
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
