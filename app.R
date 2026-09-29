# library(shiny2docker)
library(shiny)
library(shinychat)

ui <- page_chat(
  "Assistant",
  toolbar = actionButton("clear_chat", "Clear conversation"),
  toolbar_global = bslib::toolbar(
    bslib::input_dark_mode(),
    actionButton("help", "Help")
  ),
  sidebar = chat_sidebar(tags$p("Tools"), history = FALSE),
  pages_navbar = list(
    chat_nav_panel(
      "About",
      tags$p("About this app."),
      value = "about",
    ),
    chat_nav_panel(
      "Settings",
      tags$p("Settings"),
      toolbar = actionButton("save_settings", "Save settings")
    )
  ),
  drawer = chat_drawer(tags$p("Preview content"), title = "Preview")
)

server <- function(input, output, session) {
  chat <- 
    ellmer::chat_openai(
      system_prompt = "Respond to the user as succinctly as possible in French."
    )
  
  observeEvent(input$chat_user_input, {
    message <- input$chat_user_input[[1]]
    stream <- chat$stream_async(message)
    chat_append("chat", stream)
  })
}

shinyApp(ui, server)