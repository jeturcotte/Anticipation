library(quanteda)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

prepare <- function( corpus ) {
     return(
          #unlist(
               tokenize(
                    tolower( corpus ),
                    removeNumbers = T,
                    removePunct = T,
                    removeSeparators = T,
                    removeTwitter = T,
                    verbose = F
               )
          #)
     )
}

findings <- function( text_so_far ) {
     
     tokens <- prepare( unlist(text_so_far) )
     results <- data.table()
     
     # look for all depths
     penta <- paste( tail(tokens,n=5), collapse=" " )  # intended to know some common catch phrases
     tetra <- paste( tail(tokens,n=4), collapse=" " )  # intended to know some short catch phrases
     tri <- paste( tail(tokens,n=3), collapse=" " )    # more likely to at least be able to follow grammar
     bi <- paste( tail(tokens,n=2), collapse=" " )     # may be able to handle some grammar
     uni <- paste( tail(tokens,n=1), collapse=" " )    # if all else fails
     
     # snag the whole resultset
     model[ model$observed %in% c(penta,tetra,tri,bi,uni), ]
     
}

choices <- function( results ) {
     
     if(!nrow(results)){ return(c('NA','NA','NA'))}
     results <- aggregate( score ~ predicted, data=results, FUN=max)
     head(
          results[ order( results$score, decreasing=T ), ]$predicted,
          n=3
     )
     
}

# load the data
model <- readRDS('application/model.rds')
test_blogs <- prepare( readRDS('dat/corpus/blogs/testing.rds') )
test_news <- prepare( readRDS('dat/corpus/news/testing.rds') )
test_tweets <- prepare( readRDS('dat/corpus/twitter/testing.rds') )

set.seed(7041)

tbt <- 0
tbc_a <- 0
tbc_b <- 0
tbc_c <- 0
for( thought in test_blogs ){
     if( length(thought) <= 3 ){ next }
     tbt <- tbt + 1
     end_at <- sample( 1:(length(thought)-1), 1 )
     results <- choices( findings( unlist( thought[1:end_at] ) ) )
     
     if ( thought[(end_at+1)] == results[1] ) {
          tbc_a <- tbc_a + 1
     }
     else if ( !is.na(results[2]) && thought[(end_at+1)] == results[2] ) {
          tbc_b <- tbc_b + 1
     }
     else if ( !is.na(results[3]) && thought[(end_at+1)] == results[3] ) {
          tbc_c <- tbc_c + 1
     }
}

tnt <- 0
tnc_a <- 0
tnc_b <- 0
tnc_c <- 0
for( thought in test_news ){
     if( length(thought) <= 3 ){ next }
     tnt <- tnt + 1
     end_at <- sample( 1:(length(thought)-1), 1 )
     results <- choices( findings( unlist( thought[1:end_at] ) ) )
     
     if ( thought[(end_at+1)] == results[1] ) {
          tnc_a <- tnc_a + 1
     }
     else if ( !is.na(results[2]) && thought[(end_at+1)] == results[2] ) {
          tnc_b <- tnc_b + 1
     }
     else if ( !is.na(results[3]) && thought[(end_at+1)] == results[3] ) {
          tnc_c <- tnc_c + 1
     }
}

ttt <- 0
ttc_a <- 0
ttc_b <- 0
ttc_c <- 0
for( thought in test_tweets ){
     if( length(thought) <= 3 ){ next }
     ttt <- ttt + 1
     end_at <- sample( 1:(length(thought)-1), 1 )
     results <- choices( findings( unlist( thought[1:end_at] ) ) )
     
     if ( thought[(end_at+1)] == results[1] ) {
          ttc_a <- ttc_a + 1
     }
     else if ( !is.na(results[2]) && thought[(end_at+1)] == results[2] ) {
          ttc_b <- ttc_b + 1
     }
     else if ( !is.na(results[3]) && thought[(end_at+1)] == results[3] ) {
          ttc_c <- ttc_c + 1
     }
}
