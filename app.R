################################################################################
# entry point of the Shiny app
#
# Author: GOMES Michel
# Created: 04-10-2022 
################################################################################
library(shiny)
library(shiny.router)
setwd(".")
#library(shinydashboard)
library(tidyverse)
library(Seurat)
library(CellChat)
library(patchwork)
library(shinyjs)
options(stringsAsFactors = FALSE)
library(DT)
setwd(".")
source("server.R")
source("ui.R")

shinyApp(ui, server)