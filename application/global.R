library(shiny)
library(quanteda)
library(data.table)

model <- readRDS('model.rds')
message('model loaded')