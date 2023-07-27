

dashboardPage(
  dashboardHeader(title='Tracking the Sun'),
  dashboardSidebar(
    selectizeInput(inputId = "state",
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
    sidebarUserPanel("Charlotte Wolf",
                     image = "profile.jpg")
  ),
  dashboardBody(
    tabsetPanel(
      tabPanel("Potential", 
               fluidRow(
                 column(11, plotOutput("potential"))
               )
      ),
      tabPanel("Electricity Generated", 
               helpText("Here are the plots by year"),
               fluidRow(
                 column(6, plotOutput("egrid_overview")),
                 column(6, plotOutput("egrid"))
               ),
               fluidRow(
                  column(11, dataTableOutput("egridtable"))
               )
      ),
      tabPanel("View the Data",
               fluidRow(
                 column(6, plotOutput("plot_gei_price")),
                 column(6, plotOutput("plot_state_pop")),
                 column(6, plotOutput("track_sun_plot")),
                 column(6, plotOutput("egrid_bystate"))
               )
      )
    )
  )
)
