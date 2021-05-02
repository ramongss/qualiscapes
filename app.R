# devtools::load_all()

load("data/qualiscapes.rda")

library(DT)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinydashboard)
library(magrittr, include.only = "%>%")

da_qualis <- qualiscapes %>%
  dplyr::rename(issn = ISSN_2019,
                titulo = TITULO_2019,
                estrato = ESTRATO_2019)

ui <- fluidPage(theme = shinytheme("cerulean"),
                titlePanel(
                  fluidRow(
                    column(9, "Pesquisa de Periódicos"),
                    column(3, actionButton("github",
                                           label = "Código",
                                           icon = icon("github"),
                                           width = "100px",
                                           onclick ="window.open(`https://github.com/beatrizmilz/QualisCAPES/blob/master/app.R`, '_blank')",
                                           style="float:right"))
                  ),
                  windowTitle = "Pesquisa de Periódicos"
                ),
                hr(),
                sidebarPanel(
                  shinyjs::useShinyjs(),
                  div(
                      id = "form",
                       selectizeInput(
                         inputId = "issn_i",
                         label = "Selecione e/ou digite o(s) número(s) de ISSN",
                         # choices =  sort(unique(da_qualis$issn)),
                         choices = NULL,
                         multiple = TRUE,
                         selected = FALSE
                       ),
                      #
                       selectizeInput(
                         inputId = "titulo_i",
                         label = "Selecione e/ou digite o(s) Título(s) do(s) Períodico(s)",
                         # choices =  sort(unique(da_qualis$titulo)),
                         choices = NULL,
                         multiple = TRUE,
                         selected = FALSE
                       ),
                      #
                       sliderTextInput(
                         inputId = "estrato_i",
                         label = "Escolha a classificação no Periódicos CAPES",
                         choices = sort(unique(da_qualis$estrato)),
                         selected = c("A1", "NP"),
                         grid = TRUE
                       )
                  ),
                  actionButton("resetAll", "Limpar entradas")
                ),
                mainPanel(
                  # Adiciona a tabela
                  h3("Qualis CAPES 2019"),
                  DTOutput("tabela_periodicos"),
                  hr(),
                  p(br("Desenvolvido por",
                       tags$a(href = "https://ramongss.github.io", "Ramon G. da Silva"),
                       "usando o pacote",
                       tags$a(href = "https://github.com/ramongss/qualiscapes", "{qualiscapes},"),
                       "RStudio e Shiny App."),
                    style="text-align:center")
                )
              )

server <- function(input, output,session) {

  filtered_data <- reactive({

    da_qualis2 <- da_qualis %>%
      {if (!is.null(input$issn_i)) dplyr::filter(da_qualis, issn %in% input$issn_i) else .} %>%
      {if (!is.null(input$titulo_i)) dplyr::filter(da_qualis, titulo %in% input$titulo_i) else .} %>%
      dplyr::filter(as.character(estrato) >= as.character(input$estrato_i[1]),
                    as.character(estrato) <= as.character(input$estrato_i[2])) %>%
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

  updateSelectizeInput(
    inputId = "issn_i",
    label = "Selecione e/ou digite o(s) número(s) de ISSN",
    choices =  sort(unique(da_qualis$issn)),
    server = TRUE
  )

  updateSelectizeInput(
    inputId = "titulo_i",
    label = "Selecione e/ou digite o(s) Título(s) do(s) Períodico(s)",
    choices =  sort(unique(da_qualis$titulo)),
    server = TRUE
  )

  observeEvent(input$resetAll, {
    shinyjs::reset("form")
    updateSliderTextInput(session, 'estrato_i', selected = c("A1", "NP"))
  }
  )

}

shinyApp(ui, server)
