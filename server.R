library(shiny)
library(shinyjs)
library(ggplot2)
library(shinycssloaders)
library(readr)
shinyServer(function(input, output) {
 
descriptiondataset <-read_csv("data/datadescription.csv")
      
 output$a <- DT::renderDataTable(descriptiondataset, filter = 'top', options = list(
        pageLength = 100, autoWidth = TRUE))
  
  data <- read_csv("data/merged1.csv")
  
  # Filter data based on selections
  output$table <-DT::renderDataTable(datatable(data, options = list(
    initComplete = JS(
      "function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#0E7DE3', 'color': '#fff'});",
      "}")
  ),
                                                rownames = FALSE,
                                                selection = 'none'
) %>%
                                        formatStyle('score_AMM',backgroundColor = 'orange',  color = styleInterval(c(4, 6), c('black', 'blue', 'red')),fontWeight = 'bold',
                                                    background = styleColorBar(data$score_AMM, 'lightblue'),
                                                    backgroundSize = '98% 88%',
                                                    backgroundRepeat = 'no-repeat',
                                                    backgroundPosition = 'center')
                                       
  )
      })
  
  


