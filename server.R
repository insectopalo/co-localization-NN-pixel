## server.R

library(shiny)
library(tiff)
library(ggvis)
library(RANN)

shinyServer(function(input, output, session) {


  output$txt <- renderText({
      #"Halla!"
  })


  # Read in image files or create randoms for init
  img1 <- reactive({
      if (is.null(input$file1)) {
          img <- matrix(rbinom(10000, 1, 0.01), 100, 100)
      } else {
          img <- readTIFF(input$file1$datapath)
          if (dim(img)[3] > 3) {
              cat(paste("The image is not RGB, dropping the other layers", "\n"))
              img <- img[,,1:3]
          }
          img <- apply(img, c(1,2), sum)
          img[img[,] > 0] <- 1
      }
      return(img)
  })

  img2 <- reactive({
      if (is.null(input$file2)) {
          img <- matrix(rbinom(10000, 1, 0.01), 100, 100)
      } else {
          img <- readTIFF(input$file2$datapath)
          if (dim(img)[3] > 3) {
              cat(paste("The image is not RGB, dropping the other layers", "\n"))
              img <- img[,,1:3]
          }
          img <- apply(img, c(1,2), sum)
          img[img[,] > 0] <- 1
      }
      return(img)
  })

  # Raster images of the inputs
  output$raster1 <- renderPlot({
      cat("Rendering plot\n")
      t <- h1()
      cat(paste("Return value:", t, "\n"))
      img <- as.matrix(img1())
      image(img, col=c("black", "magenta"), main="TIFF file 1")
  })

  output$raster2 <- renderPlot({
      image(as.matrix(img2()), col=c("black", "green"), main="TIFF file 2")
  })
  
  output$raster3 <- renderPlot({
      input$updateButton
      isolate(mat1 <- img1())
      isolate(mat2 <- img2())
      # TODO: error if imgs are different sizes
      mat2[mat2==1] <- 2
      img <- mat1 + mat2

      image(as.matrix(img), col=c("black", "magenta", "green", "white"), main="Merge")
  })


  vis_hist <- reactive({

      input$updateButton

      isolate(coords1 <- which(img1()==1, arr.ind=TRUE))
      isolate(coords2 <- which(img2()==1, arr.ind=TRUE))

      nns <- as.data.frame(nn2(coords2, coords1, k=1, searchtype="standard", eps=0)[[2]])

      # Plot histogram with ggvis
      nns %>%
          ggvis(~V1) %>%
          layer_histograms(width = input$binwidth, closed = "left", boundary = 0,
                           fillOpacity := 0.2, fillOpacity.hover := 0.5) %>%
          add_tooltip(function(df) (paste("count:", df$stack_upr_ - df$stack_lwr_))) %>%
          set_options(width = "auto", height = 500) %>%
          add_axis("x", title = "Euclidean distance") %>%
          add_axis("y", title = "Count")

  })

  vis_hist %>% bind_shiny("gghist")

  #output$hist <- renderPlot({
  #    input$updateButton
  #    # Check that images are the same size

  #    # Get coordinates of pixels
  #    isolate(coords1 <- which(img1()==1, arr.ind=TRUE))
  #    isolate(coords2 <- which(img2()==1, arr.ind=TRUE))

  #    # Find NNs
  #    nns <- nn2(coords2, coords1, k=1, searchtype="standard", eps=0)

  #    # Plot histogram
  #    hist(nns$nn.dists, col = 'darkgray', border = 'white')

  #})

})
