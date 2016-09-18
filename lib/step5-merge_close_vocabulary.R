library(quanteda)
library(stringr)
library(dplyr)
library(data.table)

setwd("~/R/PROJECTS/Anticipation")

proc_time <- proc.time()
blogs <- readRDS('dat/close/blogs.rds')
news <- readRDS('dat/close/news.rds')
dest <- 'dat/close/all_stemmed.rds'
merged <- aggregate( frequency ~ observed, data=rbind( blogs, news ), FUN=sum )
message( sprintf( ' - merged blogs and news stemmed vocabularies with %d acceptable unigrams', nrow(merged) ) )
saveRDS( merged, dest )
message( sprintf( ' - saved to < %s >\n\n', dest ) )
