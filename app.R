# app.R — Shiny App Nacimientos 2023

library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(DT)
library(plotly)

# ------------------------
# Cargar y limpiar datos del dataset
# ------------------------
nacimientos <- read_csv("nacimientos2023_limpio1.csv", show_col_types = FALSE) %>%
  rename_with(tolower) %>%   # nombres de columnas a minúsculas
  mutate(
    jurisdiccion = trimws(as.character(jurisdiccion)),
    sexo = trimws(tolower(as.character(sexo))),
    edad_grupo = trimws(as.character(edad_grupo)),
    nacimientos = as.numeric(nacimientos)
  ) %>%
  filter(sexo %in% c("masculino", "femenino")) %>%
  filter(!is.na(nacimientos) & nacimientos > 0)

# Re-etiquetar rangos de edad
nacimientos <- nacimientos %>%
  mutate(edad_grupo = case_when(
    edad_grupo %in% c("45 y más", "De 45 y más") ~ "45 y más",
    TRUE ~ edad_grupo
  ))

# Opciones desplegables
prov_choices <- sort(unique(nacimientos$jurisdiccion))
edad_choices <- sort(unique(nacimientos$edad_grupo))
edad_choices <- edad_choices[!is.na(edad_choices)]

# Colores pastel
colores_pastel <- c(
  "#F4B6C2", "#BFD7EA", "#FFDAC1", "#E2F0CB", 
  "#FFB7B2", "#C7CEEA", "#FFFACD", "#D5AAFF", "#A8E6CF"
)

# ------------------------
# UI
# ------------------------
ui <- fluidPage(
  titlePanel(HTML("<span style='font-weight:bold; font-size:130%;'>NACIDOS VIVOS REGISTRADOS EN LA REPÚBLICA ARGENTINA 2023</span>")),
  
  # Link a la fuente + introducción
  HTML("<p><b>Fuente de los datos:</b> 
       <a href='http://datos.salud.gob.ar/dataset/nacidos-vivos-registrados-por-jurisdiccion-de-residencia-de-la-madre-republica-argentina-ano/archivo/40e722b8-72eb-49a0-89dc-5ee174bf63b4' target='_blank'>
       Ministerio de Salud - Datos Abiertos</a></p>"),
  HTML("<p style='font-size:110%;'>Esta aplicación interactiva presenta información sobre nacidos vivos en Argentina durante el año 2023. 
       Permite analizar los nacimientos según el sexo, comparar entre jurisdicciones y observar la relación entre la edad de la madre y la jurisdicción.</p>"),
  
  tabsetPanel(
    tabPanel(
      title = HTML("<span style='font-weight:bold; font-size:115%;'>NACIMIENTOS POR SEXO</span>"),
      sidebarLayout(
        sidebarPanel(
          selectInput("provincia", "SELECCIONE UNA JURISDICCIÓN:", 
                      choices = c("Todas", prov_choices), selected = "Todas"),
          hr(),
          div("📌 En la siguiente gráfica se observa la distribución de nacimientos según el sexo (masculino/femenino), ya sea a nivel nacional o por jurisdicción.", 
              style="font-size:120%; color:#555; text-align:left;")
        ),
        mainPanel(
          plotlyOutput("grafico_sexo"),
          DTOutput("tabla_sexo")
        )
      )),
    
    tabPanel(
      title = HTML("<span style='font-weight:bold; font-size:115%;'>COMPARACIÓN ENTRE JURISDICCIONES</span>"),
      sidebarLayout(
        sidebarPanel(
          selectInput("comparar_provincias", "SELECCIONE JURISDICCIONES (SELECCIÓN MÚLTIPLE):",
                      choices = prov_choices,
                      selected = NULL,
                      multiple = TRUE),
          hr(),
          div("📌 En la siguiente gráfica se observa el total de nacimientos registrados en cada jurisdicción, lo que permite realizar comparaciones entre ellas.", 
              style="font-size:120%; color:#555; text-align:left;")
        ),
        mainPanel(
          plotlyOutput("grafico_provincias"),
          DTOutput("tabla_provincias")
        )
      )),
    
    tabPanel(
      title = HTML("<span style='font-weight:bold; font-size:115%;'>EDAD DE LA MADRE VS JURISDICCIONES</span>"),
      sidebarLayout(
        sidebarPanel(
          selectInput("edad_var", "SELECCIONE RANGO DE EDAD DE LA MADRE:",
                      choices = c("Todas", edad_choices), selected = "Todas"),
          helpText("⚠️ Este gráfico utiliza una escala logarítmica en el eje Y. 
                   Cada incremento representa una multiplicación (10, 100, 1000). 
                   Se usa para visualizar jurisdicciones con grandes diferencias en los nacimientos."),
          downloadButton("descargar_datos", "DESCARGAR DATOS"),
          hr(),
          div("📌 En la siguiente gráfica se observa cómo varían los nacimientos según el grupo de edad de la madre y la jurisdicción de residencia, representados en escala logarítmica.", 
              style="font-size:120%; color:#555; text-align:left;")
        ),
        mainPanel(
          plotlyOutput("grafico_edad", height = "700px", width = "100%"),
          DTOutput("tabla_edad")
        )
      ))
  )
)

# ------------------------
# SERVER
# ------------------------
server <- function(input, output, session) {
  
  datos_limpios <- reactive({ nacimientos })
  
  # ---- Gráfico 1 y tabla ----
  output$grafico_sexo <- renderPlotly({
    datos <- datos_limpios()
    if (input$provincia != "Todas") {
      datos <- datos %>% filter(jurisdiccion == input$provincia)
    }
    datos <- datos %>%
      group_by(sexo) %>%
      summarise(n = sum(nacimientos, na.rm = TRUE), .groups = "drop")
    
    p <- ggplot(datos, aes(x = sexo, y = n, fill = sexo, text = paste("Nacimientos:", n))) +
      geom_col(width = 0.6) +
      scale_x_discrete(labels = c("femenino"="Femenino","masculino"="Masculino")) +
      scale_fill_manual(values = c("femenino" = "#F4B6C2", "masculino" = "#BFD7EA"), guide = FALSE) +
      labs(
        title = ifelse(input$provincia == "Todas",
                       "Nacimientos por sexo — Todas las jurisdicciones",
                       paste("Nacimientos por sexo en", input$provincia)),
        x = "Sexo", y = "Cantidad de nacimientos"
      ) +
      theme_minimal(base_size = 14)
    
    ggplotly(p, tooltip = "text")
  })
  
  output$tabla_sexo <- renderDT({
    datos <- datos_limpios()
    if (input$provincia != "Todas") {
      datos <- datos %>% filter(jurisdiccion == input$provincia)
    }
    datos %>%
      group_by(Sexo = tools::toTitleCase(sexo)) %>%
      summarise(Nacimientos = sum(nacimientos, na.rm=TRUE), .groups="drop")
  })
  
  # ---- Gráfico 2 y tabla ----
  output$grafico_provincias <- renderPlotly({
    datos <- datos_limpios()
    if (!is.null(input$comparar_provincias) && length(input$comparar_provincias) > 0) {
      datos <- datos %>% filter(jurisdiccion %in% input$comparar_provincias)
    }
    datos <- datos %>%
      group_by(jurisdiccion) %>%
      summarise(Nacimientos = sum(nacimientos, na.rm=TRUE), .groups="drop") %>%
      arrange(desc(Nacimientos))
    
    p <- ggplot(datos, aes(x=reorder(jurisdiccion, -Nacimientos), y=Nacimientos,
                           text = paste("Nacimientos:", Nacimientos))) +
      geom_col(fill="#BFD7EA", width=0.7) +
      labs(title="Comparación de nacimientos entre jurisdicciones",
           x="Jurisdicción", y="Cantidad de nacimientos") +
      theme_minimal(base_size=12) +
      theme(axis.text.x=element_text(angle=45, hjust=1, size=9)) +
      scale_x_discrete(expand = expansion(mult = c(0.05, 0.1)))
    
    ggplotly(p, tooltip = "text")
  })
  
  output$tabla_provincias <- renderDT({
    datos <- datos_limpios()
    if (!is.null(input$comparar_provincias) && length(input$comparar_provincias) > 0) {
      datos <- datos %>% filter(jurisdiccion %in% input$comparar_provincias)
    }
    datos %>%
      group_by(Jurisdiccion = jurisdiccion) %>%
      summarise(Nacimientos = sum(nacimientos, na.rm=TRUE), .groups="drop") %>%
      arrange(desc(Nacimientos))
  })
  
  # ---- Gráfico 3 y tabla ----
  output$grafico_edad <- renderPlotly({
    datos <- datos_limpios()
    if (input$edad_var != "Todas") {
      datos <- datos %>% filter(edad_grupo == input$edad_var)
    }
    datos <- datos %>%
      group_by(jurisdiccion, edad_grupo) %>%
      summarise(Nacimientos = sum(nacimientos, na.rm=TRUE), .groups="drop")
    
    # Gráfico de dispersión con escala logarítmica en eje Y
    p <- ggplot(datos, aes(x = jurisdiccion, y = Nacimientos,
                           color = edad_grupo,
                           text = paste("Edad:", edad_grupo, "<br>Nacimientos:", Nacimientos))) +
      geom_point(size = 2.5, alpha = 0.7) +
      scale_color_manual(values = rep(colores_pastel, length.out = length(unique(datos$edad_grupo)))) +
      scale_y_log10() +
      labs(title = "Nacimientos por jurisdicción y grupo de edad (escala logarítmica)",
           x="Jurisdicción", y="Cantidad de nacimientos (log)", color="Grupo de edad") +
      theme_minimal(base_size=12) +
      theme(axis.text.x=element_text(angle=45, hjust=1, size=9)) +
      scale_x_discrete(expand = expansion(mult = c(0.05, 0.1)))
    
    ggplotly(p, tooltip = "text")
  })
  
  output$tabla_edad <- renderDT({
    datos <- datos_limpios()
    if (input$edad_var != "Todas") {
      datos <- datos %>% filter(edad_grupo == input$edad_var)
    }
    datos %>%
      group_by(Jurisdiccion = jurisdiccion, Edad = edad_grupo) %>%
      summarise(Nacimientos = sum(nacimientos, na.rm=TRUE), .groups="drop") %>%
      arrange(desc(Nacimientos))
  })
  
  # ---- Descargar datos ----
  output$descargar_datos <- downloadHandler(
    filename = function() {
      paste0("nacimientos_filtrados_", Sys.Date(), ".csv")
    },
    content = function(file) {
      datos <- datos_limpios()
      if (input$edad_var != "Todas") {
        datos <- datos %>% filter(edad_grupo == input$edad_var)
      }
      write_csv(datos, file)
    }
  )
}

# ------------------------
# Lanzar app
# ------------------------
shinyApp(ui, server)