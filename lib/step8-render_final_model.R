library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

compile_time <- proc.time()

bigrams <- readRDS('dat/protomodel/chosen.intact.2.grams.rds')
trigrams <- readRDS('dat/protomodel/chosen.intact.3.grams.rds')
tetragrams <- readRDS('dat/protomodel/chosen.intact.4.grams.rds')
pentagrams <- readRDS('dat/protomodel/chosen.intact.5.grams.rds')
message('all n-grams loaded')

ngrams <- rbind( bigrams, trigrams, tetragrams, pentagrams )
rm( bigrams, trigrams, tetragrams, pentagrams )
message( sprintf( ' - %d ngrams combined into one structure', nrow(ngrams) ) )

close_blogs <- readRDS('dat/close/blogs.rds')
close_news <- readRDS('dat/close/news.rds')
message( ' - close vocabulary loaded' )
message( '   - twitter excluded due to prevalence of intentionally misspelled words' )

close <- as.data.table( aggregate( frequency ~ observed, data=rbind( close_news, close_blogs ), FUN=median) )
rm( close_blogs, close_news )
message( 
     sprintf( 
          ' - aggregated common close vocabulary of %d words ', 
          nrow(close)
     )
)

close$rarity <- close$frequency / sum(close$frequency)
close <- close[, !c('frequency'), with=F ]
message(
     sprintf(
          ' - rarity of each word calculated at a mean of ( %0.6f )',
          mean(close$rarity)
     )
)

setkey(ngrams,observed)
setkey(close,observed)
message( ' - keys established for both ngrams and close vocab, to speed up searches a bit' )

ngrams <- merge( ngrams, close, by.x='predicted', by.y='observed')
ngrams$score <- ngrams$incidence + ngrams$rarity
ngrams <- ngrams[ order( rank(ngrams$observed), -rank(ngrams$score) ), ]
message(
     sprintf(
          ' - mean sortable score of ( %0.4f )  calculated from close vocab rarity added to ngram incidence',
          mean(ngrams$score)
     )
)

print ( proc.time() - compile_time )

saveRDS( ngrams[, !c( 'incidence', 'rarity' ), with=F ], 'application/model.rds' )
message( ' - final model saved to < dat/model.rds >\n\n' )