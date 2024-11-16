# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")
# df <- Limer_GetMaster(template = FALSE)





#' Get the Quesion from the Master File
#' @description This function gets the questions (plot, variable, text)
#'  from the master file.
#' @export


Limer_GetMasterQuesions <- function(id, name) {
  #Get specs from config
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential
  #Connect
  tmp.session <- surveyConnectLs(user = tmp.user,
                                 credential = tmp.credential,
                                 server = tmp.server)


  lslist <- call_limer(method = "list_questions",
                       params = list(iSurveyID = id))

  release_session_key()

  if (rlang::is_empty(lslist$status) == FALSE) {
    problem <- paste0("Error in get_MasterMeta(): ", lslist$status)
    cli::cli_abort(problem)
  }


  questiontypes <- unique(lslist$type)

  allowed_types <- c("!", "L", "F", "X", "M", "S", "T")

  # Check if any value in questiontypes is not in the allowed set
  invalid_values <- questiontypes[!questiontypes %in% allowed_types]

  # If there are any invalid values, abort with a custom message
  if (length(invalid_values) > 0) {
    cli::cli_abort(paste("Invalid value(s) found in questiontypes:",
                     paste(invalid_values, collapse = ", ")))
  }


  #drop boilerplate
  if ("X" %in% questiontypes) {
    lslist <- lslist |> dplyr::filter(type != "X")
  }





  #TYPE F OR M###########
  templateArray <- NULL



  if (any(questiontypes %in% c("F", "M"))) {
    lslistArray <- lslist |> dplyr::filter(type %in% c("F", "M"))



    df <- lslistArray |>
      dplyr::select(parent_qid, title)


    # Step 1: Extract plot titles (where parent_qid == 0)

    titles <- df |>
      dplyr::filter(parent_qid == 0) |>
      dplyr::mutate(row_number = dplyr::dense_rank(title)) |>
      dplyr::select(row_number, plot = title, parent = parent_qid)


    var_titles <- df |>
      dplyr::filter(parent_qid != 0) |>
      dplyr::mutate(row_number = dplyr::dense_rank(parent_qid)) |>
      dplyr::select(row_number, title, parentV = parent_qid)


    #Left join the two dataframes on row_number
    matched_variables <- titles |>
      dplyr::left_join(var_titles, by = "row_number")


    plot <- matched_variables$plot
    varname <- matched_variables$title


    question <- lslistArray |>
      dplyr::filter(parent_qid != "0") |>
      dplyr::pull(question)

    questions <- stringr::str_trim(question)

    templateArray <- tibble::tibble(surveyID = id,
                                    template = name,
                                    plot = plot,
                                    variable = varname,
                                    text = questions)
  }

  templateLRadio <- NULL
  if (any(questiontypes %in% c("!", "L", "S", "T"))) {
    #TYPE "!", "L", "S", "T"###########

    lslistLRadio <- lslist |> dplyr::filter(type %in% c("!", "L", "S", "T"))

    varname <- lslistLRadio$title
    plot <- substr(varname, 1, 3)
    varname <- substr(varname, 4, nchar(varname))

    questions <- lslistLRadio$question



    checkhtml <- is_html(questions[1])


    # q1 <- rvest::minimal_html(questions[1]) |>
    #   rvest::html_elements("span") |>
    #   rvest::html_elements("b") |>
    #   rvest::html_text2()

    #questions_rest <- questions[-1]

    q_rest <- purrr::map(questions, extract_html) |>
      purrr::flatten_chr()

    #q_rest <- q_rest[q_rest != " "]

    questions <- stringr::str_trim(q_rest)

    nquestions <- length(questions)
    nplots <- length(plot)

    if (nplots != nquestions) {
      questions <- "Reformat HTML Code"
    }


    templateLRadio <- tibble::tibble(surveyID = id,
                                     template = name,
                                     plot = plot,
                                     variable = varname,
                                     text = questions)
  }



  # Return the appropriate result, combining if both exist
  if (!is.null(templateArray) && !is.null(templateLRadio)) {
    df_return <- rbind(templateArray, templateLRadio)
  } else {
    # Return the one that exists or "Upps" if neither exists
    #df_return <- rlang::`%||%`(templateArray, templateLRadio)

    df_return <- rlang::`%||%`(templateArray, templateLRadio)
  }

  return(df_return)
}



#limer_NEW(id = df$sid[31], name = df$surveyls_title[31])

#purrr::map2(df$sid, df$surveyls_title, limer_NEW)



