========
NN-pixel
========

Shiny app to find nearest-neighbour pixels for co-localisation studies in fluorescent microscopy.


------------------
How to run the app
------------------

Start an R session in the folder where the ui.R and server.R files are located.

> library(shiny)
> runApp()


---------------------
How to deploy the app
---------------------

Log in into your shinyapps.io account and under your user, choose "Tokens".
Retrieve your token.
Open an R session where the ui.R and server.R files are located.

> install.packages('rsconnect')
> library('rsconnect')
> setAccountInfo(name="<ACCOUNT>", token="<TOKEN>", secret="<SECRET>")
> deployApp()

The "setAccountInfo" command is only needed the first time.

