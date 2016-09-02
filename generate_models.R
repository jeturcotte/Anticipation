library(rredis)

corpus_file <- 'data/out/clean_corpus.txt'
ngrams_file <- 'data/out/ngrams.txt'

# lets first create a tidy data 'barrel' for this, first...
ngrams <- data.frame(
     "tri"=character(),
     "bi"=character(),
     "uni"=character(),
     "predicting"=character(),
     "pop"=integer(),
    stringsAsFactors=F
)

count <- 0

# first attempt; the most manual way possible...
for ( line in readLines( corpus_file, n=100 ) ) {
     
     words <- unlist( strsplit( line, " " ) )
     for ( n in 2:length(words) ) {
          key <- words[n-1]
          if (n==3) {
               key <- paste( words[(n-2):n], collapse=" " )
          }
          if (n > 3) {
               key <- paste( words[(n-3):n], collapse=" " )
          }
     }

}