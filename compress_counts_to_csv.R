library(rredis)

redisConnect()

ngram_file <- 'data/out/three_most_common_ngrams.csv'
c <- 0

ngrams <- data.frame(
     "tri"=character(),
     "bi"=character(),
     "uni"=character(),
     "predicting"=character(),
     "pop"=integer(),
     stringsAsFactors=F
)

# given that rredis seems not to offer a cursor for
# 'scan' nativ to redis itself we have to break this up
# somehow... so... alphabetically
segments <- c(
     'a','b','c','d','e','f','g','h','i','j',
     'k','l','m','n','o','p','q','r','s','t',
     'u','v','w','x','y','z'
)

for ( segment in c('b') ) {
     
     pattern <- paste(segment,'*',sep="")
     for ( match in redisKeys( pattern=pattern ) ) {
     
          ngram <- redisHGetAll(match)
          
          # whittle out the ultra-rare matches
          # since we have already collated possible
          # walk-back options in other keys
          if ( length( names(ngram) ) > 1 || ngram[[1]][1] != '1' ) {
               
               c <- c + 1
               results <- list()
               for ( predicted in names(ngram) ) {
                    results[[predicted]] <- as.integer(ngram[[predicted]][1])
               }
     
               
               
          }
          
          if (!c %% 10000) {
               print( paste( as.integer( ( c / 1000 ) ), "k keys have been read from redis", sep="" ) )
               print(ngram)
          }
     }
     
}

print ('done')