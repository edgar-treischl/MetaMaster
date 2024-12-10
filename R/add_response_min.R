# library(MetaMaster)
#
# library(tidyverse)
#
#
# df <- list(
#   id = 1,
#   lastpage = 1,
#   startlanguage = "de",
#   seed = 1453197542,
#   `1036621` = 1,
#   `1036622` = 1
# )
#
#
#
# #Get specs from config
# get <- config::get()
# tmp.server <- get$tmp.server
# tmp.user <- get$tmp.user
# tmp.credential <- get$tmp.credential
# #Connect
# tmp.session <- LS_Connect(user = tmp.user,
#                           credential = tmp.credential,
#                           server = tmp.server)
#
# #Get list of questions
# lslist <- LS_Ask(method = "add_response",
#                  params = list(iSurveyID = "515139",
#                                ResponseData = df))
#
#
# lslist
# #Disconnect
# LS_Release()
#
#
# #Real
# # library(dplyr)
# # library(tidyr)
# #
# #
# # # Example tibble (assuming you've already loaded it)
# # df <- tibble(
# #   id = 1,
# #   submitdate = as.POSIXct("1980-01-01 00:00:00"),
# #   lastpage = 6,
# #   startlanguage = "de",
# #   seed = 1441197542,
# #   `E01[B131W124E]` = 1,
# #   `E01[B132a]` = 1,
# #   `E01[B132c]` = 1,
# #   `E01[B133b]` = 1,
# #   `E02[B334W125a]` = 1,
# #   `E02[B334W125b]` = 1,
# #   `E02[B333]` = 1,
# #   `E03[A632e]` = 1,
# #   `E03[A633e]` = 1,
# #   `E03[A631]` = 1,
# #   `E04[C111b]` = 1,
# #   `E04[D311a]` = 1,
# #   `E04[D311b]` = 1,
# #   `E04[D312W153a]` = 1,
# #   `E04[D312W153b]` = 1,
# #   `E04[D313W154]` = 1,
# #   `E04[D315]` = 1,
# #   `E04[D316W235e]` = 1,
# #   `E04[D332]` = 1,
# #   `E05[B112e]` = 1,
# #   `E05[D314a]` = 1,
# #   `E05[D314b]` = 1,
# #   `Zuf[Z1E]` = 1,
# #   `Zuf[Z2E]` = 1,
# #   `Zuf[Z3E]` = 1,
# #   `Zuf[Z4E]` = 1,
# #   `Zuf[Z5E]` = 1,
# #   `Zuf[Z6E]` = 1,
# #   `Zuf[Z7E]` = 1
# # )
# #
# # # Replace square brackets in the column names with underscores
# # df_adjusted <- df %>%
# #   rename_with(~ gsub("\\[|\\]", "_", .)) %>%  # Replace '[' and ']' with '_'
# #   rename_with(~ gsub("_$", "", .))  # Remove trailing underscores (if any)
# #
# # # Prepare the survey response data by removing non-question columns
# #
# #
# #
# # prepared_data <- df_adjusted |> as.list()
# #
# #
# # # Check the adjusted column names
# # colnames(adjusted_df)
# #
# # # Check the structure of the prepared data
# # str(prepared_data)  # This should be a
