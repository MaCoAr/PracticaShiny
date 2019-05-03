#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

#### Librerias a utilizar ####
library(shiny)
library(readxl)
library(dplyr)
library(reshape2)
library(ggplot2)

#### Datos globales ####
# Datos a utilzar en la practica
Datos <- read_excel("~/github/PracticaShiny/DatosPracticaShiny.xlsx", 
                    sheet = "Datos")

Limites <- read_excel("~/github/PracticaShiny/DatosPracticaShiny.xlsx", 
                    sheet = "Limites")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  ##### Obtención de Datos ####
  
  # Obtener las filas de datos Funcionario x Servicio,
  # 1ro se extrajo los datos para los parametros establecidos en los filtros
  # 2do se seleccionaron las columnas necesarias 
  # 3ro se pasa de formato largo a ancho,
  # (pivot la columna servicio y aplique la funcion suma a la columna varlor incoter ponderado)
  t_DxS <- reactive({
    DF_S <-  Datos %>% 
          filter(Area == input$area, Año == input$anio , Mes == input$mes) %>% 
          select(Servicio,Funcionario,Incoterm_Ponderado) %>% 
          dcast(Funcionario ~ Servicio, fun.aggregate = sum, value.var = "Incoterm_Ponderado")
    #Anexar nueva columna con la suma de las columnas valor por cada fila
    DF_S$Total <- rowSums(DF_S[,2:length(DF_S)])
    return(DF_S)
  })

  # Obtener las filas de datos Funcionario x Termino,
  # 1ro se extrajo los datos para los parametros establecidos en los filtros
  # 2do se seleccionaron las columnas necesarias 
  # 3ro se pasa de formato largo a ancho,
  # (pivot la columna termino y aplique la funcion suma a la columna varlor incoter ponderado)
  t_DxI <- reactive({
     DF_T <- Datos %>% 
            filter(Area == input$area, Año == input$anio , Mes == input$mes) %>% 
            select(Termino,Funcionario,Incoterm_Ponderado) %>% 
            dcast(Funcionario ~ Termino, fun.aggregate = sum, value.var = "Incoterm_Ponderado") 
    #Anexar nueva columna con la suma de las columnas valor por cada fila
     DF_T$Total <- rowSums(DF_T[,2:11])
     return(DF_T)
  })
  
  ##  Función para imprimir en la consola
  # cat("Voy aquí")

  #### Proceso reactivo para graficar los datos de eficacia ####
  Plot_Eficiencia <- reactive({
    # obtener los registros necesarios de la variable Datos
    Datos_Grafico <-  Datos %>% 
      select(Funcionario, Lider, Incoterm_Ponderado) %>% 
      filter(DatosPracticaShiny$Area == input$area, DatosPracticaShiny$Año == input$anio, DatosPracticaShiny$Mes == input$mes)
    
    # Agrupar los registros para sumar los valores por funcionario
    D_G <- Datos_Grafico %>% 
      group_by(Funcionario, Lider) %>% 
      mutate(Total = sum(Incoterm_Ponderado)) %>% 
      select(Funcionario, Lider, Total) %>% 
      ungroup() %>% 
      distinct()    
    
    # Extraer la información de los limites por area y año
    D_L <- filter(Limites,Area == input$area, Año == input$anio )    
    
    # Realizar el merge entre los datos y los limites
    df_new <- merge(D_G,D_L,by="Lider")

    # Area seleccionada
    m_Area <- switch(input$area, "P" = "Pricing", "C" = "Comercial", "O" = "Operaciones")
    
    # Información acmulada o mensaul
    m_Acumulado <- ifelse(input$chkDatosAcumulados,"Acumulado","Mensual")

    # Graficar
    plot_g <- ggplot(df_new) +
      geom_bar(aes(x=df_new$Funcionario, y=df_new$Total/3, fill=df_new$Funcionario), stat="identity", width = 0.25, alpha=0.5, show.legend = FALSE) + 
      geom_line(aes(x=df_new$Funcionario, y=df_new$Valor, group = df_new$Limite, colour = df_new$Limite), size = 0.8, show.legend = FALSE) +
      geom_text(aes(x=df_new$Funcionario, y=df_new$Total,label=df_new$Total), vjust=-0.5)+
      scale_fill_discrete(name="Funcionarios")+
      ylab("Solicitudes SPOT")+
      xlab("Funcionarios")+
      theme_bw()+
      ggtitle(paste("Indicador de Eficacia - ",m_Acumulado), subtitle = paste("TCC Carga - ",m_Area) )+
      geom_point(aes(x=df_new$Funcionario, y=df_new$Valor), col= "red") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    # Regresar la grafica
    return(plot_g)
  })  
  
  ##### Salida de la información ####
  # Listar la totalidad de la información
  output$tableDatos = renderDataTable(Datos)
  
  # Listar la información agrupada por Funcionario y Servico 
  output$tableServicio = renderDataTable(t_DxS()) 
  
  # Listar la información agrupada por Funcionario y Incoterm
  output$tableIncoterm = renderDataTable(t_DxI())
  
  # Grafica de eficacia por area
  output$plotEficacia = renderPlot(Plot_Eficiencia())
  
})
