## server.R

library(shiny)
library(tiff)
library(ggvis)
library(RANN)

shinyServer(function(input, output, session) {

  # Read in image files or create randoms for init
  img1 <- reactive({
      cat("===Inside img1\n")
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
      cat("===Inside img2\n")
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

  # Calculate NN
  nns <- reactive({
      cat("===Inside nns\n")

      input$updateButton

      im1 <- img1()
      im2 <- img2()
      if (dim(im1)[1] != dim(im2)[1] || dim(im1)[2] != dim(im2)[2]){
        cat(paste("!!=== Images are different sizes =====\n"))
        # TODO: Open error message
        # TODO: Return empty matrix
      }
      
      # Isolate from the change in files so that it doesn't recalculate when
      # one image is chosen
      isolate(coords1 <- which(img1()==1, arr.ind=TRUE))
      isolate(coords2 <- which(img2()==1, arr.ind=TRUE))

      # Calculate NN
      # nn2() returns a list whose second element is a matrix with k columns
      # with the Euclidean distances to the k-nearest neighbours (k=1). Each
      # row is one pixel in file 1.
      nns <- as.data.frame(nn2(coords2, coords1, k=1, searchtype="standard", eps=0)[[2]])
      colnames(nns) <- c("Distance")

      return(nns)
  })

  # Raster images of the inputs
  output$raster1 <- renderPlot({
      cat("===renderPlot for raster1\n")
      image(as.matrix(img1()), col=c("black", "magenta"), main="TIFF file 1")
  })

  output$raster2 <- renderPlot({
      cat("===renderPlot for raster2\n")
      image(as.matrix(img2()), col=c("black", "green"), main="TIFF file 2")
  })
  
  output$raster3 <- renderPlot({
      cat("===renderPlot for raster3\n")
      input$updateButton
      isolate(mat1 <- img1())
      isolate(mat2 <- img2())
      # TODO: make it dependent on "nns" function, and check the error there?
      mat2[mat2==1] <- 2
      img <- mat1 + mat2
      if (max(img) == 3) {
        colors <- c("black", "magenta", "green", "white")
      } else {
        colors <- c("black", "magenta", "green")
      }

      image(as.matrix(img), col=colors, main="Merge")
  })

  
  # Render dist table
  output$table <- renderTable({
      cat("===Inside renderTable for output$distTable\n")

      input$updateButton

      nns <- isolate(nns())

      return(nns)
  })

  output$downloadLink <- downloadHandler(
      filename = function() {
          paste("data-", Sys.Date(), ".csv", sep="")
      },
      content = function(file) {
          write.csv(isolate(nns()), file=file, quote=F, row.names=F)
      }
  )

  vis_hist <- reactive({
      cat("===Inside var_hist\n")

      input$updateButton

      nns <- isolate(nns())

      # Plot histogram with ggvis
      p <- nns %>%
            ggvis(~Distance) %>%
            layer_histograms(width = input$binwidth, closed = "left", boundary = 0,
                             fillOpacity := 0.2, fillOpacity.hover := 0.5) %>%
            add_tooltip(function(df) (paste("count:", df$stack_upr_ - df$stack_lwr_))) %>%
            set_options(width = "auto", height = 500) %>%
            add_axis("x", title = "Euclidean distance") %>%
            add_axis("y", title = "Count")

  })

  vis_hist %>% bind_shiny("gghist")

})
