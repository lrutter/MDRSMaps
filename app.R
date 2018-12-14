library(shiny)
library(shinycssloaders)
library(shinydashboard)
library(shinycssloaders)



options(spinner.color.background="#F5F5F5")




sidebar <- shinydashboard::dashboardSidebar(
width = 180,
hr(),
shinydashboard::sidebarMenu(id="tabs",
shinydashboard::menuItem("Application", tabName="mapPlot"),
shinydashboard::menuItem("About", tabName = "about", selected=TRUE)
)
)




body <- shinydashboard::dashboardBody(
shinydashboard::tabItems(
shinydashboard::tabItem(tabName = "mapPlot",
                        
                        
tags$style(HTML("

.box.box-solid.box-primary>.box-header {
color:#fff;
background:#222d32
}

.box.box-solid.box-primary{
border-bottom-color:#D3D3D3;
border-left-color:#D3D3D3;
border-right-color:#D3D3D3;
border-top-color:#D3D3D3;
background:#D3D3D3
}

")),                        
                        
                        
                        
                        
fluidRow(
column(width = 4, 

shinydashboard::box(width = NULL, status = "primary", title = "Plot metrics", solidHeader = TRUE,
# shiny::selectizeInput("selPair", "Treatment pairs:", choices = myPairs, multiple = TRUE, options = list(maxItems = 2)),
# shiny::selectInput("selOrder", "Metric order:", choices = c("Increasing", "Decreasing")),
# shiny::numericInput("binSize", "Hexagon size:", value = 10, min = 1),
fileInput('datafile', 'Choose CSV File',
accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')))),

column(width = 8,
shinydashboard::box(width = NULL, shinycssloaders::withSpinner(plotOutput("plotMap")), collapsible = FALSE, background = "black", title = "MDRS map with overlaid coordinates", status = "primary", solidHeader = TRUE))))))


ui <- shinydashboard::dashboardPage(skin = "red",
shinydashboard::dashboardHeader(title = "MDRS Map", titleWidth = 180),
sidebar,
body
)


server=function(input, output){

#This function is repsonsible for loading in the selected file
filedata <- reactive({
    infile <- input$datafile
    if (is.null(infile)) {
        # User has not uploaded a file yet
        return(NULL)
    }
    read.csv(infile$datapath)
})
    

output$plotMap <- renderPlot({

df <-filedata()
if (is.null(df)) return(NULL)

df <- as.data.frame(df)
df <- df[,1:ncol(df)]
df <- setNames(df, c("ID", "Latitude", "Longitude"))

register_google(key = "AIzaSyCcJu4DttxEDccaixZomOCXcUhptYHX2n4")
# Center on MDRS
island = get_map(location = c(lon = -110.7919, lat = 38.4065), zoom = 13, maptype = "satellite")

p <- ggmap(island, extent = "panel", legend = "bottomright") +
    geom_point(aes(x = Longitude, y = Latitude), data = df, size = 4, color = "#ff0000")
#+ scale_x_continuous(limits = c(minLon, maxLon), expand = c(0, 0)) +
#scale_y_continuous(limits = c(minLat, maxLat), expand = c(0, 0))

return(p)

})}

shinyApp(ui, server)