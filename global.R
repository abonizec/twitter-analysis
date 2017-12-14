# Global setups

#### Load packages
library(twitteR)
library(tm)
library(wordcloud)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(stringr)
library(topicmodels)
require(data.table) 

#### Load tweets posted by izigloo and EP
izigloo <- get(load("data/tweets_izigloo_ 2017-12-13 .Rdata"))
izigloo$month <- format(as.Date(izigloo$created), "%Y-%m")
izigloo$day <- format(as.Date(izigloo$created), "%Y-%m-%d")
EP <- get(load("data/tweets_EP_ 2017-12-13 .Rdata"))
EP$month <- format(as.Date(EP$created), "%Y-%m")
EP$day <- format(as.Date(EP$created), "%Y-%m-%d")
Both <- rbind(izigloo,EP)

#### Grab text data
getTextData <- function(tweets,stopwordList) {

    # Gather corpus
    textdata <- Corpus(VectorSource(tweets$text))
    
    textdata <- 
        textdata %>%
        #Remove URL
        tm_map(content_transformer(function(x) gsub("http[[:alnum:][:punct:]]*", "", x))) %>%
        #Remove linefeeds (\n)
        tm_map(content_transformer(function(x) gsub("\n","", x))) %>%
        #Replace accents
        tm_map(content_transformer(function(x) gsub("[éèê]","e", x))) %>%
        tm_map(content_transformer(function(x) gsub("[àâ]","a", x))) %>%
        tm_map(content_transformer(function(x) gsub("[ùû]","u", x))) %>%
        tm_map(content_transformer(function(x) gsub("[ô]","o", x))) %>%
        #Remvove apostrophes
        tm_map(content_transformer(function(x) gsub('"',"", x))) %>%
        #Transforming emojis
        tm_map(content_transformer(function(x) iconv(x, from='ASCII', 
                                                      to='UTF-8', sub='byte'))) %>%
        #Removing emojis
        tm_map(content_transformer(function(x) gsub("<+[[:alnum:]]+>","", x))) %>%
        #Removing punctuation
        tm_map(removePunctuation, preserve_intra_word_contractions=F, preserve_intra_word_dashes=F) %>%
    
        tm_map(content_transformer(tolower)) %>% 
        tm_map(content_transformer(function(x) str_replace_all(x, "@\\w+", ""))) %>% # remove twitter handles
        tm_map(removeNumbers) %>%
        tm_map(removeWords, stopwordList)
}


