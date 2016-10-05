--- 
title       : Text Anticipation
subtitle    : A Modest Effort in Text Prediction
author      : J.E. Turcotte
job         : 
framework   : io2012   
highlighter : highlight.js 
hitheme     : tomorrow
widgets     : []           
mode        : selfcontained 
knit        : slidify::knit2slides
--- 

## A Simple Application

* With this, I present a simple text prediction application
  * found at https://jeturcotte.shinyapps.io/TextAnticipation/
* The idea behind this application is to parse words up to the point where text has left off, and offer the most likely word to follow.
* Its use is simple enough; Begin by typing and, if you like, pause long enough for the application to guess.
* It will offer the most likely next word and even let you click on that word to append it to the sentence.
  * given that many applications offer more than one possibility, I also include what those might be
* The result can be quite hilarious, actually, if you start it off and just let the predictive model jabber away.

---

## A Quick Look at the Guts

* For this project, a modestly large corpus was provided -- Blogs, News Articles and a slew of Tweets.
* These were broken down into roughly 8.1 million individual sentences, which then were reinterpreted as chains of ngrams.

---

## Method to the Madness

Interestingly enough, it looks as though D.C. more than recovered from the housing/banking crisis, while my native state *seems* to have fallen into a second pitfall, probably due to globalism.


```
## Error in file(file, "rt"): cannot open the connection
```

```
## Error in melt(psf, id.vars = do_not_melt, variable.name = "Date", value.name = "MeanPrice"): object 'psf' not found
```

```
## Error in paste(psf$Date, "01"): object 'psf' not found
```

```
## Error in colnames(psf)[2] <- "State": object 'psf' not found
```

```
## Error in eval(expr, envir, enclos): object 'psf' not found
```

```
## Error in subset(psf, State %in% c("District of Columbia", "Virginia", : object 'psf' not found
```

```
## Error in ggplot(my_states, aes(Date, MeanPrice)): object 'my_states' not found
```

```
## Error in eval(expr, envir, enclos): object 'psf_plot' not found
```

```
## Error in eval(expr, envir, enclos): object 'psf_plot' not found
```

```
## Error in eval(expr, envir, enclos): object 'psf_plot' not found
```

Sadly, even as the jobs are being pulled into the cities, this one, at least, appears to be accelerating away from affordability.  The ratio in difference between the four in 2000 is significantly less acute than in 2015.

---

## A Quick Look across the Lower 48

![A Screenshot of Per-Square-Foot](assets/img/screenshot.png)

Thus, I introduce the first rudimentary version of the [Per Square Foot](https://jeturcotte.shinyapps.io/per-square-foot/) application which, for now, shows the mean square foot price for housing across most of the lower 48 states, both in the dollars of the time, and adjusted to the value of the 2016 dollar.

---

## Future Upgrades

* Would be nice to add similar breakdown by county, by zipcode, metro area, et cetera.
* Would be nice to offer a trend plot for the entire nation as a time series, and extrapolate into the future with predictions
* Would be nice to offer a trend plot, per state or other regionality, perhaps even in each popup, of the same information
* Would be nice to map out the mean price per square foot as a function of local cost of living and wages (affordability.)
* Would be nice to make similar chart based on rent instead of purchase cost.


