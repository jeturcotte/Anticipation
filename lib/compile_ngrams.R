library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

src <- 'data/raw_texts'
dest <- 'data/raw_ngrams'

for( filename in list.files( src ) ) {
     
     if ( grepl('testing', filename) ) {
          message( sprintf( 'skipping test file: %s', filename ) )
          next
     }
     
     infile <- sprintf( '%s/%s', src, filename )
     
     # get our filename parts
     fnp <- unlist( strsplit( filename, '\\.' ) )
     sbp <- unlist( strsplit( fnp[2], '_' ) )
     ctype <- fnp[1]
     cnum <- sbp[2]
     rm( fnp, sbp )
     
     # load the data
     ptm <- proc.time()
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
     corpus <- corpus[ !grepl( '[[:digit:]]', corpus ) ]
     message( sprintf( 'data file %s has been tokenized', infile ) )
     
     # build out EVERY SINGLE 1-4gram in the entire sample corpus
     all_ngrams <- unlist(
          lapply(
               head( corpus, n=length(corpus) ),
               function(c){ 
                    return( ngrams( c, n=2:4, concatenator=" " ) )
               }
          )
     )

     # create a data frame to contain all this
     all_ngrams <- data.table( ngram=unlist( all_ngrams ) )
     message( 
          sprintf(
               'initial data table of %d ngrams created, consuming %f megs of memory',
               nrow( all_ngrams ),
               object.size( all_ngrams ) / (1024*1024)
               )
     )

     # now sum it all up
     all_ngrams <- tally( group_by( all_ngrams, ngram ), sort=T )
     colnames(all_ngrams) <- c('observed','frequency')
     #all_ngrams <- all_ngrams[all_ngrams$frequency > 3,]
     message( 
          sprintf(
               'compressed tallies of %d unique multi-sighting ngrams created, consuming %f megs of memory',
               nrow( all_ngrams ),
               object.size( all_ngrams ) / (1024*1024)
          )
     )
     
     # and save it out before it disappears, for cthulhu's sake!
     outfile <- sprintf( '%s/%s.%s.rds', dest, ctype, cnum )
     saveRDS( all_ngrams, outfile )
     print(proc.time() - ptm)
     message( sprintf( 'saved to %s ... and done\n\n', outfile ) )
     
}







