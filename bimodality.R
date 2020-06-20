library("tidyverse")
library("readxl")
library("lubridate")
library("diptest")
library("nortest")
library("moments")

###############
## load data ##
###############

source("fake_data.R")

#####################
## calculate stats ##
#####################

stats = data %>%
  filter(!is.na(mark)) %>%
  group_by(institution, year, term, course) %>%
  ## ad.test sample size must be greater than 7
  filter(length(mark) > 7) %>%
  summarize(n = length(mark),
            mean = mean(mark),
            sd = sd(mark),
            kurtosis = kurtosis(mark),
            skewness = skewness(mark),
            ## Hartigans' Dip Test for Unimodality
            dip = dip.test(mark)[[1]],
            p_dip = dip.test(mark)[[2]],
            ## Shapiro-Wilk Normality Test
            shapiro = shapiro.test(mark)[[1]],
            p_shapiro = shapiro.test(mark)[[2]],
            ## Anderson-Darling test for normality
            ad = ad.test(mark)[[1]],
            p_ad = ad.test(mark)[[2]],
            log_shapiro = shapiro.test(log(mark))[[1]],
            p_log_shapiro = shapiro.test(log(mark))[[2]]) %>%
  ungroup()

#################################################
## bimodality (and other distributional) tests ##
#################################################

stats %>%
  group_by(institution) %>%
  summarise(percent_shapiro_rejected = mean(p_shapiro < 0.05) * 100,
            percent_dip_test_rejected = mean(kurtosis < 3 & p_dip < 0.05) * 100)

###################
## visualisation ##
###################

## theme_set(theme_gray(base_size = 25))

ggplot(data, aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  labs(title = "all marks")

ggplot(data, aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  facet_wrap(~institution) +
  labs(title = "marks by institution")

ggplot(data, aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  facet_wrap(~year) +
  labs(title = "marks by year")

ggplot(data, aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  facet_grid(institution~year) +
  labs(title = "marks by year & institution")

## this won't really be useful for the fake data (since the distributions don't
## change year-to-year) but it might be interesting for real data

ggplot(data, aes(year, mark)) +
  geom_point(alpha = 0.01) +
  geom_smooth(method = "lm") +
  facet_wrap(~institution) +
  labs(title = "marks over time")
