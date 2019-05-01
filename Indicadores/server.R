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
library(dplyr)
library(reshape2)

# Datos a utilzar en la practica
Datos <- read_excel("~/github/PracticaShiny/DatosPracticaShiny.xlsx", 
                    sheet = "Datos")

DatosxServicio <- select(DatosPracticaShiny,Area,Año,Mes,Servicio,Funcionario,Incoterm_Ponderado)
DatosxIncoterm <- select(DatosPracticaShiny,Area,Año,Mes,Termino ,Funcionario,Incoterm_Ponderado)

# Convertir la información de formato largo a formato ancho 
# (pivot la columna servicio y aplique la funcion suma a la columna varlor incoter ponderado)
tmpDxS <- dcast(D_S, Area + Año + Mes + Funcionario ~ Servicio, fun.aggregate = sum, value.var = "Incoterm_Ponderado")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  # Obtener las variables del filtro

  t_DxS <- reactive({
    filter(tmpDxS, Area == input$area, Año == input$anio , Mes == input$mes)
  }) 
  
  output$tableDatos = renderDataTable(Datos, 
                                      options = list(aLengthMenu = c(5, 30, 50), iDisplayLength = 5))
  
  # Listar la información agrupada por servico 
  output$tableServicio = renderDataTable(t_DxS(),
                                         options = list(aLengthMenu = c(5, 10, 20, 50, 100), iDisplayLength = 5))  
  
})
