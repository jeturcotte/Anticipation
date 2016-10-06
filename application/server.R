library(shiny)
library(quanteda)
library(data.table)

findings <- function( text_so_far ) {
     
     tokens <- unlist(
          tokenize(
               tolower(text_so_far),
               removeNumbers = T,
               removePunct = T,
               removeSeparators = T,
               removeTwitter = T,
               verbose = F
          )
     )
     results <- data.table()
     
     # look for all depths
     penta <- paste( tail(tokens,n=5), collapse=" " )  # intended to know some common catch phrases
     tetra <- paste( tail(tokens,n=4), collapse=" " )  # intended to know some short catch phrases
     tri <- paste( tail(tokens,n=3), collapse=" " )    # more likely to at least be able to follow grammar
     bi <- paste( tail(tokens,n=2), collapse=" " )     # may be able to handle some grammar
     uni <- paste( tail(tokens,n=1), collapse=" " )    # if all else fails
     
     # snag the whole resultset
     model[ model$observed %in% c(penta,tetra,tri,bi,uni), ]
     
}

choices <- function( results ) {
     
     if(!nrow(results)){ return(c('NA','NA','NA'))}
     results <- aggregate( score ~ predicted, data=results, FUN=max)
     head(
          results[ order( results$score, decreasing=T ), ]$predicted,
          n=3
     )
     
}


# the data interpretation server itself
shinyServer( function( input, output, session ) {

     observeEvent(
          input$choice_1, {
               if( input$choice_1 > 0 ) {
                    results <- findings( input$anticipate_this )
                    if ( nrow(results) ){
                         selection <- choices(results)
                    }
                    newval <- paste(
                         input$anticipate_this,
                         selection[1],
                         sep=' '
                    )
                    updateTextInput(
                         session,
                         'anticipate_this',
                         label=NULL,
                         value=newval
                    )
               }
          }
     )
     
     # be on the lookout for changes from our input
     observe({
          
          results <- findings( input$anticipate_this )

          if( nrow(results) ) {
               selection <- choices( results )
               
               for ( bn in 1:3 ) {
                    
                    identity <- paste( 'choice', bn, sep="_" )
                    if ( nrow(results) >= bn ) {
                         
                         message( sprintf( '%s: %s', identity, selection[bn] ) )
                         updateActionButton(
                              session,
                              identity,
                              label=selection[bn]
                         )

                    } else {
                         
                         updateActionButton(
                              session, identity, label='N/A'
                         )
                        
                    }
                    
               }
               
          }
          
          
     })
  
})
