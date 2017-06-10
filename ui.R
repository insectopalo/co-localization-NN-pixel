## ui.R

library(shiny)
library(ggvis)

shinyUI(fluidPage(

  titlePanel("NN-pixel"),

  fluidRow(
           column(3,
                  wellPanel(
                            h3("File input"),
                            tags$small(paste0(
                              "Click on \"Browse...\" to select the TIFF images to ",
                              "analyze.\n",
                              "For each non-black pixel of the first image, the ",
                              "distance with its exact nearest-neighbor from the ",
                              "second image will be computed.\n",
                              "Click on \"Update!\" to run the analysis and plot the histogram ",
                              "of distances." )
                            ),

                            br(),
                            br(),

                            fileInput("file1", "Choose TIFF file 1",
                                      accept = c("image/tiff", "image/x-tiff", ".tif", ".tiff")),
                            fileInput("file2", "Choose TIFF file 2",
                                      accept = c("image/tiff", "image/x-tiff", ".tif", ".tiff")),
                            actionButton("updateButton", "Update!")
                  )
           ),
           column(9,
                  column(4, plotOutput("raster1")),
                  column(4, plotOutput("raster2")),
                  column(4, plotOutput("raster3"))
           )
  ),
  fluidRow(
           column(3,
                  wellPanel(
                            h3("Display"),
                            tags$small(paste0(
                              "Change the bin width using the slider.")
                            ),
                            br(),
                            br(),
                            sliderInput("binwidth", "Bin width:", min = 1, max = 20, value = 1),
                            br()
                  ),
                  wellPanel(
                            h3("Download"),
                            tags$small(paste0(
                              "Download the Euclidean distances using the button below.\n",
                              "To save the histogram generated, click on the gear icon on its top-right corner.")
                            ),
                            br(),
                            br(),
                            downloadButton("downloadLink", "Download CSV")
                  )
           ),
           column(6,
                  ggvisOutput("gghist")
                  #plotOutput("hist")
           )
  )
))

