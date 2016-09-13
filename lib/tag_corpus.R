library(koRpus)

src <- 'data/out/'
dest <- 'data/evaluated/'

for( filename in list.files( src ) ) {
     
     if ( grepl('testing', filename) ) {
          message( sprintf( 'skipping test file: %s', filename ) )
          next
     }
     
     stem <- gsub( '\\.txt', '', filename )
     infile <- sprintf( '%s%s', src, filename )
     outfile <- sprintf( '%s%s.rds', dest, stem )
     
     message( sprintf( 'loading file: %s', infile ) )
     ptm <- proc.time()
     text.tagged <- treetag(
          infile,
          treetagger = "manual",
          lang="en",
          TT.options = list(
               path="~/R",
               preset="en"
          )
     )
     
     message( sprintf( 'saving file: %s', outfile ) )
     saveRDS( text.tagged, outfile )
     print( proc.time() - ptm )
     
}





