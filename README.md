# twitter-analysis

INTRODUCTION
------------

This is a Shiny application written in R that visualizes Twitter data.
In this example, we want to analyze tweets published either by EP user account, Izigloo or Both. The tweets were collected prior to build the application using TwitteR package.

LOADING TWEETS
--------------

The first step is to load tweet for the analysis. A selection bar enables to select EP tweets, Izigloo or Both. 
Also, there is a checkbock to choose eiher including the term "Izigloo" in the analysis or not. The word is actually very frequent and its inclusion impact results a lot.
This selection will be used for all analysis.

ANALYSIS
--------

This performs a wordcloud from text data, a time plot, a cluster analysis and topic modeling. Also, it returns a table of all tweets used. 
The application is divided into several panels, each panel displaying a specific analysis from the tweets' selection.

METHODOLOGY
-----------

The shiny appliction is written with R. For vizualisation, ggplot2 is mainly used.
The hierarchical clustering method with Ward distances was chosen for the cluster analysis.
The topic modeling was conducted using the Latent Dirichlet Allocation (LDA) model (topicmodels package).

