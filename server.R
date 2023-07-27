
#library(leaflet)
#install.packages(gdal-config)

shinyServer(function(input, output, session) {
  
  # Filter data based on selections
  output$egridtable <- renderDataTable(datatable({ 
    eGrid
  }))

  # flights_delay <- reactive({
  #   flights %>%
  #     filter(origin == input$state & dest == input$dest) %>%
  #     group_by(carrier) %>%
  #     summarise(n = n(),
  #               departure = mean(dep_delay),
  #               arrival = mean(arr_delay))
  # })

  # output$delay <- renderPlot(
  #   flights_delay() %>%
  #     gather(key = type, value = delay, departure, arrival) %>%
  #     ggplot(aes(x = carrier, y = delay, fill = type)) +
  #     geom_col(position = "dodge") +
  #     ggtitle("Average delay")
  # )
    
  output$potential <- renderPlot({
    df = eGrid %>%
      filter(Year==2021) %>%
      spread("Type", "Generation_Mwh") %>%
      left_join(state_pop, by=c('Region'='state')) %>%
      #mutate(gap=((total-solar)/state_pop)) %>%
      mutate(gap=total-solar) %>%
      rename(state=Region) #Rename column because the plot_usmap expects a column state or fips
    #   ggplot(aes(x = reorder(Region, -gap), y = gap)) +
    #   geom_col(fill = "lightblue") +
    #   labs(title="Difference between total and solar power generation (MWh) for 2021") +
    #   xlab("State") +
    #   ylab("MWh") +
    #   theme(axis.text.x = element_text(angle = 90))
    plot_usmap(data=df, values = "gap", labels=TRUE, color = "black", alpha=0.6) + 
      #geom_point(data = gei_price, aes(x = LONGITUDE, y = LATITUDE), color = "red") +
      scale_fill_continuous(high="darkgreen", low="white", name = "Population (2021)", label = scales::comma) + 
      theme(legend.position = "right")
  })
  
  output$egrid_overview <- renderPlot({
    eGrid %>%
      filter(Year==input$year) %>%
      ggplot(aes(x = Generation_Mwh, y = Type, fill=as.factor(Year))) +
      geom_density_ridges(color = "darkgreen", size = 2, alpha = 0.1, scale = 2, 
                          jittered_points = TRUE, quantile_lines = TRUE, scale = 0.9, alpha = 0.7,
                          vline_size = 1, vline_color = "red",
                          point_size = 0.4, point_alpha = 1,
                          position = position_raincloud(adjust_vlines = TRUE)) +
      labs(title=paste("generation (MWh) for ", input$year))
  })
  
  output$egrid <- renderPlot({
    eGrid %>%
      filter(Year==input$year & Type==input$type) %>%
      ggplot(aes(x = reorder(Region, -Generation_Mwh), y = Generation_Mwh)) +
      geom_col(fill = "lightblue") +
      labs(title=paste(input$type, " generation (MWh) for ", input$year)) +
      xlab("State") +
      ylab("MWh") +
      theme(axis.text.x = element_text(angle = 90))
  })
  
  output$plot_gei_price <- renderPlot({
    gei_price %>%
      mutate(highlight = ifelse(State == input$state, "1", "0")) %>%
      ggplot(aes(x = reorder(State, -Cents.per.kwh), y = Cents.per.kwh, fill=highlight)) + 
      geom_bar(stat="identity") +
      ggtitle("Average Retail Electricity Price (Cents per kilowatt hour) by state for 2021") +
      xlab("State") +
      ylab("Cents per kilowatt hour") +
      theme(axis.text.x = element_text(angle = 90)) +
      scale_fill_manual( values = c( "1"="darkgreen", "0"="lightblue" ),guide = FALSE )
  })
  
  output$plot_state_pop <- renderPlot({
    state_pop %>%
      ggplot(aes(x = reorder(state, -state_pop), y = state_pop)) +
      geom_col(fill = "lightblue") +
      labs(title="State population for US Census for 2021") +
      xlab("State") +
      ylab("Population") +
      theme(axis.text.x = element_text(angle = 90))
  })
  
  output$track_sun_plot <- renderPlot({
    #    flights_delay() %>%
    track_sun %>%
      ggplot(aes(x = reorder(state, -tot_capacity), y = tot_capacity)) +
      geom_col(fill = "lightblue") +
      labs(title="Amount of output (kw (DC)) by state") +
      xlab("state") +
      ylab("kw (DC)")
  })
  
  output$egrid_bystate <- renderPlot({
    eGrid %>%
      filter(Region==input$state & Year==input$year) %>%
      ggplot(aes(x = Type, y = Generation_Mwh)) +
      geom_col(fill = "lightblue") +
      labs(title=paste("Generation (MWh) by type for ", input$year)) +
      xlab(input$state) +
      ylab("MWh")
  })
  
})