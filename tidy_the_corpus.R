setwd("~/R/PROJECTS/Anticipation")

separate_sentences <- function( corpus ) {
     message('breaking corpus down into individual sentence')
     return(
          unlist(
               strsplit( corpus, '(?<![^!?.])\\s+', perl=T )
          )
     )
}

change_whitespace_to_space <- function( corpus ) {
     message('simplifying white space usage')
     return(
          gsub( "[[:space:]]", " ", corpus )
     )
}

expand_common_full_stops <- function( corpus ) {
     message('expanding common full stops')
     corpus <- gsub( "mr.", "mister", corpus, ignore.case=TRUE )
     corpus <- gsub( "mrs.", "missus", corpus, ignore.case=TRUE )
     corpus <- gsub( "dr.", "doctor", corpus, ignore.case=TRUE )
     corpus <- gsub( "prof.", "professor", corpus, ignore.case=TRUE )
     corpus <- gsub( "capt.", "captain", corpus, ignore.case=TRUE )
} 

clean_sentences <- function( corpus ) {
     message('cleaning corpus of rare complexities, incuding content in parentheses')
     corpus <- gsub( " *\\(.*?\\) *", "", corpus)
     corpus <- gsub( " *\\[.*?\\] *", "", corpus)
     # what about ... elipses?
     return(
          gsub( "[^[:alnum:], '?!.-;:]", "", corpus)
     )
}

process_corpus <- function( type, src='data/in' ) {
     filename <- sprintf( '%s/en_US.%s.txt', src, type )
     message( sprintf( 'processing file: %s', filename ) )
     corpus <- readLines( filename )
     corplen <- length( corpus )
     corpus <- expand_common_full_stops (
          change_whitespace_to_space (
               clean_sentences(
                    corpus
               )
          )
     )
     corpus <- separate_sentences( corpus )
     message( sprintf( 'broken %d lines in original corpus to %d simplified new lines', corplen, length(corpus) ) )
     return( corpus )
}

parse_corpus_to_chunked_files <- function( type, chunksize=100000, dest='data/out' ) {
     corpus <- process_corpus( type )
     corplen <- length( corpus )
     corpus <- split( corpus, ceiling( seq_along( corpus ) / chunksize ) )
     for( clabel in labels( corpus ) )  {
          chunk <- corpus[[clabel]]
          if ( length(chunk) < chunksize ) {
               filename <- sprintf( '%s/%s.%s.txt', dest, type, 'testing' )
          } else {
               filename <- sprintf( '%s/%s.%s_%s.txt', dest, type, 'training', clabel )
          }
          writeLines( chunk, filename )
          message( sprintf( 'saved %s to disk for later stages of processing', filename ) )
     }
}

for( type in c( 'blogs', 'news', 'twitter' ) ) {
     message( sprintf( 'importing %s-type corpus', type ) )
     parse_corpus_to_chunked_files( type )
}