source("data.R")


ui <- navbarPage("Home Values",
  theme = shinytheme("sandstone"),
  # PLOT AND TABLE TAB
  tabPanel("Plot and Table",
    sidebarLayout(
      sidebarPanel(
        selectInput("bedrooms", "No. of Bedrooms", choices=unique(homeValueLong$Bedrooms), selected = "Two"),
        selectizeInput("state", "Select a state", choices=sort(unique(homeValueLong$State))),
        selectizeInput("county", "Select a county", choices=sort(unique(homeValueLong$RegionName)))

      ),
      mainPanel(
          plotOutput("plot"),
          DT::DTOutput("table")
      )
    )
  ),
  # MAP TAB
  tabPanel("Map",
    sidebarLayout(
      sidebarPanel(
        sliderInput("date",
                    "Year:",
                    min = min(year(homeValueLong$Date)),
                    max = max(year(homeValueLong$Date)),
                    value=2016,
                    sep=""),
        selectInput("map_bedrooms", "No. of Bedrooms", choices=unique(homeValueLong$Bedrooms), selected = "Two")
      ),
      mainPanel(
        tags$b(textOutput("mapTitle")),
        leafletOutput("map")
      )
    )
  ),
  # ABOUT THE DATA TAB
  tabPanel("About the Data",
           tags$div(
             tags$a(href="https://www.zillow.com/research/data/", "The data come from Zillow's Home Value Index."),
             tags$p("This index measures monthly changes in Zestimates, which is Zillow's estimate of a home's market value. This takes into account market
                    conditions, location, and various home facts."),
             tags$h4("The Data"),
             tags$ul(
               tags$li("Bedrooms: The number of bedrooms that the home has. Values range from 1-4, or 5+."),
               tags$li("RegionName: The US county name."),
               tags$li("State: The US state abbreviation."),
               tags$li("Metro: The metropolitian area that the region is in."),
               tags$li("FIPS: The Federal Information Processing Standards code that uniquely identifies counties in the United States. 
                       This is used to map the Zillow data to the spatial data."),
               tags$li("Date: The date of the home valuation."),
               tags$li("HomeValue: The value in USD of the home.")
             ),
             tags$a(href="https://github.umn.edu/brow4261/home_values_app", "Source code can be found on Github."))
            )
)

server <- function(input, output, session){
  
  # CHANGES COUNTY INPUT OPTIONS BASED ON SELECTED STATE
  countyOptions <- reactive({
    homeValueLong %>%
      filter(State == input$state) %>%
      pull(RegionName)
  })
  observe({
    updateSelectizeInput(session, "county", choices=countyOptions())
  })
  
  # FILTERS DATA BASED ON SELECTED STATE AND HOME SIZE - FOR PLOT AND TABLE ONLY
  selected <- reactive({
    homeValueLong %>%
      filter(State == input$state, Bedrooms == input$bedrooms)
    })
   selectedCounty <- reactive({
     selected() %>% filter(RegionName == input$county)
   })

  # TABLE OF FILTERED DATA
  output$table <- DT::renderDT({
    selected()
    })
  
  # LINE GRAPH OF HOME VALUE OVER TIME, SELECTED COUNTY IN RED, OTHER COUNTIES IN STATE IN GREY
  output$plot <- renderPlot({
    ggplot() +
      geom_line(aes(x=Date, y=HomeValue, group=RegionName), data=selected(), col="grey", alpha=0.75) +
      geom_line(aes(x=Date, y=HomeValue), data=selectedCounty(), col="red") +
      theme_minimal() + xlab("Year") + ylab("Home Value Index (USD)") +
      scale_y_continuous(labels = comma)
  })
  
  # FILTERS DATA BASED ON HOME SIZE AND YEAR SELECTED
  mapSelection <- reactive({
    temp <- homeValueLong %>%
      filter(Bedrooms == input$map_bedrooms, year(Date) == input$date, month(Date) == 12)
    merge(countyData, temp, by.x="GEOID", by.y="FIPS")
  })
  
  # MAP TITLE
  output$mapTitle <- renderText({
    paste0("Average Home Value of a ", input$map_bedrooms, " Bedroom House in ", input$date, ".")
  })
  
  # INTERACTIVE MAP
  output$map <- renderLeaflet({
    # COLOR PALETTE
    cols <- colorBin(
      palette="BuPu",
      domain = mapSelection()@data[["HomeValue"]],
      bins=c(0, 50000, 100000, 200000, 500000, 10000000)
    )
    # MAP
    leaflet() %>%
      addTiles() %>%
      addPolygons(data=mapSelection(),
                  fillColor = ~cols(HomeValue),
                  fillOpacity = 0.75,
                  weight=0.25,
                  label=paste0(mapSelection()@data[["NAME"]], ": $", 
                              mapSelection()@data[["HomeValue"]]),
                  highlight = highlightOptions(color="red",
                                               bringToFront=TRUE,
                                               weight=1)) %>%
      addLegend(pal = cols, values = countyData$HomeValue, opacity = 1, title="USD") %>%
      setView(lng = -98.583, lat = 39.833, zoom = 3)
  })
}

shinyApp(ui = ui, server = server)