setwd("~/R/PROJECTS/Anticipation")

data_source <- 'data/in'
data_result <- 'data/out'
blogs <- readLines( paste( data_source, 'en_US.blogs.txt', sep='/' ) )
news <- readLines( paste( data_source, 'en_US.news.txt', sep='/' ) )
twitter <- readLines( paste( data_source, 'en_US.twitter.txt', sep='/' ) )
out_file <- paste( data_result, 'clean_corpus.txt', sep="/" )

# smash all three into one ridiculously massive (and yet small) corpus
corpus <- c(blogs, news, twitter)
rm(blogs)
rm(news)
rm(twitter)

print("corpuses combined")
print( paste( length(corpus), "lines to be processed" ) )

count <- 0

# first attempt; the most manual way possible... just clean the corpus up
for ( line in corpus ) {
     
     # we're including subsections of sentences here, too, since they generally do infer
     # that there's a logical separation of concepts even between commas in a long run-on sentence, too
     thoughts <- strsplit( tolower(line), '\\,\\s*|\\.\\s*|\\?\\s*|\\!\\s*', perl=T )
     for ( thought in unlist(thoughts) ) {
          words <- unlist( 
               strsplit( 
                    gsub( pattern="[[:punct:]]", thought, replacement="" ),
                    " "
               )
          )
          words <- words[words != '']
          if (length(words) > 1) {
               if (count == 0) {
                    write( paste( words, collapse=" " ), out_file, append=FALSE )
               } else {
                    write( paste( words, collapse=" " ), out_file, append=TRUE )
               }
               count <- count + 1
          }

          if (!count %% 10000) {
               print( paste( count, "items have been written to file" ) )
          }
     }
}
print("done")