data_source <- 'data/out/clean_corpus.txt'
bigram_result <- 'data/evaluated/sample_bigrams.csv'
trigram_result <- 'data/evaluated/sample_trigrams.csv'
corpus_stats_result <- 'data/evaluated/bigram_and_trigram_stats.csv'
corpus <- readLines( data_source )

# for display purposes
specify_decimal <- function(x, k) format(round(x, k), nsmall=k)

# take just a subset of the lines, across all sources
corpus <- sample( corpus, 250000 )

# make space to record some things
bigrams <- character()
trigrams <- character()
tc <- 0
lc <- 0

# first attempt; the most manual way possible...
for ( line in corpus ) {
     
     # count lines read
     lc <- lc + 1
     percent_done <- specify_decimal( (100 / length(corpus) ) * lc, 2 )
     
     words <- unlist( strsplit( line, " " ) )
     for ( n in 2:length(words) ) {
          
          # if any of these three cross a 10k barrier, we want to know
          report <- FALSE
          
          # then a bigram, if available
          if (n > 2) {
               bigram <- paste( words[(n-1):n], collapse=" " )
               bigrams <- c( bigrams, bigram )
               tc <- tc + 1
               if (!tc %% 10000) { report <- TRUE }
          }
          
          # and, finally, a trigram, if available
          if (n > 3) {
               trigram <- paste( words[(n-2):n], collapse=" " )
               trigrams <- c( trigrams, trigram )
               tc <- tc + 1
               if (!tc %% 10000) { report <- TRUE }
          }
          
          # now keep us in the loop, yo
          if ( report ) {
               print( paste( 
                    as.integer( ( tc / 1000 ) ), 
                    "k n-gram tallies complete; ",
                    percent_done,
                    "% done at ",
                    lc,
                    " lines processed",
                    sep=""
               ) )
          }
     }
}

# now, format and save out the results for bigrams
unique_bigrams <- unique(bigrams)
bigram_counts <- matrix( ncol=1, nrow=length(unique_bigrams) )
rownames(bigram_counts) <- unique_bigrams

# now count the bigrams
wc <- 0
tc <- length(unique_bigrams)

for ( bigram in bigrams ) {
     wc <- wc + 1
     if ( is.na( bigram_counts[bigram,] ) ) {
          bigram_counts[bigram,] <- 1
     } else {
          bigram_counts[bigram,] <- bigram_counts[bigram,] + 1
          #print( paste( 'bigram "', bigram, '" has been encountered more than once', sep="") )
     }
     if ( !wc %% 10000 ) {
          print( paste( 
               as.integer( ( wc / 1000 ) ), 
               "k bigram tallies complete; ",
               specify_decimal( (100 / tc) * wc, 2 ),
               "% done at ",
               wc,
               " bigrams out of ",
               tc,
               sep=""
          ) )
     }
}

# now reformat for saving
bigram_counts <- as.data.frame( bigram_counts )
bigram_counts$bigram <- rownames( bigram_counts )
colnames(bigram_counts) <- c('count','bigram')
write.csv(bigram_counts, bigram_result, row.names=F )

# and finally for trigrams
unique_trigrams <- unique(trigrams)
trigram_counts <- matrix( ncol=1, nrow=length(unique_trigrams) )
rownames(trigram_counts) <- unique_trigrams

# count the trigrams, ad nauseam
wc <- 0
tc <- length(trigrams)

for ( trigram in trigrams ) {
     wc <- wc + 1
     if ( is.na( trigram_counts[trigram,] ) ) {
          trigram_counts[trigram,] <- 1
     } else {
          trigram_counts[trigram,] <- trigram_counts[trigram,] + 1
     }
     if ( !wc %% 10000 ) {
          print( paste( 
               as.integer( ( wc / 1000 ) ), 
               "k trigram tallies complete; ",
               specify_decimal( (100 / tc) * wc, 2 ),
               "% done at ",
               wc,
               " trigrams out of ",
               tc,
               sep=""
          ) )
     }
}

# now reformat for saving
trigram_counts$trigram <- rownames( trigram_counts )
trigram_counts <- as.data.frame( trigram_counts )
colnames(trigram_counts) <- c('count','trigram')
write.csv( trigram_counts, trigram_result, row.names=F )

# and lets just spit out some stats, too
all_stats <- data.frame(
     "total_lines_studied"=length(corpus),
     "total_bigrams"=length(bigrams),
     "total_unique_bigrams"=length(unique_bigrams),
     "total_trigrams"=length(trigrams),
     "total_unique_trigrams"=length(unique_trigrams),
     stringsAsFactors=F
)
write.csv( all_stats, corpus_stats_result, row.names=F )

print("done")