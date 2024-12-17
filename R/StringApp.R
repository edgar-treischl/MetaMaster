# library(shiny)
# library(bslib)
# library(rvest)
#
# # Helper function to extract text from HTML
# extract_from_html <- function(html_text) {
#   tryCatch({
#     # Parse HTML and extract text
#     text <- html_text |>
#       read_html() |>
#       html_text2()
#     return(text)
#   }, error = function(e) {
#     return(paste("Error parsing HTML:", e$message))
#   })
# }
#
# # Helper function to extract first sentence with step tracking
# process_text_with_steps <- function(text) {
#   if (is.null(text) || text == "") return(list(result = "", steps = "❌ No text entered"))
#
#   steps <- character(0)
#   original <- text
#   steps <- c(steps, "📝 Input text:")
#   steps <- c(steps, paste("   ", original))
#
#   # Step 1: Normalize spaces
#   text <- gsub("\\s+", " ", text)
#   if (text != original) {
#     steps <- c(steps, "🔄 Normalizing spaces...")
#     steps <- c(steps, paste("   ", text))
#   }
#
#   # Step 2: Remove parentheses
#   text_no_parens <- gsub("\\([^)]*\\)", "", text)
#   if (text_no_parens != text) {
#     steps <- c(steps, "🗑️  Removing parentheses...")
#     steps <- c(steps, paste("   ", text_no_parens))
#   }
#   text <- text_no_parens
#
#   # Step 3: Handle special case or extract first sentence
#   steps <- c(steps, "✂️  Extracting first sentence...")
#
#   # Remove quotes if they exist at the start and end
#   text <- gsub('^"(.*)"$', "\\1", text)
#
#   # Check if text starts with actual dots (not quotes)
#   if (grepl("^\\.\\.+", text)) {
#     steps <- c(steps, "   → Text starts with dots, keeping full text")
#     final_result <- trimws(text)
#   } else {
#     pattern <- "\\.\\.\\.|[.!?]"
#     matches <- gregexpr(pattern, text)[[1]]
#
#     if (length(matches) > 0 && matches[1] > 0) {
#       end_pos <- matches[1]
#       match_length <- attr(matches, "match.length")[1]
#       result <- substr(text, 1, end_pos + match_length - 1)
#       result <- trimws(gsub("\\s+", " ", result))
#       steps <- c(steps, "   → Found sentence ending")
#       final_result <- result
#     } else {
#       steps <- c(steps, "   → No sentence ending found")
#       final_result <- trimws(gsub("\\s+", " ", text))
#     }
#   }
#
#   steps <- c(steps, "✨ Final result:")
#   steps <- c(steps, paste("   ", final_result))
#
#   list(result = final_result, steps = steps)
# }
#
# ui <- page(
#   title = "German Text Processor",
#   theme = bs_theme(version = 5),
#
#   navset_card_tab(
#     nav_panel(
#       title = "Plain Text",
#       layout_column_wrap(
#         width = 1,
#         card(
#           card_header("Enter Text"),
#           card_body(
#             textAreaInput("text_input",
#                           "Enter German text:",
#                           value = '"Hallo Welt. Here another sentence"',
#                           rows = 5,
#                           width = "100%",
#                           placeholder = "Enter text here...")
#           )
#         ),
#         card(
#           card_header("Processing Steps"),
#           card_body(
#             pre(
#               style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; font-family: 'Consolas', monospace;",
#               verbatimTextOutput("processing_steps")
#             )
#           )
#         )
#       )
#     ),
#
#     nav_panel(
#       title = "HTML Text",
#       layout_column_wrap(
#         width = 1,
#         card(
#           card_header("Enter HTML"),
#           card_body(
#             textAreaInput("html_input",
#                           "Enter HTML text:",
#                           rows = 5,
#                           width = "100%",
#                           placeholder = "<p>Enter HTML here...</p>")
#           )
#         ),
#         card(
#           card_header("Processing Steps"),
#           card_body(
#             pre(
#               style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; font-family: 'Consolas', monospace;",
#               verbatimTextOutput("html_processing_steps")
#             )
#           )
#         )
#       )
#     )
#   )
# )
#
# server <- function(input, output) {
#   # Process plain text
#   processed <- reactive({
#     process_text_with_steps(input$text_input)
#   })
#
#   output$processing_steps <- renderText({
#     result <- processed()
#     paste(result$steps, collapse = "\n")
#   })
#
#   # Process HTML text
#   processed_html <- reactive({
#     if (is.null(input$html_input) || input$html_input == "") {
#       return(list(result = "", steps = "❌ No HTML entered"))
#     }
#
#     steps <- character(0)
#     steps <- c(steps, "📝 Input HTML:")
#     steps <- c(steps, paste("   ", input$html_input))
#
#     # Extract text from HTML
#     steps <- c(steps, "🔍 Extracting text from HTML...")
#     extracted_text <- extract_from_html(input$html_input)
#     steps <- c(steps, paste("   ", extracted_text))
#
#     # Process the extracted text
#     text_processing <- process_text_with_steps(extracted_text)
#
#     # Combine steps
#     c(steps, text_processing$steps[-1]) # Remove duplicate "Input text" line
#   })
#
#   output$html_processing_steps <- renderText({
#     paste(processed_html(), collapse = "\n")
#   })
# }
#
# shinyApp(ui, server)
