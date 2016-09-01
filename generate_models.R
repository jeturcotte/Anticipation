data_source <- 'data/in'
data_result <- 'data/out'
blogs <- readLines(paste(data_source, 'en_US.blogs.txt', sep='/'))
news <- readLines(paste(data_source, 'en_US.news.txt', sep='/'))
twitter <- readLines(paste(data_source, 'en_US.twitter.txt', sep='/'))

# smash all three into one ridiculously massive (and yet small) corpus
corpus <- c(blogs, news, twitter)
rm(blogs)
rm(news)
rm(twitter)

# lets first create a tidy data 'barrel' for this, first...
ngrams <- data.frame(
     "tri"=character(),
     "bi"=character(),
     "uni"=character(),
     "next"=character(),
     "pop"=integer(),
    stringsAsFactors=F
)

count <- 0

# first attempt; the most manual way possible...
for ( line in corpus ) {
     
     # we're including subsections of sentences here, too, since they generally do infer
     # that there's a logical separation of concepts even between commas in a long run-on sentence, too
     thoughts <- strsplit( tolower(line), '\\,\\s*|\\.\\s*|\\?\\s*|\\!\\s*', perl=T )
     for ( thought in thoughts ) {
          words <- unlist( 
               strsplit( 
                    gsub( pattern="[[:punct:]]", phrase, replacement="" ),
                    " "
               )
          )
          words <- words[words != '']
          
          
          
          if ( length(words) > 3 ) {
               for ( i in 4:length(words) ) {
                    record <- c(
                         words[i-3],
                         words[i-2],
                         words[i-1],
                         words[i]
                    )
                    ngrams[nrow(ngrams)+1,] <- record
               }
          }
     }
}