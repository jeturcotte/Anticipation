Text Anticipation Application
========================================================
author: J.E. Turcotte
date: October 6, 2016

A Simple Application
========================================================

* With this, I present a simple text prediction application
  * found at https://jeturcotte.shinyapps.io/TextAnticipation/
* The idea behind this application is to parse words up to the point where text has left off, and offer the most likely word to follow
* Its use is simple enough; Begin by typing and, if you like, pause long enough for the application to guess
* It will offer the most likely next word and even let you click on that word to append it to the sentence
  * given that many applications offer more than one possibility, I also include what those might be

Preparing the Corpus
========================================================

* For this project, a modestly large corpus was provided -- Blogs, News Articles and a large slew of Tweets
* These were broken down into roughly 8.1 million individual sentences
* These had several passes of repair made... 
  * Numbers and Punctuation and Twitter handles were removed
  * Along with frequent abuses of excess whitespace
  * Anything inside parentheses or brackets were removed, as being potentially interruptive to otherwise cohesive phraseology
  * So also were run-on button smashes, like 'aaaaaaaaaaaaahhhh', reduced simply to 'ah'
  * Various common titles, like capt., mr., mrs., et cetera were normalized

Method AND Madness
========================================================

![plot of chunk unnamed-chunk-1](presentation-figure/unnamed-chunk-1-1.png)

Results
========================================================

![plot of chunk unnamed-chunk-2](presentation-figure/unnamed-chunk-2-1.png)
