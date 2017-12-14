
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

#### Here, we define the structure of the different panel, add text and widgets

library(shiny)

shinyUI(
    navbarPage("Twitter Analysis",
               
               tabPanel("Load tweets / Word Cloud",
                        fluidPage(
                            sidebarLayout(
                                sidebarPanel(
                                    h4("Loading tweets"),
                                    p("The application enables to load tweets published either by EP_tribu, Izigloo or both user accounts."),
                                    selectInput("tweets", "Tweeter user account:", 
                                              choices = c('izigloo'='izigloo','EP'='EP', 'Both'='Both'), 
                                              selected = 'izigloo'),
                                    checkboxInput("remIzigloo", "Remove word 'izigloo' from analysis", FALSE),
                                  
                                    h4("Analysis"),
                                    p("The different panels of the applications provide insights on tweets. In this panel, you can observe the word cloud of the most popular terms and play with the parameters bellows."),
                                    sliderInput("freq",
                                                "Minimum Frequency:",
                                                min = 1,  max = 20, value = 5),
                                    sliderInput("max",
                                                "Maximum Number of Words:",
                                                min = 1,  max = 100,  value = 50)
                                ),
                                mainPanel(verbatimTextOutput("tweetCount"),
                                          plotOutput("plot"))
                            )
                        )),
               
               tabPanel("Time plot",
                        fluidPage(
                          sidebarLayout(

                            sidebarPanel(
                              p("Here is the number of tweets published accross time since 
                              user account creation."),
                              p("If you load both EP and Izigloo accounts, you will see that today 
                              EP publishes more than izigloo (the trend has reversed)."),
                              dateRangeInput("dates", "Date range:", start="2010-01-01", startview="year", format = "mm/yyyy")

                            ),
                          mainPanel(
                            h4("Number of tweets publised by month"),
                            plotOutput("timeplot"))
                        ))),
               
               
               tabPanel("Cluster analysis",
                        fluidPage(
                          sidebarLayout(
                            # Sidebar with a slider and selection inputs
                            sidebarPanel(
                              p("From the words contained in the tweets we are able to identify popular terms and associations between words."),
                              p(" The terms higher in the plot are more popular, and terms close to each other are more associated."),
                              p("You can play with the number of clusters obtained with the hierarchical clustering method."),
                                numericInput("nclust", "Number of clusters:", value = 2, max = 10)
                            ),
                            mainPanel(
                              h4("Cluster Dendrogram"),
                              plotOutput("cluster"))
                          ))),      
               
               tabPanel("Topic analysis",
                        fluidPage(
                          sidebarLayout(
                            # Sidebar with a slider and selection inputs
                            sidebarPanel(
                              p("Here, we will uncover the underlying topics in tweets using the LDA model."),
                              p("Choose the number of topics to be defined by the model."),
                              numericInput("ntopic", "Number of topics:", value = 2, max = 5),
                              p("The barplot beside shows the evolution of the topics accros time. Each topic is characterized by 4 terms.")
                            ),
                            mainPanel(
                              h4("Tweets repartition by topic accross time"),
                              plotOutput("topic"))
                          ))),               
               
               
               tabPanel("Tweets table",
                        fluidPage(
                          
                            mainPanel(
                              h4("Table containing all tweets loaded for the analysis."),
                              DT::dataTableOutput('tweet_table'))
                        ))
    )
)

