
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

function(input, output, session) {
  
    #### Getting tweets
    tweets <- reactive({
        x <- get(input$tweets)
    })
    
    #### Getting text data from tweets
    textdata <- reactive({
        tweets <- tweets()
        #Define stopwords list
        stopwordList <- c(stopwords("french"),"a","si","comme","chez", "gt", "tres","cest","detre","ux",'tant','amp')
        if(input$remIzigloo){
          stopwordList <- c(stopwordList,"izigloo")
        }
        getTextData(tweets,stopwordList)
    })
    
    #### Count tweets
    output$tweetCount  <- renderText({
      tweets <- tweets()
      paste("Number of Tweets Found: ", as.character(nrow(tweets)))
    })
    
    #### Build wordcloud
    wordcloud_rep <- repeatable(wordcloud)
    output$plot <- renderPlot({
        wordcloud_rep(textdata(), scale=c(10,0.5),
                      min.freq = input$freq, max.words=input$max,
                      colors=brewer.pal(8, "RdBu"), random.order=F, 
                      rot.per=0.1, use.r.layout=F)
    })
    
    #### Create timeplot
    output$timeplot <-renderPlot({
      tweets <- tweets()
      #Select the right time period
      tweets <- tweets[(tweets$day >= input$dates[1]) & (tweets$day <= input$dates[2]),]
      
      tweets %>% 
        group_by(month,screenName) %>% 
        summarise(n=n_distinct(text)) %>%
        ggplot(., aes(x=month, fill=screenName, y=n )) +
        geom_bar(stat='identity') +
        labs(title="", y ="Number of tweets", x = "") +
        theme_classic() +
        scale_fill_discrete(name = "Twitter account") +
        theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 45, hjust = 1))
    })
    
    #### Cluster analysis
    output$cluster <-renderPlot({
      tweets <- tweets()
      tdm <- TermDocumentMatrix(textdata(), control = list(wordLengths = c(1, Inf)))
      tdm2 <- removeSparseTerms(tdm, sparse = 0.95)
      m2 <- as.matrix(tdm2)
      # cluster terms
      distMatrix <- dist(scale(m2))
      fit <- hclust(distMatrix, method = "ward.D")
      
      # Convert hclust into a dendrogram and plot
      hcd <- as.dendrogram(fit)
      # Default plot
      plot(hcd, type = "rectangle", ylab = "Height")
      
      rect.hclust(fit, k = input$nclust)
      
    })
    
    #### Topic modeling
    output$topic <-renderPlot({
      tweets <- tweets()
      #cross tweets to create a matrix
      tdm <- TermDocumentMatrix(textdata(), control = list(wordLengths = c(1, Inf)))
      dtm <- as.DocumentTermMatrix(tdm)
      #remove mpty tweets
      rowTotals <- apply(dtm , 1, sum) #Find the sum of words in each Document
      dtm.new   <- dtm[rowTotals> 0, ]           #remove all docs without words
      tweets.new   <- tweets[rowTotals> 0, ] 
      #Find the main topics
      lda <- LDA(dtm.new, k = input$ntopic, control = list(seed = 1234)) # find k topics
      term <- terms(lda, 4) # first 4 terms of every topic
      term <- apply(term, MARGIN = 2, paste, collapse = ", ")
      #Cross with the date (month-year)
      topic <- topics(lda, 1)
      topics <- data.frame(date=tweets.new$month, topic, text=tweets.new$text)
      #Plot tweets by topics accross time
      topics %>% 
        group_by(date,topic) %>% 
        summarise(n=n_distinct(text)) %>%
        mutate(f=n/sum(n))  %>%
        ggplot(.,aes(x=date,fill=term[topic],y=f)) + 
        geom_bar(stat="identity",position="stack") +
        labs(title="", y ="Tweets (%)", x = "") +
        theme_classic() +
        scale_fill_discrete(name = "Topic") +
        theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 45, hjust = 1))
    })
    
    #### Display table containing all tweets used for analysis
    output$tweet_table <- DT::renderDataTable({
        tweets <- tweets()
        temp <- data.frame(Date=format(tweets$created, "%d-%m-%Y %H:%M:%S"), User=tweets$screenName, Text=tweets$text, RetweetNb= tweets$retweetCount)
        DT::datatable(temp, options = list(searching = FALSE))
    })
    
}