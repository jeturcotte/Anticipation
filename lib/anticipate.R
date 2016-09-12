anticipate <- function(phrase) {
     ngram <- paste( tail( unlist( wordstem( tokenize ( phrase ) ) ), 3), collapse=" " )
     return(
          head( ng[ng$predictors==ngram,], n=3 )
     )
} 