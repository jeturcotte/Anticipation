#tokens <- removeFeatures(tokens, stopwords())
#stems <- wordstem(tokens, 'english')
#trigrams <- ngrams(tokens,n=3,concatenator=" ")
#tg_matrix <- dfm(trigrams, verbose = F)  # this makes an incident matrix!

library(quanteda)
library(stringr)
library(dplyr)

specify_decimal <- function(x, k) format(round(x, k), nsmall=k)

setwd("~/R/PROJECTS/Anticipation")

stem_the_predictors <- function( ngram ) {
     tokens <- unlist( tokenize( ngram ) )
     return(
          paste(
               paste(
                    wordstem(
                         tokens[1:( length(tokens) - 1 )],
                         language='english'
                    ),
                    collapse=" "
               ),
               tail( tokens, n=1 ),
               sep="|"
          )
     )
}

# load the data
ptm <- proc.time()
corpus <- c(
     readLines('data/in/en_US.blogs.txt'),
     readLines('data/in/en_US.news.txt'),
     readLines('data/in/en_US.twitter.txt')
)
corpus <- head(sample(corpus), 1000000)
print(proc.time() - ptm)
print('data files loaded and resampled')

# tokenize the data
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

# build out EVERY SINGLE bi, tri, and tetragram in the entire sample corpus
ptm <- proc.time()
all_ngrams <- unlist( lapply( head(corpus,n=length(corpus)), function(c){ return( ngrams( c, n=2:4, concatenator=" " ) ) } ) )
print( proc.time() - ptm )
print('ngrams assembled')

# now reduce the predictors to stems (but not the predictED)
ptm <- proc.time()
all_ngrams <- lapply( as.list(all_ngrams), stem_the_predictors )
print( proc.time() - ptm )
print('stemmed all the predictors')

# create a data frame to contain all this
ptm <- proc.time()
ng_frame <- data.frame( ngram=unlist( all_ngrams ) )
print(proc.time() - ptm)
print('initial data frame created')

# split out the columns
ptm <- proc.time()
ng_frame <- as.data.frame(str_split_fixed( ng_frame$ngram, "\\|", 2))
print(proc.time() - ptm)
print('predictors isolated from observations')

# now sum it all up
ptm <- proc.time()
ng_frame <- tally( group_by( ng_frame, V1, V2 ), sort=T )
colnames(ng_frame) <- c('predictors','observed','frequency')
ng_frame <- group_by( ng_frame, predictors ) %>% mutate( percent = frequency / sum(frequency) )
print(proc.time() - ptm)
print('summations unlocked!')

# and save it out before it disappears, for cthulhu's sake!
ptm <- proc.time()
saveRDS('data/out/analyzed_ngrams.rds')
print(proc.time() - ptm)
print('saved to file ... and done')
