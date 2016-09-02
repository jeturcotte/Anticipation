library(rredis)

redisConnect()
redisSetPipeline(TRUE)
corpus_file <- 'data/out/clean_corpus.txt'
tc <- 0
lc <- 0
tl <- 2000000 # length( readLines( corpus_file ) )

# for display purposes
specify_decimal <- function(x, k) format(round(x, k), nsmall=k)

# first attempt; the most manual way possible...
for ( line in readLines( corpus_file, n=tl ) ) {
     
     # count lines read
     lc <- lc + 1
     percent_done <- specify_decimal( (100 / tl) * lc, 2 )
     
     words <- unlist( strsplit( line, " " ) )
     for ( n in 2:length(words) ) {
          
          # if any of these three cross a 10k barrier, we want to know
          report <- FALSE
          
          # insert our unigram first
          unigram <- words[(n-1)]
          redisHIncrBy( unigram, words[n], 1)
          tc <- tc + 1
          if (!tc %% 10000) { report <- TRUE }
          
          # then a bigram, if available
          if (n > 2) {
               bigram <- paste( words[(n-2):(n-1)], collapse=" " )
               redisHIncrBy( bigram, words[n], 1)
               tc <- tc + 1
               if (!tc %% 10000) { report <- TRUE }
          }
          
          # and, finally, a trigram, if available
          if (n > 3) {
               trigram <- paste( words[(n-3):(n-1)], collapse=" " )
               redisHIncrBy( trigram, words[n], 1)
               tc <- tc + 1
               if (!tc %% 10000) { report <- TRUE }
          }
          
          # now keep us in the loop, yo
          if ( report ) {
               print( paste( 
                    as.integer( ( tc / 1000 ) ), 
                    "k n-gram tallies complete; ",
                    percent_done,
                    "% done at ",
                    lc,
                    " lines processed",
                    sep=""
               ) )
          }
     }
}

print ('done')