library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

script_time <- proc.time()

# keep separate ngrams from different sources, for now
for( type in c('blogs','news','twitter') ) {
     
     type_time <- proc.time()
     
     src <- sprintf( 'dat/ngrams/%s', type )
     
     # keep separate ngrams that do and don't include stopwords, for now
     for( category in c('nostpwrd','intact') ) {
               
          # keep separate the ngram lengths, for now
          # unigrams will be done separately as a close vocab system
          for ( n in 5:2 ) {
               
               n_time <- proc.time()
               
               # load only the subcategory of ngrams this time around
               files <- list.files( sprintf( src ) ) 
               fpat <- sprintf( '%s_%s', category, n )
               files <- files[ grepl( fpat, files) ]
               if( !length(files) ) { next }
               infile <- sprintf( '%s/%s', src, files[1] )
               outfile <- sprintf( '%s/all.%s.%d.grams.rds', src, category, n )
               
               # read in first file manually given that we're aggregating now
               message( sprintf( '\nopening < %s > to begin', infile ) )
               ngrams <- readRDS( infile )
               
               for( filename in files[2:( length(files) )] ) {
                    
                    infile <- sprintf( '%s/%s', src, filename )
                    total_in <- nrow(ngrams)
                    
                    # load the data
                    message( sprintf( 'opening < %s > for merger', infile ) )
                    next_ngrams <- readRDS( infile )
                    total_loaded <- nrow(next_ngrams)

                    # aggregate their tallies
                    ngrams <- aggregate( frequency ~ observed, data=rbind( ngrams, next_ngrams ), FUN=sum)
                    total_merged <- nrow(ngrams)

                    message( 
                         sprintf( 
                              ' - had %d rows of %s %d-grams, plus %d more, and merged to become %d\n - - (consuming %0.2f megs of memory)', 
                              total_in,
                              category,
                              n, 
                              total_loaded,
                              total_merged,
                              object.size( ngrams ) / (1024*1024)
                         )
                    )
                    
                    # and save it out before it disappears, for cthulhu's sake!
                    saveRDS( ngrams, outfile )
                    message( sprintf( ' - backed up to < %s >', outfile ) )
                    
               } # end individual file aggregation

               print( proc.time() - n_time )
               message(
                    sprintf(
                         ' - final %s %d-grams saved to < %s > ... and done with %s\n',
                         category,
                         n,
                         outfile,
                         type
                    )
               )
                              
          } # end n-gram collation

     } # end categorical collation

     print(proc.time() - type_time)
     message( sprintf( '- ngrams for %s have been collated\n\n', type ) )
     
} # end type collation

print(proc.time() - script_time)
message( sprintf( 'all ngram types have been collated\n' ) )






