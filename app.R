devtools::load_all()

library(DT)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinydashboard)
library(magrittr, include.only = "%>%")

da_qualis <- get_qualis(file = NULL) %>%
  dplyr::rename(issn = ISSN_2019,
                titulo = TITULO_2019,
                estrato = ESTRATO_2019)

ui <- fluidPage(theme = shinytheme("cerulean"),
                titlePanel("Pesquisa de Periódicos - 2019 Qualis CAPES"),
                  sidebarPanel(
                         selectizeInput(
                           inputId = "issn_i",
                           label = "Selecione e/ou digite o(s) número(s) de ISSN",
                           choices =  sort(unique(da_qualis$issn)),
                           multiple = TRUE,
                           selected = FALSE
                         ),

                         selectizeInput(
                           inputId = "titulo_i",
                           label = "Selecione e/ou digite o(s) Título(s) do(s) Períodico(s)",
                           choices =  sort(unique(da_qualis$titulo)),
                           multiple = TRUE,
                           selected = FALSE
                         ),

                         sliderTextInput(
                           inputId = "estrato_i",
                           label = "Escolha a classificação no Periódicos CAPES",
                           choices = sort(unique(da_qualis$estrato)),
                           selected = c("A1", "NP"),
                           grid = TRUE
                         )
                  ),
                mainPanel(
                  # Adiciona a tabela
                  DTOutput("tabela_periodicos")
                )
)

server <- function(input, output) {

  filtered_data <- reactive({

    req(input$estrato_i)

    da_qualis2 <- da_qualis %>%
      dplyr::filter(as.character(estrato) >= as.character(input$estrato_i[1]),
                    as.character(estrato) <= as.character(input$estrato_i[2])) %>%
      {if (!is.null(input$issn_i)) dplyr::filter(da_qualis, issn %in% input$issn_i) else .} %>%
      {if (!is.null(input$titulo_i)) dplyr::filter(da_qualis, titulo %in% input$titulo_i) else .} %>%
      dplyr::arrange(estrato)

    da_qualis2

  })

  output$tabela_periodicos <- renderDT({
    filtered_data()  %>%
      dplyr::rename(ISSN = issn,
                    `Título do Periódico` = titulo,
                    `Estrato CAPES` = estrato
      )

  } , escape = FALSE)

}


shinyApp(ui, server)
