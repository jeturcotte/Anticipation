library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

specify_decimal <- function(x, k) format(round(x, k), nsmall=k)

setwd("~/R/PROJECTS/Anticipation")

src <- 'data/raw_text'
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
     message( sprintf( 'data file %s, part %s tokenized', ctype, cnum ) )

     # build out EVERY SINGLE 2-4gram in the entire sample corpus
     all_ngrams <- unlist(
          lapply(
               head( corpus, n=length(corpus) ),
               function(c){ 
                    return( ngrams( c, n=2:4, concatenator=" " ) )
               }
          )
     )
     message( sprintf('%d ngrams assembled', length(all_ngrams) ) )

     # create a data frame to contain all this
     ng_frame <- data.frame( ngram=unlist( all_ngrams ) )
     message('initial data frame created')

     # split out the columns
     ng_frame <- as.data.frame(str_split_fixed( ng_frame$ngram, "\\|", 2))
     message('predictors isolated from observations')
     
     # now sum it all up
     ng_frame <- tally( group_by( ng_frame, V1, V2 ), sort=T )
     colnames(ng_frame) <- c('predictors','observed','frequency')
     ng_frame <- group_by( ng_frame, predictors ) %>% mutate( percent = frequency / sum(frequency) )
     message( sprintf( 'summations of %d unique ngrams tallied!', nrow(ng_frame) ) )

     # and save it out before it disappears, for cthulhu's sake!
     outfile <- sprintf( '%s/%s.%s.rds', dest, ctype, cnum )
     saveRDS( all_ngrams, outfile )
     print(proc.time() - ptm)
     message( sprintf( 'saved to %s ... and done\n\n', outfile ) )
     
     quit()
}







