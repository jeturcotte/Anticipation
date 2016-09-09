#tokens <- removeFeatures(tokens, stopwords())
#stems <- wordstem(tokens, 'english')
#trigrams <- ngrams(tokens,n=3,concatenator=" ")
#tg_matrix <- dfm(trigrams, verbose = F)  # this makes an incident matrix!

#setwd("~/R/PROJECTS/Anticipation")
library(quanteda)
library(markovchain)
ptm <- proc.time()
texts <- corpus(readLines('data/in/en_US.blogs.txt',n=10000))
proc.time() - ptm
tokens <- toLower(tokenize( texts, removeNumbers = T, removePunct = T, removeSeparators = T, removeTwitter = T, verbose = T))
#stems <- wordstem(tokens, 'english')
ptm <- proc.time()
fit <- markovchainFit( data=unlist(tokens) )
proc.time() - ptm
ptm <- proc.time()
predict( fit$estimate, newdata=c("where","was","i"), n.ahead=10)
proc.time() - ptm

