setwd("~/R/PROJECTS/Anticipation")

data_source <- 'data/in'
data_result <- 'data/out'
blogs <- readLines( paste( data_source, 'en_US.blogs.txt', sep='/' ) )
news <- readLines( paste( data_source, 'en_US.news.txt', sep='/' ) )
twitter <- readLines( paste( data_source, 'en_US.twitter.txt', sep='/' ) )
out_blogs <- paste( data_result, 'clean_blogs.txt', sep="/" )
out_news <- paste( data_result, 'clean_news.txt', sep="/" )
out_twitter <- paste( data_result, 'clean_twitter.txt', sep="/" )

count <- 0

# first attempt; the most manual way possible... just clean the corpus up
for ( line in blogs ) {
     
     thoughts <- strsplit( tolower(line), '\\.\\s*|\\?\\s*|\\!\\s*', perl=T )
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
                    write( paste( words, collapse=" " ), out_blogs, append=FALSE )
               } else {
                    write( paste( words, collapse=" " ), out_blogs, append=TRUE )
               }
               count <- count + 1
          }

          if (!count %% 10000) {
               print( paste( count, "items have been written to blog file" ) )
          }
     }
}
print("done")

count <- 0

for ( line in news ) {
     
     thoughts <- strsplit( tolower(line), '\\.\\s*|\\?\\s*|\\!\\s*', perl=T )
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
                    write( paste( words, collapse=" " ), out_news, append=FALSE )
               } else {
                    write( paste( words, collapse=" " ), out_news, append=TRUE )
               }
               count <- count + 1
          }
          
          if (!count %% 10000) {
               print( paste( count, "items have been written to news file" ) )
          }
     }
}

count <- 0

for ( line in twitter ) {
     
     thoughts <- strsplit( tolower(line), '\\.\\s*|\\?\\s*|\\!\\s*', perl=T )
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
                    write( paste( words, collapse=" " ), out_twitter, append=FALSE )
               } else {
                    write( paste( words, collapse=" " ), out_twitter, append=TRUE )
               }
               count <- count + 1
          }
          
          if (!count %% 10000) {
               print( paste( count, "items have been written to twitter file" ) )
          }
     }
}

