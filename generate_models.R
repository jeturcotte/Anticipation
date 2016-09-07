library(quanteda)
files <- list.files('./data/in', pattern = 'en_US*', full.names = T)

texts <- corpus(readLines('data/in/en_US.blogs.txt',n=100000))
tokens <- toLower(tokenize( texts, removeNumbers = T, removePunct = T, removeSeparators = T, removeTwitter = T, verbose = T))
#tokens <- removeFeatures(tokens, stopwords())
stems <- wordstem(tokens, 'english')
trigrams <- ngrams(tokens,n=3,concatenator=" ")
tg_matrix <- dfm(trigrams, verbose = F)  # this makes an incident matrix!
