library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

src <- 'data/raw_texts'
dest <- 'data/close'

for( filename in list.files( src ) ) {
     
     if ( grepl('testing', filename) ) {
          message( sprintf( 'skipping test file: %s', filename ) )
          next
     }
     
     infile <- sprintf( '%s/%s', src, filename )
     
     # load the data
     corpus <- readLines( infile )
     message( sprintf( 'data file %s loaded and resampled', infile ) )

     # tokenize the data
     corpus <- toLower(
          tokenize(
               corpus,
               removeNumbers = T,
               removePunct = T,
               removeSeparators = T,
               removeTwitter = T,
               verbose = T
          )
     )
     message( sprintf( 'data file %s has been tokenized', infile ) )

     full_corpus <- c( full_corpus, corpus )
     message( 
          sprintf(
               'extracted tokens merged into full list, at size of %f megs of memory',
               object.size( full_corpus ) / (1024*1024)
          )
     )
}
     
# nix anything with a number
full_corpus <- full_corpus[ !grepl( '[[:digit:]]', full_corpus ) ]
message( sprintf( 'eliminated anything compaced with a number; down to %d tokens ', length(full_corpus) ) )

# make a table out of this
full_corpus <- data.table( ngram=unlist( full_corpus ) )
message( sprintf( 'tokens rearranged into a data.table of %d rows', nrow(full_corpus) ) )

# and compress that table into tallies
full_corpus <- tally( group_by( full_corpus, ngram ), sort=T )
message( 
     sprintf( 
          'tokens tallied a data.table of %d rows, consuming %f megs of memory',
          nrow(full_corpus),
          object.size( full_corpus ) / (1024*1024)
     )
)

outfile <- sprintf( '%s/vocabulary.rds', dest )
saveRDS( full_corpus[ full_corpus$n >= 15, ], outfile )
message( sprintf( 'saved close vocabulary to %s ... and done\n\n', outfile ) )

outfile <- sprintf( '%s/exclusions.rds', dest )
saveRDS( full_corpus[ full_corpus$n < 15, ], outfile )
message( sprintf( 'saved close exclusions to %s ... and done\n\n', outfile ) )