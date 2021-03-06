# ************************************************
### simon munzert
### time series
# ************************************************

source("packages.r")
source("functions.r")


## CRAN Task View on time series analysis
browseURL("https://cran.r-project.org/web/views/TimeSeries.html")


# ************************************************
# Working with times using the lubridate package -

library(lubridate)

# create a year-month-day variable
dates_char <- c("2017-09-01", "2017-08-31", "2017-08-30")
#dates_char <- c("20170901", "20170831", "20170830")
#dates_char <- c("2017/09/01", "2017/08/31", "2017/08/30")
class(dates_char)
dates <- ymd(dates_char) # ymd() function to deal with year-month-day input
dates
plot(dates)

# other formats work, too
mdy("09-24-2017")
dmy("24.09.2017")

# there are many other things you can do with the package, for instance
  # work with time zones
  # compute time intervals
  # do arithmetic with date times (durations, periods)

# check out the following vignette for more info!
browseURL("https://cran.r-project.org/web/packages/lubridate/vignettes/lubridate.html")



# ************************************************
# Managing time series data with the xts package -

library(xts) # also loads zoo package

# import fertility data from Wooldridge
?fertil3
names(fertil3)
View(fertil3)
dat <- fertil3

# plot time series
plot(dat$gfr)

# create xts time series object
dat_ts <- ts(dat, frequency = 1, start = 1913) # create time-series object: provide time of the first observation and frequency 
dat_xts <- as.xts(dat_ts)

# dat_xts <- xts(dat, yearmon(dat$year)) # alternative assignment of time scheme with yearmon() function from the zoo package
plot(dat_xts$gfr)

# create lag variables
dat$gfr
dplyr::lag(dat$gfr, 1)
dplyr::lag(dat$gfr, 2)
dplyr::lead(dat$gfr, 1)



# ************************************************
# Exercise: The Efficient Markets Hypothesis -----

data(nyse)
?nyse

# plot time series
plot(nyse$price, type = "l")
plot(nyse$return, type = "l")

# do past returns help explain future returns?
summary(lm(return ~ dplyr::lag(return), data = nyse))

# assess autocorrelation
acf(nyse$return, na.action = na.pass)
acf(nyse$price, na.action = na.pass, lag.max = 20)

# assess partial autocorrelation
pacf(nyse$return, na.action = na.pass)
pacf(nyse$price, na.action = na.pass)

# assess autocorrelation in residuals using the Durbin-Watson test for autocorrelation
model <- lm(price ~ lag(price), data = nyse)
summary(model)
dwtest(model) # be careful: in LDV models the DW test statistic tends to underestimate autocorrelation

# Augmented Dickey-Fuller test
adf.test(nyse$return[-1])
plot(nyse$t, nyse$return, type = "l")

# How does the Dickey-Fuller test work?
  # tests the predictive power of an autoregressive process on the integrated time series
  # the null hypothesis for the test is that the time-series has a unit root (i.e. is not stationary).
  # the more negative it is, the stronger the rejection of the hypothesis that there is a unit root at some level of confidence
x <- rnorm(1000)  # no unit-root = stationary
adf.test(x)
y <- diffinv(x)   # contains a unit-root = non-stationary
adf.test(y)



# ************************************************
# Seasonal adjustment ----------------------------

unemp <- read_csv("../data/unemployment-ger-monthly.csv")
head(unemp)
names(unemp) <- c("month", "total")

unemp_ts <- ts(unemp$total, start=c(1948,1), frequency = 12)
plot(unemp_ts)
unemp_stl <- stl(unemp_ts, s.window = "periodic")
plot(unemp_stl)

summary(unemp_stl)
unemp_stl_df <- unemp_stl$time.series




# ************************************************
# Finite distributed lag (FDL) models ------------

# scatterplot
plot(dat$pe, dat$gfr)

# parallel time series
par(mfrow = c(2, 1))
plot(dat_xts$gfr)
plot(dat_xts$pe)

# OLS
model_out <- lm(gfr ~ pe, data = dat) # static model; only impact propensity assessed
summary(model_out)
model_out <- lm(gfr ~ pe + dplyr::lag(pe, 1) + dplyr::lag(pe, 2), data = dat) # assess long-run propensity with two lags
summary(model_out)



# ************************************************
# Lag dependent variable (LDV) models ------------

# check for autocorrelation
foo <- acf(dat$gfr, na.action = na.pass)
cor(dat$gfr, dplyr::lag(dat$gfr, 1), use = "pairwise.complete")
cor(dat$gfr, dplyr::lag(dat$gfr, 2), use = "pairwise.complete")
cor(dat$gfr, dplyr::lag(dat$gfr, 4), use = "pairwise.complete")
cor(dat$gfr, dplyr::lag(dat$gfr, 11), use = "pairwise.complete")
cor(dat$gfr, dplyr::lag(dat$gfr, 12), use = "pairwise.complete")

# build simple LDV model
summary(lm(gfr ~ dyplr::lag(gfr, 1) + dplyr::lag(gfr, 2), data = dat))



