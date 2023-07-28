

dashboardPage(
  dashboardHeader(title='Solar Power Potential'),
  dashboardSidebar(
    sidebarUserPanel("Charlotte Wolf"),
    selectInput(inputId = "state",
                   label = "State",
                   choices = c(unique(as.character(eGrid$Region)))
    ),
    selectInput(inputId = "type",
                label = "Choose energy type to display:",
                choices = c("total", "solar", "non-renewables", "renewables")
    ),
    selectInput(inputId = "year",
                label = "Year:", 
                choices = c(unique(as.character(eGrid$Year)))
    ),
    sidebarMenu(
      menuItem("Links", tabName = "links", icon = icon("chain"))
    ),
    a("EPA's eGrid Data", href="https://www.epa.gov/egrid/data-explorer"), br(),
    a("Berkeley Lab's - Tracking the Sun", href=" https://emp.lbl.gov/tracking-the-sun"), br(),
    a("GEI electricity price", href="https://www.globalenergyinstitute.org/average-electricity-retail-prices-map"), br(),
    a("Simple Maps, US Census Data", href="https://simplemaps.com/data/us-zips"), br(), br(), br(), br(),
    a("Charlotte Wolf - GitHub", href="https://github.com/lottiewolf/NYCDSA_Solar_Power")
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'links',
              p("Solar power and renewable energy are currently key areas of economic growth, 
                and this app helps to identify areas of potential market growth. The data in this 
                project comes from the Global Energy Institute's report on retail electricity 
                price, the US Census population data, Berkeley Lab's report Tracking the Sun, 
                and the EPA's data on electricity generated in the US by state.")
      )
    ),
    tabsetPanel(
      tabPanel("Potential", 
               selectInput(inputId = "gap_type",
                           label = "Potential Market Type",
                           choices = c("Gap between total and renewables",
                                       "Gap between total and solar",
                                       "Highest electricity cost", 
                                       "Largest population")
               ),
               fluidRow(
                 column(11, plotOutput("potential"))
               ), 
               fluidRow(
                 column(3, tableOutput("gap1table")),
                 column(3, tableOutput("gap2table")),
                 column(3, tableOutput("gap3table")),
                 column(3, tableOutput("gap4table"))
               )
      ),
      tabPanel("EPA's eGrid: Electricity Generated", 
               #helpText("Here are the plots by year"),
               fluidRow(
                 column(6, plotOutput("egrid_overview")),
                 column(6, plotOutput("egrid"))
               ),
               fluidRow(
                  column(11, dataTableOutput("egridtable"))
               )
      ),
      tabPanel("Data Overview",
               fluidRow(
                 column(6, plotOutput("plot_gei_price")),
                 column(6, plotOutput("plot_state_pop")),
                 column(6, plotOutput("plot_track_sun")),
                 column(6, plotOutput("plot_egrid_bystate"))
               )
      )
    )
  )
)
