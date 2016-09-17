library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

src <- 'data/raw_ngrams'
dest <- 'data/raw_ngrams'

entire <- proc.time()

blogs <- readRDS('data/raw_ngrams/all_ngrams_for_blogs.rds')
news <- readRDS('data/raw_ngrams/all_ngrams_for_news.rds')
twitter <- readRDS('data/raw_ngrams/all_ngrams_for_witter.rds')

blogs <- blogs[ blogs$frequency > 4, ]
news <- news[ news$frequency > 4, ]
twitter <- twitter[ twitter$frequency > 4, ]

ng <- aggregate( frequency ~ observed, data=rbind( blogs, news, twitter ), FUN=sum)
rm( blogs, news, twitter )
ng[,c('observed','predicted')] <- str_split_fixed(ng$observed, ' (?=[^ ]+$)', 2)
ng <- ng[order(ng$observed,-ng$frequency),]

for( type in c('blogs','news','twitter') ) {

     this_loop <- proc.time()
     
     # load up our unfiltered ngram files for this type
     infile <- sprintf( '%s/all_ngrams_for_%s.rds', src, type )
     message( sprintf( 'reading in %s', infile ) )
     ngrams <- readRDS( infile )
     message( sprintf( 
          ' - complete at %d rows and needing %0.2f megs of memory',
          nrow(ngrams),
          object.size(ngrams) / (1024*1024)
     ) )
     
     # slice off the truly rare stuff
     ngrams <- ngrams[ ngrams$frequency > 4, ]
     message( sprintf( 
          ' - reduced to %d rows, needing %0.2f megs of memory',
          nrow(ngrams),
          object.size(ngrams) / (1024*1024)
     ) )
     
     # take off the final as predicted as opposed to predictor
     ngrams[,c('observed','predicted')] <- str_split_fixed(ngrams$observed, ' (?=[^ ]+$)', 2)
     
 }

print(proc.time() - entire)
message( sprintf( 'all ngram types have been collated' ) )






