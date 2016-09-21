library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

# load ngram intact from blogs
# load ngram intact from news
# load ngram intact from twitter ?
# order each <- pbx[order(pbx$frequency, decreasing=T),]
# slice off 1 count from each <- pbx[pbx$frequency > 1,]
# ngrams[,c('observed','predicted')] <- str_split_fixed(ngrams$observed, ' (?=[^ ]+$)', 2)
# ngrams <- aggregate( frequency ~ observed, data=rbind( pbi, pni, pni ), FUN=sum)

script_time <- proc.time()

# load the data
penta_news <- readRDS('dat/ngrams/news/all.intact.5.grams.rds')
penta_blogs <- readRDS('dat/ngrams/blogs/all.intact.5.grams.rds')
penta_tweets <- readRDS('dat/ngrams/twitter/all.intact.5.grams.rds')
message('5gram files loaded')

# eliminate majority of useless entries
penta_news <- penta_news[penta_news$frequency > 1,]
penta_blogs <- penta_blogs[penta_blogs$frequency > 1,]
penta_tweets <- penta_tweets[penta_tweets$frequency > 1,]
message('5gram lists whittled down a bit')

# splice some together as a reference for success
penta_ref <- cbind(
     head(penta_news,n=10),
     head(penta_blogs,n=10),
     head(penta_tweets,n=10)
)
colnames(penta_ref) <- c('n','nc','b','bc','t','tc')
message('created reference frame')

# collapse and recalculate them
ngrams <- aggregate( frequency ~ observed, data=rbind( penta_news, penta_blogs, penta_tweets ), FUN=sum)
rm( penta_tweets, penta_blogs, penta_news )
message('aggregated into one frame')

# split the predicted off, and begin to categorize within
ngrams[,c('observed','predicted')] <- str_split_fixed(ngrams$observed, ' (?=[^ ]+$)', 2)
message('split predicted from predictors')

ngrams$observed <- as.factor(ngrams$observed)
ngrams$predicted <- as.factor(ngrams$predicted)
ngrams <- ngrams %>% 
     group_by(observed) %>%
     mutate(
          incidence = round(
               frequency / sum( frequency ),
               digits=3
          ),
          population = n_distinct( frequency )
     )
message('created incidence and population columbs')

ngrams <- as.data.table(ngrams)
ngrams <- ngrams[order(-rank(ngrams$frequency), -rank(ngrams$incidence)),]
#ngrams <- ngrams[, tail(.SD, 3), by=frequency]
message('reordered and sliced off extraneous results')
