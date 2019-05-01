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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # Obtener las filas de datos Funcionario x Servicio,
  # 1ro se extrajo los datos para los parametros establecidos en los filtros
  # 2do se seleccionaron las columnas necesarias 
  # 3ro se pasa de formato largo a ancho,
  # (pivot la columna servicio y aplique la funcion suma a la columna varlor incoter ponderado)
  t_DxS <- reactive({
    Datos %>% 
    filter(Area == input$area, Año == input$anio , Mes == input$mes) %>% 
    select(Servicio,Funcionario,Incoterm_Ponderado) %>% 
    dcast(Funcionario ~ Servicio, fun.aggregate = sum, value.var = "Incoterm_Ponderado")
  })
  
  t_DxI <- reactive({
     Datos %>% 
      filter(Area == input$area, Año == input$anio , Mes == input$mes) %>% 
      select(Termino,Funcionario,Incoterm_Ponderado) %>% 
      dcast(Funcionario ~ Termino, fun.aggregate = sum, value.var = "Incoterm_Ponderado")
  })
  
  ##  Funcion para imprimir en la consola
  cat("Voy aquí")
 
  
  ##, Marca 1 ###
  ##########################
   #, Salida de la información
  
  output$tableDatos = renderDataTable(Datos)
  
  # Listar la información agrupada por Funcionario y Servico 
  output$tableServicio = renderDataTable(t_DxS()) 
  
  # Listar la información agrupada por Funcionario y Termino de negociación
  output$tableIncoterm = renderDataTable(t_DxI())
  
})
