The goal of the MetaMaster package is to create meta data for LimeSurvey
which are reproducible, tested, and in consequence error-free. The
package provides functions to get the names of the master templates, the
data of the master template, and to create new surveys based on a
template.

<img src='images/logo.png' alt='Meta master - Edgar Treischl' align='center' width='325'/>

## Preparation steps

In order to use the package, you may wish to adjust the parameters for
the LimeSurvey API (user name, LimeSurvey instance, etc.). All
parameters that are necessary to retrieve data from a test or production
LimeSurvey instance are saved in the `config.yml` file. The next console
shows the default parameters for the test instance.

    default:
      tmp.server: "semiotikon"
      api_url: "http://www.semiotikon.de/lime2/index.php/admin/remotecontrol"
      tmp.user: "limeremote"
      tmp.credential: "IWBD3SnMfxcu"

To use the production parameters (OES server), set the `R_CONFIG_ACTIVE`
to `production`.

    Sys.setenv(R_CONFIG_ACTIVE = "production")

## Meta Master in Action

The `get_MasterTemplate()` function returns the name of master template
for a specific school type (e.g. `sart = 'gs'`). If the parameter `sart`
is missing, the function returns the all master templates.

    #Load the package
    library(MetaMaster)

    #Get master template for all school types
    mastertemplatesdf <- get_MasterTemplate()
    mastertemplatesdf
    #> # A tibble: 36 × 2
    #>    sid    surveyls_title                      
    #>    <chr>  <chr>                               
    #>  1 197865 master_01_bfr_allg_gm_elt_00_2022_v4
    #>  2 943467 master_02_bfr_allg_gm_elt_01_2022_v4
    #>  3 866667 master_03_bfr_allg_gm_leh_00_2022_v4
    #>  4 383484 master_04_bfr_allg_gs_elt_00_2022_v4
    #>  5 687118 master_05_bfr_allg_gs_elt_01_2022_v4
    #>  6 661758 master_06_bfr_allg_gs_leh_00_2022_v4
    #>  7 573979 master_07_bfr_allg_gs_sus_00_2022_v4
    #>  8 294498 master_08_bfr_allg_gs_sus_02_2022_v4
    #>  9 488727 master_09_bfr_allg_gy_elt_00_2022_v4
    #> 10 197211 master_10_bfr_allg_gy_elt_01_2022_v4
    #> # ℹ 26 more rows

The latter is used to retrieve the meta data for all master templates:
The `get_MasterMeta()` function returns the metadata for a specific
master template. As the next console underlines, it needs a `surveyID`
and `name` of the survey. The function returns variable names and text
from the LimeSurvey API.

    #Get metadata for a specific master template
    get_MasterMeta(id = "197865",
                   name = "master_01_bfr_allg_gm_elt_00_2022_v4")
    #> # A tibble: 29 × 4
    #>    surveyID template                             variable  var_text                              
    #>    <chr>    <chr>                                <chr>     <chr>                                 
    #>  1 197865   master_01_bfr_allg_gm_elt_00_2022_v4 B131W124E "An dieser Schule herrscht ein freund…
    #>  2 197865   master_01_bfr_allg_gm_elt_00_2022_v4 B132a     "Mein Sohn/meine Tochter fühlt sich a…
    #>  3 197865   master_01_bfr_allg_gm_elt_00_2022_v4 B132c     "Die Räume der Schule bieten eine ang…
    #>  4 197865   master_01_bfr_allg_gm_elt_00_2022_v4 B133b     "Die Schule ist ein sicherer Ort."    
    #>  5 197865   master_01_bfr_allg_gm_elt_00_2022_v4 B334W125a "An dieser Schule wird konsequent geg…
    #>  6 197865   master_01_bfr_allg_gm_elt_00_2022_v4 B334W125b "Wenn es Konflikte gibt, trägt die Sc…
    #>  7 197865   master_01_bfr_allg_gm_elt_00_2022_v4 B333      "Mein Sohn/meine Tochter lernt an die…
    #>  8 197865   master_01_bfr_allg_gm_elt_00_2022_v4 A632e     "Mein Sohn/meine Tochter lernt in der…
    #>  9 197865   master_01_bfr_allg_gm_elt_00_2022_v4 A633e     "Mein Sohn/meine Tochter erfährt in d…
    #> 10 197865   master_01_bfr_allg_gm_elt_00_2022_v4 A631      "Mein Sohn/meine Tochter lernt in der…
    #> # ℹ 19 more rows

The `get_AllMasterMeta()` is a wrapper function for `get_MasterMeta`
that returns the metadata for all master templates in LimeSurvey. With
the parameter `export = TRUE` the function exports the data as an Excel
file.

    #Get metadata for all master templates
    get_AllMasterMeta(export = TRUE)

This file is used to create the meta data for all master templates.
Based on the results from the `get_AllMasterMeta()` function, the
function merges all report templates from Giselas manual meta data and
append them to one file.

The function comes with the `overallreports` parameter to create
metadata that include also the meta data for the overall reports; and
the `export` parameter let you export the metadata as an Excel file.

Furthermore, the function informs you which report templates cannot be
merged with the master templates from LimeSurvey. These inconsistencies
need to be fixed manually.

    #Create metadata for all master templates
    metadata <- create_metadata(export = FALSE,
                    overallreports = TRUE)
    #> ✖ Some variables cannot be matched, check: rpt_elt_p1
    #> ✖ Some variables cannot be matched, check: rpt_elt_p2
    #> ✖ Some variables cannot be matched, check: rpt_leh_p1
    #> ✖ Some variables cannot be matched, check: rpt_leh_p2
    #> ✖ Some variables cannot be matched, check: rpt_leh_gs_p1
    #> ✖ Some variables cannot be matched, check: rpt_leh_gs_p2
    #> ✖ Some variables cannot be matched, check: rpt_sus_p1
    #> ✖ Some variables cannot be matched, check: rpt_sus_p2
    #> ✖ Some variables cannot be matched, check: rpt_sus_gm_p1
    #> ✖ Some variables cannot be matched, check: rpt_aus_bq_p1
    #> ✖ Some variables cannot be matched, check: rpt_elt_bq_p1
    #> ✖ Some variables cannot be matched, check: rpt_leh_bq_p1
    #> ✖ Some variables cannot be matched, check: rpt_sus_bq_p1
    #> ✖ Some variables cannot be matched, check: rpt_leh_fb_p1
    #> ✖ Some variables cannot be matched, check: rpt_sus_fb_p1
    #> ✖ Some variables cannot be matched, check: rpt_elt_fz_p1
    #> ✖ Some variables cannot be matched, check: rpt_elt_fz p2
    #> ✖ Some variables cannot be matched, check: rpt_leh_fz_p1
    #> ✖ Some variables cannot be matched, check: rpt_leh_fz_p2
    #> ✖ Some variables cannot be matched, check: rpt_ubb_gm_p1
    #> ✖ Some variables cannot be matched, check: rpt_ubb_gs_p1
    #> ✖ Some variables cannot be matched, check: rpt_ubb_ms_p1
    #> ✖ Some variables cannot be matched, check: rpt_ubb_p1
    #> ✖ Some variables cannot be matched, check: rpt_ubb_fb_p1
    #> ✖ Some variables cannot be matched, check: rpt_ubb_fz_p1
    #> ✔ All report templates are checked.

If a report template contains variables names that cannot be matched
with the manual meta data, the function only appends variables names
from LimeSurvey that cannot be matched. Thus, the result from
`create_metadata` shows templates without errors (all columns are
filled) and templates with errors (only variables names and text are
listed). For example, the last console showed that the template
`rpt_elt_p1` contains errors. The file shows which variables cannot be
matched.

    #The following variable names from LimeSurvey cant be matched: 
    metadata |> dplyr::filter(report_template == "rpt_elt_p1") 
    #> # A tibble: 4 × 6
    #>   report_template variable  var_text                                      plot  label_short sets 
    #>   <chr>           <chr>     <chr>                                         <chr> <chr>       <chr>
    #> 1 rpt_elt_p1      A632e     Mein Sohn/meine Tochter lernt in der Schule,… <NA>  <NA>        <NA> 
    #> 2 rpt_elt_p1      A633e     Mein Sohn/meine Tochter erfährt in der Schul… <NA>  <NA>        <NA> 
    #> 3 rpt_elt_p1      B112e     Über die Möglichkeiten der Mitsprache als El… <NA>  <NA>        <NA> 
    #> 4 rpt_elt_p1      D316W235e Der Informationsaustausch mit den Lehrkräfte… <NA>  <NA>        <NA>

## Problems Master to Template

Things to discuss with Gisela:

-   Odd master templates: `master_07_bfr_allg_gs_sus_00_2022_v4`,
    `master_08_bfr_allg_gs_sus_02_2022_v4`,
    `master_28_bfr_zspf_fz_sus_05_2022_v4`

<!-- -->

    #Probs
    #[1] "master_07_bfr_allg_gs_sus_00_2022_v4" "master_08_bfr_allg_gs_sus_02_2022_v4"
    # [3] "master_28_bfr_zspf_fz_sus_05_2022_v4"

### Odd HTML formating

    # q1 <- rvest::minimal_html(questions[1]) |> 
    #   rvest::html_elements("span") |> 
    #   rvest::html_elements("span") |> 
    #   rvest::html_elements("span") |> 
    #   rvest::html_elements("span") |> 
    #   rvest::html_text2()

## Sent via API

Finally, the package provides a function to create a new survey based on
a master template. The `send_survey()` function needs the path to the
master template and the name of the new survey.

    #Create a new survey
    send_survey(lss = "struktur_LimeSurvey.lss",
                name = "SurveyName")

## Further Helpers

In order to create PDF reports, we need to identify the survey and
report template based on school characteristics. The `get_metalist()`
function returns the names of all survey and report templates and
includes the school characteristics. The results are based on the
`masterToTemplates` file and not via the LimeSurvey API.

    #Inspect all master and report templates
    get_metalist()
    #> # A tibble: 75 × 7
    #>    master                               template                 report ubb   stype type  ganztag
    #>    <chr>                                <chr>                    <chr>  <chr> <chr> <chr> <chr>  
    #>  1 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_allg_gm_elt_00… rpt_e… FALSE gm    elt   FALSE  
    #>  2 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_allg_rs_elt_00… rpt_e… FALSE rs    elt   FALSE  
    #>  3 master_01_bfr_allg_gm_elt_00_2022_v4 tmpl_bfr_beru_ws_elt_00… rpt_e… FALSE beru… elt   FALSE  
    #>  4 master_02_bfr_allg_gm_elt_01_2022_v4 tmpl_bfr_allg_gm_elt_01… rpt_e… FALSE gm    elt   TRUE   
    #>  5 master_03_bfr_allg_gm_leh_00_2022_v4 tmpl_bfr_allg_gm_leh_00… rpt_l… FALSE gm    leh   FALSE  
    #>  6 master_03_bfr_allg_gm_leh_00_2022_v4 tmpl_bfr_allg_gm_leh_00… rpt_l… FALSE gm    leh   TRUE   
    #>  7 master_04_bfr_allg_gs_elt_00_2022_v4 tmpl_bfr_allg_gs_elt_00… rpt_e… FALSE gs    elt   FALSE  
    #>  8 master_05_bfr_allg_gs_elt_01_2022_v4 tmpl_bfr_allg_gs_elt_01… rpt_e… FALSE gs    elt   TRUE   
    #>  9 master_06_bfr_allg_gs_leh_00_2022_v4 tmpl_bfr_allg_gs_leh_00… rpt_l… FALSE gs    leh   FALSE  
    #> 10 master_06_bfr_allg_gs_leh_00_2022_v4 tmpl_bfr_allg_gs_leh_00… rpt_l… FALSE gs    leh   TRUE   
    #> # ℹ 65 more rows
