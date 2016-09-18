library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

entire <- proc.time()
n <- 5

for( type in c('blogs','news','twitter') ) {

     by_type <- proc.time()
     src <- sprintf( 'dat/corpus/%s', type )
     dest <- sprintf( 'dat/ngrams/%s', type )
     
     for( filename in list.files( src ) ) {

          if ( grepl('testing', filename) ) {
               message( sprintf( 'skipping test file: %s\n', filename ) )
               next
          }
          
          this_loop <- proc.time()
          infile <- sprintf( '%s/%s', src, filename )
          
          # get our filename parts
          fnp <- unlist( strsplit( filename, '\\.' ) )
          sbp <- unlist( strsplit( fnp[1], '_' ) )
          ctype <- sbp[1]
          cnum <- sbp[2]
          rm( fnp, sbp )

          # load the data
          corpus <- readRDS( infile )
          message( sprintf( 'data file < %s > loaded and resampled', infile ) )

          # tokenize the data
          corpus <- toLower(
               #removeFeatures(
               tokenize(
                    corpus,
                    removeNumbers = T,
                    removePunct = T,
                    removeSeparators = T,
                    removeTwitter = T,
                    verbose = F
               ) #, stopwords("english")
               #)
          )
          corpus <- corpus[ !grepl( '[[:digit:]]', corpus ) ]
          message( sprintf( ' - content been tokenized and cleaned of number-letter combinations', infile ) )
          
          for ( n in 5:1 ) {
               
               # build out EVERY SINGLE ngram from the corpus
               ngrams <- unlist(
                    lapply(
                         head( corpus, n=length(corpus) ),
                         function(c){ 
                              return( ngrams( c, n=n, concatenator=" " ) )
                         }
                    )
               )
               
               # create a data frame to contain all this
               ngrams <- data.table( ngram=unlist( ngrams ) )
               message( 
                    sprintf(
                         ' - initial data table of %d %d-grams created, consuming %0.2f megs of memory',
                         nrow( ngrams ),
                         n,
                         object.size( ngrams ) / (1024*1024)
                    )
               )
               
               # now sum it all up
               ngrams <- tally( group_by( ngrams, ngram ), sort=T )
               colnames( ngrams ) <- c( 'observed','frequency' )
               message( 
                    sprintf(
                         ' - compressed tallies of %d unique %d-grams created',
                         nrow( ngrams ),
                         n
                    )
               )
               
               # and save it out before it disappears, for cthulhu's sake!
               outfile <- sprintf( '%s/intact_%d-gram_%s.rds', dest, n, cnum )
               saveRDS( ngrams, outfile )
               message( sprintf( ' - saved to < %s > ... and done\n', outfile ) )
               
          }
              
          print( proc.time() - this_loop )
          message( sprintf( 'all ngram collations done for group %d\n', n ) )
          
     }
     
     print(proc.time() - by_type)
     message( sprintf( 'all ngram collations done for %s\n\n', type ) )
     
}

print(proc.time() - entire)
message( sprintf( 'all ngrams types have been collated for all types', n ) )






