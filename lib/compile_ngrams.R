#tokens <- removeFeatures(tokens, stopwords())
#stems <- wordstem(tokens, 'english')
#trigrams <- ngrams(tokens,n=3,concatenator=" ")
#tg_matrix <- dfm(trigrams, verbose = F)  # this makes an incident matrix!

library(quanteda)

specify_decimal <- function(x, k) format(round(x, k), nsmall=k)

setwd("~/R/PROJECTS/Anticipation")

ptm <- proc.time()
corpus <- c(
     readLines('data/in/en_US.blogs.txt'),
     readLines('data/in/en_US.news.txt'),
     readLines('data/in/en_US.twitter.txt')
)
corpus <- head(sample(corpus), 500000)
print(proc.time() - ptm)
print('data files loaded and resampled')

ptm <- proc.time()
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
print( proc.time() - ptm )
print('data files tokenized')

ngrams <- list()
lc <- length(corpus)

for ( ln in 1:lc ) {

     unstemmed <- unlist( tokenize( unlist( corpus[ln] ) ) )
     if (is.null(unstemmed)) {
          next
     }
     stemmed <- wordstem( unstemmed )
     
     for ( wn in (length(unstemmed)-1):1 ) {
          
          bigram <- paste(
               unstemmed[wn],
               unstemmed[(wn+1)],
               sep="|"
          )
          if (is.null(ngrams[[bigram]])) {
               ngrams[[bigram]] <- 1
          } else {
               ngrams[[bigram]] <- ngrams[[bigram]] + 1
          }
          if ( (wn-1) >= 1 ) {
               trigram <- paste(
                    stemmed[(wn-1)], '_',
                    stemmed[wn], '|',
                    unstemmed[(wn+1)],
                    sep=""
               )
               if (is.null(ngrams[[trigram]])) {
                    ngrams[[trigram]] <- 1
               } else {
                    ngrams[[trigram]] <- ngrams[[trigram]] + 1
               }
          }
          if ( (wn-2) >= 1) {
               tetragram <- paste(
                    stemmed[(wn-2)], '_',
                    stemmed[(wn-1)], '_',
                    stemmed[wn], '|',
                    unstemmed[(wn+1)],
                    sep=""
               )
               if (is.null(ngrams[[tetragram]])) {
                    ngrams[[tetragram]] <- 1
               } else {
                    ngrams[[tetragram]] <- ngrams[[tetragram]] + 1
               }
          }
     }
     if ( !ln %% 250 ) {
          print( paste( 
               specify_decimal( (100 / lc ) * ln, 2 ),
               "% done at ",
               ln,
               " records decomposed out of ",
               lc,
               sep=""
          ) )
     }
}
