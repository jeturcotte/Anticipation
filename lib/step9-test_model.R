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

findings <- function( tokens ) {
     
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

set.seed(7041)
# source, ngram, hit, which
line <- '%s,%s,%s,%s,%s,%d'
outfile <- 'reports/test_results.csv'
write( 'source,ngram,correct,best,which,hits', outfile )

for( src in c('blogs','news','twitter') ) {

     infile <- sprintf( 'dat/corpus/%s/testing.rds', src )
     corpus <- prepare(
          readRDS( infile )
     )
     message( sprintf( '- file < %s > loaded;', infile ) )
     
     src_time <- proc.time()
     thoughts_tested <- 0
     for( thought in corpus ) {
          
          if( length(thought) <= 4 ){ next }
          thoughts_tested <- thoughts_tested + 1
          
          # assemble our randomly placed ngram
          guess_at <- sample( 3:(length(thought)-1), 1 )
          ngram <- unlist( thought[1:guess_at] )
          
          # predict what comes next
          predictions <- choices( findings( ngram ) )

          # tag which hit we got, if any
          which_hit <- 'none'
          total_hits <- length(predictions)
          if ( thought[(guess_at+1)] == predictions[1] ) {
               which_hit <- 'first'
          }
          else if ( !is.na(predictions[2]) && thought[(guess_at+1)] == predictions[2] ) {
               which_hit <- 'second'
          }
          else if ( !is.na(predictions[3]) && thought[(guess_at+1)] == predictions[3] ) {
               which_hit <- 'third'
          }
          
          # append to file
          entry <- sprintf(
               line,
               src,
               paste( tail(ngram,n=5), collapse=" " ),
               thought[(guess_at+1)],
               predictions[1],
               which_hit,
               total_hits
          )
          write( entry, outfile, append=T )
          
          # keep us updated on progress
          if ( !1000 %% thoughts_tested ) {
               message(
                    sprintf(
                         ' - %dk %s thoughts tested; %0.2f complete',
                         as.integer( thoughts_tested / 1000 ),
                         src,
                         ( thoughts_tested / nrow(corpus) * 100 )
                    )
               )
          }
          
     }
     
     print( proc.time() - src_time )
     message( sprintf( '\t- %s material processed;\n', src ) )
     
}

message( '- testing process complete ')