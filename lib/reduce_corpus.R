library(quanteda)
library(stringr)

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

tag <- function (line) { 
     sent_words <- Maxent_Sent_Token_Annotator()
     word_token <- Maxent_Word_Token_Annotator()
     pos_tags <- Maxent_POS_Tag_Annotator()
     simple_tokens <- annotate( line, list( sent_words, word_token ) )
     annotation <- annotate( line, pos_tags, simple_tokens )
     words <- subset(annotation, type=="word")
     tags <- sapply(words$features, '[[', "POS")
     return(
          paste(
               sprintf("%s/%s", line[words], tags), collapse=""
          )
     ) 
}

POStag <- function(path = path){
     require("NLP")
     require("openNLP")
     require("openNLPmodels.en")
     corpus.files = list.files(path = path, pattern = NULL, all.files = T, full.names = T, recursive = T, ignore.case = T, include.dirs = T)
     corpus.tmp <- lapply(
          corpus.files , function(x) {
               scan(x, what = "char", sep = "\t", quiet = T)
          }
     )
     corpus.tmp <- lapply(
          corpus.tmp, function(x){
               x <- paste(x, collapse = " ")
          }
     )
     corpus.tmp <- lapply(
          corpus.tmp, function(x) {
               x <- enc2utf8(x)
          }
     )
     corpus.tmp <- gsub(" {2,}", " ", corpus.tmp)
     corpus.tmp <- str_trim(corpus.tmp, side = "both")
     Corpus <- lapply(
          corpus.tmp, function(x){
               x <- as.String(x)
          }
     )
     sent_token_annotator <- Maxent_Sent_Token_Annotator()
     word_token_annotator <- Maxent_Word_Token_Annotator()
     pos_tag_annotator <- Maxent_POS_Tag_Annotator()
     lapply(
          Corpus, function(x){
               y1 <- annotate(x, list(sent_token_annotator , word_token_annotator))
               y2<- annotate(x, pos_tag_annotator , y1)
               y2w <- subset(y2, type == "word")
               tags <- sapply(y2w$features , '[[', "POS")
               r1 <- sprintf("%s/%s", x[y2w], tags)
               r2 <- paste(r1, collapse = " ")
               return(r2)
          }
     )
}



# load the data
ptm <- proc.time()
blogs <- readLines('data/out/clean_corpus.txt')

total_samples <- length(blogs) + length(news) + length(twitter)
blog_thoughts <- unlist( strsplit( tolower(blogs), '\\,\\s*|\\.\\s*|\\?\\s*|\\!\\s*', perl=T ) )


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
saveRDS( all_ngrams, 'data/evaluated/analyzed_ngrams.rds' )
print(proc.time() - ptm)
print('saved to file ... and done')
