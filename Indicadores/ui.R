#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(lubridate) 

#######################################################
# Inicio Definición de Variables
#######################################################
# vector con los años desde el 2019 hasta el año actual
vector_anios <- 2019:year(now())

# Listas
areas <- list("Pricing"="P","Comercial"="C","Operaciones"="O")
meses <- list("Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5, "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11,"Diciembre" = 12)

#######################################################
# Fin Definición de Variables
#######################################################

# Define UI for application that draws a histogram
shinyUI(
  pageWithSidebar(
  # Titlo de la aplicación
  headerPanel("Indicadores de Eficiencia y Eficacia", windowTitle = "Indicadores de Eficiencia y Eficacia"),
  
  # Crear panel del usuaria
  sidebarPanel(width = 3,
    h3("Filtros"),
    #Anexar los controles para los filtros
    selectInput(inputId = "area", label = "Seleccione un área", choices = areas),
    selectInput(inputId = "anio", label = "Seleccione un año", choices = vector_anios),
    selectInput(inputId = "mes", label = "Seleccione un mes", choices = meses),
    checkboxInput(inputId = "chkDatosAcumulados", label = "Datos acumulados", value = TRUE)
    
  ), # sidebarPanel
  
  mainPanel(
    tabsetPanel(
      tabPanel("Datos", dataTableOutput("tableDatos")),
      tabPanel("Operaciones x Servicio", dataTableOutput("tableServicio")),
      tabPanel("Operaciones x Incoterm", dataTableOutput("tableIncoterm")),
      tabPanel("Gráfico Eficacia", plotOutput("plotEficacia")),
      tabPanel("Gráfico Eficiencia", plotOutput("plotEficiencia"))
    )
  ) # main Panel
  ) # pageWithSidebar
) # Parantisis final
