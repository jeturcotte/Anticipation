library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

src <- 'data/raw_ngrams'
dest <- 'data/raw_ngrams'

entire <- proc.time()

for( type in c('blogs','news','twitter') ) {

     files <- list.files( 
          sprintf( 
               '%s/%s',
               src,
               type
          )
     )
     ngrams <- readRDS(
          sprintf(
               '%s/%s/%s',
               src,
               type,
               files[1]
          )
     )
     
     total <- proc.time()
     
     for( filename in files[2:( length(files) )] ) {
          
          infile <- sprintf( '%s/%s/%s', src, type, filename )
          total_in <- nrow(ngrams)
          
          # load the data
          thisloop <- proc.time()
          next_ngrams <- readRDS( infile )
          total_loaded <- nrow(next_ngrams)
          message( sprintf( 'file < %s > loaded', infile ) )
          
          # aggregate their tallies
          ngrams <- aggregate( frequency ~ observed, data=rbind(ngrams,next_ngrams), FUN=sum)
          total_merged <- nrow(ngrams)
          print(proc.time() - thisloop)
          message( 
               sprintf( 
                    ' - had %d rows of ngrams, loaded %d more, and merged to become %d (consuming %f megs of memory)\n', 
                    total_in, total_loaded, total_merged, object.size( ngrams ) / (1024*1024)
               )
          )
          
          # and save it out before it disappears, for cthulhu's sake!
          outfile <- sprintf( '%s/all_ngrams_for_%s.rds', dest, type )
          saveRDS( ngrams, outfile )
          message( sprintf( ' - backed up to < %s >\n', outfile ) )
          
     }
     
     print(proc.time() - total)
     message( sprintf( 'final saved to < %s > ... and done with %s\n\n', outfile, type ) )
     
}

print(proc.time() - entire)
message( sprintf( 'all ngram types have been collated' ) )






