library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

# load ngram intact from blogs
# load ngram intact from news
# load ngram intact from twitter ?
# order each <- pbx[order(pbx$frequency, decreasing=T),]
# slice off 1 count from each <- pbx[pbx$frequency > 1,]
# ngrams[,c('observed','predicted')] <- str_split_fixed(ngrams$observed, ' (?=[^ ]+$)', 2)
# ngrams <- aggregate( frequency ~ observed, data=rbind( pbi, pni, pni ), FUN=sum)

script_time <- proc.time()

remove_stop_words <- function(obs) {
     pared_down <- removeFeatures( tokenize(obs), stopwords("english") )
     return( paste( unlist( pared_down ), collapse=" " ) )
}

for( n in 5:2 ) {
     
     n_time <- proc.time()
     message( sprintf( 'loading all source %d-gram files', n ) )
     # for now, we're going to ignore previous nostopword and do it to predictos on the fly here
          # efficient, right?
     news <- readRDS( sprintf( 'dat/ngrams/news/all.intact.%d.grams.rds', n ) )
     blogs <- readRDS( sprintf( 'dat/ngrams/blogs/all.intact.%d.grams.rds', n ) )
     tweets <- readRDS( sprintf( 'dat/ngrams/twitter/all.intact.%d.grams.rds', n ) )
     
     # cut out ridiculously rare things
     news <- news[news$frequency > 2,]
     blogs <- blogs[blogs$frequency > 2,]
     tweets <- tweets[tweets$frequency > 2,]
     message( sprintf( ' - merging all but unique %d-grams', n ) )
     
     # add ,'nostopword' later... along with a section to do it
     for( category in c( 'intact', 'no_stop_words' ) ){
          
          # collapse and recalculate them
          precount <- nrow(news) + nrow(blogs) + nrow(tweets)
          ngrams <- aggregate( frequency ~ observed, data=rbind( news, blogs, tweets ), FUN=sum)
          message( sprintf( ' - cross-compiled %s %d-grams, narrowed from %d down to %d rows', category, n, precount, nrow(ngrams) ) )

          # split the predicted off, and begin to categorize within
          ngrams[, c( 'observed','predicted')] <- str_split_fixed(ngrams$observed, ' (?=[^ ]+$)', 2)
          ngrams <- as.data.table( ngrams )
          message( ' - split predicted word from predictive words' )
                    
          if ( category == 'no_stop_words' ) {
               ngrams <- ngrams[ , observed := lapply( observed, function(observation) remove_stop_words(observation) )]
               ngrams <- ngrams[ ngrams$observed != '', ]
               ngrams$observed <- as.factor(unlist(ngrams$observed))
               ngrams <- aggregate( frequency ~ observed + predicted, data=ngrams, FUN=sum)
               message( sprintf( ' - re-aggregated %s %d-grams, narrowed from %d down to %d rows', category, n, precount, nrow(ngrams) ) )
          }

          # make processing words a little faster and ligher on memory
          ngrams$observed <- as.factor(ngrams$observed)
          ngrams$predicted <- as.factor(ngrams$predicted)
          
          message( 
               sprintf( 
                    ' - factored %d unique observed and %d unique predicted columns', 
                    length(unique(ngrams$observed)), 
                    length(unique(ngrams$predicted))
               )
          )
          
          # cull one more time based on a naive threshold
          thresh <- 20
          ngrams <- ngrams[ ngrams$frequency > thresh,]
          message( 
               sprintf( 
                    ' - sliced down to %d total observations based on threshold of more than %d observations ', 
                    nrow(ngrams), 
                    thresh
               )
          )
          
          # now build out a predictor sensitive incidence score for each predicted word
          ngrams <- as.data.table (
               ngrams %>% 
                    group_by(observed) %>%
                    mutate(
                         incidence = round(
                              frequency / sum( frequency ),
                              digits=4
                         )
                    )
          )
          message(' - incidence calculated for each predicted for each predictor ')
          
          # re-sort the table, and cleave all but three best options from it
          ngrams <- ngrams[ order( -rank(ngrams$frequency), -rank(ngrams$incidence) ), ]
          ngrams <- ngrams[ order( ngrams$frequency ), tail( .SD, 3 ), by=observed ]
          message( 
               sprintf( 
                    ' - sliced again down to %d total observations, keeping only max of 3 observations per predictor ', 
                    nrow(ngrams)
               )
          )
          
          # kep only incidence for numbers
          ngrams <- ngrams[, !c('frequency'), with=F ]
          saveRDS( ngrams, sprintf('dat/protomodel/chosen.%s.%d.grams.rds', category, n) )
     }
     
     print( proc.time() - n_time )
     message( sprintf( 'finished compiling %d-grams and saved to file under dat/protomodel\n\n', n ) )
     
}
