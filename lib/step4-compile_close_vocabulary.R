library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

# we are skipping twitter unigrams, for now, due to noise caused by intentional misspellings, et cetera
for( type in c( 'blogs', 'news' ) ) {

     src <- sprintf( 'dat/ngrams/%s', type )
     dest <- sprintf( 'dat/close/%s.rds', type )
     files <- list.files( src )
     files <- files[ grepl('intact_1', files) ]
     
     infile <- sprintf( '%s/%s', src, files[1] )
     unigrams <- readRDS( infile )
     # we will store only stems, and do comparisons against stems later
     # as to whether we'll keep the unstemmed token in our ngram lists
     unigrams$observed <- wordstem( unigrams$observed, language="english" )
     
     for( filename in files[2:( length(files) )] ) {
          
          file_time <- proc.time()
          
          infile <- sprintf( '%s/%s', src, filename )
          total_in <- nrow(unigrams)
          
          # load the data
          next_unigrams <- readRDS( infile )
          # see previous explanation for stemming
          next_unigrams$observed <- wordstem( next_unigrams$observed, language="english" )
          total_loaded <- nrow(next_unigrams)
          message( sprintf( 'file < %s > loaded', infile ) )
          
          # aggregate their tallies
          unigrams <- aggregate( frequency ~ observed, data=rbind( unigrams, next_unigrams ), FUN=sum )
          total_merged <- nrow(unigrams)

          message( 
               sprintf( 
                    ' - had %d rows of unigrams, loaded %d more, and merged to become %d\n - - (consuming %f megs of memory)', 
                    total_in,
                    total_loaded,
                    total_merged,
                    object.size( unigrams ) / (1024*1024)
               )
          )
          
          # and save it out before it disappears, for cthulhu's sake!
          saveRDS( unigrams, dest )
          message( sprintf( ' - backed up to < %s >\n', dest ) )
          
     }

     # now get a percentile count after killing rare stemmed unigrams (which should have many many less rare)
     unigrams <- unigrams[ unigrams$frequency >= 50, ]

     # and, after all that work, just destroy ~85% of it!
     saveRDS( unigrams, dest )
     message( sprintf( ' - finalized < %s > with %d acceptable unigrams\n', dest, nrow(unigrams) ) )
     
}
