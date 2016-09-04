setwd("~/R/PROJECTS/Anticipation")

data_source <- 'data/in/'
data_result <- 'data/evaluated/'
corpus_type <- 'twitter'
corpus <- readLines( paste( data_source, 'en_US.', corpus_type, '.txt', sep='' ), n=250000 )
corpus_words_file <- paste( data_result, corpus_type, '_words.csv', sep='' )
corpus_stats_file <- paste( data_result, corpus_type, '_stats.csv', sep='' )

# for display purposes
specify_decimal <- function(x, k) format(round(x, k), nsmall=k)

just_the_words <- character()

# first clean up the entire thing
lc <- 0
for (line in corpus) {
     thoughts <- unlist( strsplit( tolower(line), '\\,\\s*|\\.\\s*|\\?\\s*|\\!\\s*', perl=T ) )
     thoughts <- gsub( pattern="[[:punct:]]", thoughts, replacement="" )
     words <- unlist( strsplit( thoughts, " " ))
     just_the_words <- c( just_the_words, words )
     lc <- lc + 1
     if ( !lc %% 10000 ) {
          print( paste (
             lc, 'lines processed', sep=" "  
          ) )
     }
}

# winnow down list of words used to unique ones
# and pre-allocate a matrix for efficiency
unique_words <- unique(just_the_words)
counts <- matrix( ncol=1, nrow=length(unique_words) )
rownames(counts) <- unique_words

# count 'em all!

wc <- 0
tc <- length(just_the_words)

for ( word in just_the_words ) {
     if ( word=='' ) { next }
     wc <- wc + 1
     if ( is.na(counts[word,]) ) {
          counts[word,] <- 1
     } else {
          counts[word,] <- counts[word,] + 1
     }
     if ( !wc %% 10000 ) {
          print( paste( 
               as.integer( ( wc / 1000 ) ), 
               "k word tallies complete; ",
               specify_decimal( (100 / tc) * wc, 2 ),
               "% done at ",
               wc,
               " words out of ",
               tc,
               sep=""
          ) )
     }
}

# now reformat for saving
counts <- as.data.frame( counts )
counts$word <- rownames(counts)
write.csv(counts, corpus_words_file, row.names=F )

# and some rough stats
all_stats <- data.frame(
     "total_entries"=length(corpus),
     "total_words"=length(just_the_words),
     "unique_words"=length(unique_words),
     stringsAsFactors=F
)
write.csv(all_stats, corpus_stats_file, row.names=F )

print("done")