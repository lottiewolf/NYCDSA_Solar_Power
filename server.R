
shinyServer(function(input, output, session) {
  
  #This plot is of the US map
  output$potential <- renderPlot({
    if(input$gap_type=="Gap between total and renewables"){
      df = eGrid %>%
        filter(Year==2021) %>%
        spread("Type", "Generation_Mwh") %>%
        mutate(gap=total-renewables) %>%
        rename(state=Region) #Rename column because the plot_usmap expects a column state or fips
    }
    if(input$gap_type=="Gap between total and solar"){
      df = eGrid %>%
        filter(Year==2021) %>%
        spread("Type", "Generation_Mwh") %>%
        #left_join(state_pop, by=c('Region'='state')) %>%
        #mutate(gap=((total-solar)/state_pop)) %>%
        mutate(gap=total-solar) %>%
        rename(state=Region) #Rename column because the plot_usmap expects a column state or fips
    }
    if(input$gap_type=="High electricity cost"){
      df = gei_price %>%
        rename("gap"="Cents_per_kwh") %>%
        rename(state=State) #Rename column because the plot_usmap expects a column state or fips
    }
    if(input$gap_type=="Largest population"){
      df = state_pop %>%
        rename("gap"="state_pop")
    }
    plot_usmap(data=df, values = "gap", labels=TRUE, color = "black", alpha=1) + 
      scale_fill_continuous(high="darkgreen", low="white", name = "Top States-2021", label = scales::comma) + 
      theme(legend.position = "right")
  })
  
  #These are the tables below the map
  output$gap1table <- renderTable({ 
    df_renew_gap = eGrid %>%
      filter(Year==2021) %>%
      spread("Type", "Generation_Mwh") %>%
      mutate(total_renew_energy_gap=total-renewables) %>%
      select(Region, total_renew_energy_gap) %>%
      arrange(desc(total_renew_energy_gap))
    head(df_renew_gap, 10)
  })
  output$gap2table <- renderTable({ 
    df_solar_gap = eGrid %>%
      filter(Year==2021) %>%
      spread("Type", "Generation_Mwh") %>%
      mutate(total_solar_energy_gap=total-solar) %>%
      select(Region, total_solar_energy_gap) %>%
      arrange(desc(total_solar_energy_gap))
    head(df_solar_gap, 10)
  })
  output$gap3table <- renderTable({ 
    gei_price = gei_price %>%
      arrange(desc(Cents_per_kwh))
    head(gei_price, 10)
  })
  output$gap4table <- renderTable({
    state_pop = state_pop %>%
      arrange(desc(state_pop))
    head(state_pop, 10)
  })
  
  #Second tab, first plot
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
  
  #Second tab, second plot
  output$egrid <- renderPlot({
    eGrid %>%
      filter(Year==input$year & Type==input$type) %>%
      mutate(highlight = ifelse(Region == input$state, "1", "0")) %>%
      ggplot(aes(x = reorder(Region, -Generation_Mwh), y = Generation_Mwh, fill=highlight)) +
      geom_bar(stat="identity") +
      ggtitle(paste(input$type, " generation (MWh) for ", input$year)) +
      xlab("State") +
      ylab("MWh") +
      theme(axis.text.x = element_text(angle = 90)) +
      scale_fill_manual( values = c( "1"="darkgreen", "0"="lightblue" ),guide = FALSE )
  })
  
  #Second tab, table below
  output$egridtable <- renderDataTable(datatable({ 
    eGrid
  }))
  
  #Third tab, data viewer 
  output$plot_gei_price <- renderPlot({
    gei_price %>%
      mutate(highlight = ifelse(State == input$state, "1", "0")) %>%
      ggplot(aes(x = reorder(State, -Cents_per_kwh), y = Cents_per_kwh, fill=highlight)) + 
      geom_bar(stat="identity") +
      ggtitle("GEI Retail Electricity Price (Cents per kilowatt hour) by state for 2021") +
      xlab("State") +
      ylab("Cents per kilowatt hour") +
      theme(axis.text.x = element_text(angle = 90)) +
      scale_fill_manual( values = c( "1"="darkgreen", "0"="lightblue" ),guide = FALSE )
  })
  
  output$plot_state_pop <- renderPlot({
    state_pop %>%
      mutate(highlight = ifelse(state == input$state, "1", "0")) %>%
      ggplot(aes(x = reorder(state, -state_pop), y = state_pop, fill=highlight)) +
      geom_bar(stat="identity") +
      ggtitle("State population from US Census for 2021") +
      xlab("State") +
      ylab("Population") +
      theme(axis.text.x = element_text(angle = 90)) +
      scale_fill_manual( values = c( "1"="darkgreen", "0"="lightblue" ),guide = FALSE )
  })
  
  output$plot_track_sun <- renderPlot({
    track_sun %>%
      left_join(state_pop, by=c('state'='state_id')) %>%
      rename(state_name=state.y) %>%
      mutate(highlight = ifelse(state_name == input$state, "1", "0")) %>%
      ggplot(aes(x = reorder(state_name, -tot_capacity), y = tot_capacity, fill=highlight)) +
      geom_bar(stat="identity") +
      ggtitle("Tracking the Sun: Amount of electrical output (kw (DC)) at peak sun by state") +
      xlab("State") +
      ylab("Kw (DC)") +
      theme(axis.text.x = element_text(angle = 90)) +
      scale_fill_manual( values = c( "1"="darkgreen", "0"="lightblue" ),guide = FALSE )
  })
  
  output$plot_egrid_bystate <- renderPlot({
    eGrid %>%
      filter(Region==input$state & Year==input$year) %>%
      ggplot(aes(x = Type, y = Generation_Mwh)) +
      geom_col(fill = "lightblue") +
      labs(title=paste("eGrid Electricity Generation (MWh) by type for", input$year)) +
      xlab(input$state) +
      ylab("MWh")
  })
  
})