library(shiny)
library(quanteda)
library(data.table)

model <- readRDS('model.rds')
message('model loaded')

findings <- function( text_so_far ) {
     
     tokens <- unlist( tokenize( tolower( text_so_far ) ) )
     results <- data.table()
     
     # look for all depths
     tetra <- paste( tail(tokens,n=4), collapse=" " )
     tri <- paste( tail(tokens,n=3), collapse=" " )
     bi <- paste( tail(tokens,n=2), collapse=" " )
     uni <- paste( tail(tokens,n=1), collapse=" " )
     
     # snag the whole resultset
     model[ model$observed %in% c(tetra,tri,bi,uni), ]
     
}

choices <- function( results ) {
     
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
