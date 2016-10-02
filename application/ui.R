library(shiny)

shinyUI(

     bootstrapPage(
          
          title = "Text Anticipation",
          theme = 'darkly.css',
         div(
               style="padding-left:10px; color: #EA1; background-color: #000",
               h1('TEXT ANTICIPATION')
          ),
          absolutePanel(
               top = 100,
               left = 100,
               textInput(
                    inputId = 'anticipate_this',
                    label = NULL,
                    placeholder = 'begin typing:',
                    width = "600px"
               ),
               div(
                    style="padding-left:35px;",
                    div(
                         style="display:inline-block; width:300px",
                         h3(
                              'prediction: '
                         )
                    ),
                    div(
                         style="display:inline-block",
                         actionButton(
                              "choice_1",
                              "N/A",
                              width = '220px',
                              class = 'btn-lg btn-success'
                         )
                    )
               ),
               div(
                    style="padding-left:35px;",
                    div(
                         style="display:inline-block; width:300px",
                         h4(
                              '2nd most likely: '
                         )
                    ),
                    div(
                         style="display:inline-block",
                         actionButton(
                              "choice_2",
                              "N/A",
                              width = '220px',
                              class = 'btn-sm btn-success disabled'
                         )
                    )
               ),
               div(
                    style="padding-left:35px;",
                    div(
                         style="display:inline-block; width:300px",
                         h5(
                              '3rd most likely: '
                         )
                    ),
                    div(
                         style="display:inline-block",
                         actionButton(
                              "choice_3",
                              "N/A",
                              width = '220px',
                              class = 'btn-xs btn-success disabled'
                         )
                    )
               ),
               h5('It may take a moment for supporting data to load into memory...')
               
          )
          
     )

)
