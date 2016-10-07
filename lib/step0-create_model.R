setwd("~/R/PROJECTS/Anticipation")

source('lib/step1-clean_corpus.R')
source('lib/step2-extract_intact_ngrams.R')
#source('lib/step3-extract_ngrams_without_stopwords.R')     # deemed useless at this stage
source('lib/step4-compile_close_vocabulary.R')
source('lib/step5-merge_close_vocabulary.R')
source('lib/step6-collate_ngrams_categorically.R')
source('lib/step7-reduce_ngrams_to_models.R')
source('lib/step8-render_final_model.R')
source('lib/step9-test_model.R')