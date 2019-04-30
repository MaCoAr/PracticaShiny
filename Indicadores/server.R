#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# Librerias a utilizar
library(shiny)
library(readxl)

# Datos a utilzar en la practica
library(readxl)
Datos <- read_excel("~/github/PracticaShiny/DatosPracticaShiny.xlsx", 
                    sheet = "Datos")

#cargar datos de la pratactica
file <- system.file("datos","DatosPracticaShiny.xlsx", package = "xlsx")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
output$tableServicio = renderDataTable({Datos})
  
})
