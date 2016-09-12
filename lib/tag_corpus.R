library(koRpus)

text.tagged <- treetag(
     "data/out/clean_corpus.txt",
     treetagger = "manual",
     lang="en",
     TT.options = list(
          path="~/R",
          preset="en"
     )
)


