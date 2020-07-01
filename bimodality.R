library("tidyverse")
library("readxl")
library("lubridate")
library("diptest")
library("nortest")
library("moments")

###############
## load data ##
###############

## source("fake_data.R")
source("preprocessing.R")

#####################
## calculate stats ##
#####################

stats = data %>%
  filter(!is.na(mark)) %>%
  group_by(institution, year, term, course) %>%
  ## ad.test sample size must be greater than 7
  filter(n() > 7) %>%
  summarize(n = n(),
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
            percent_dip_test_rejected = mean(kurtosis < 3 & p_dip < 0.05) * 100) %>%
  print(n=Inf)

###################
## visualisation ##
###################

theme_set(theme_gray(base_size = 25))

mark_histogram = geom_histogram(aes(fill = grade), breaks = seq(0, 100, 1), closed="left")

data %>%
  ggplot(aes(mark)) +
  mark_histogram +
  scale_fill_brewer(type="qual", palette = 2) +
  labs(title = "all marks")

data %>%
  ggplot(aes(mark)) +
  mark_histogram +
  scale_fill_brewer(type="qual", palette = 2) +
  facet_wrap(~year) +
  labs(title = "marks by year") +
  scale_x_continuous(n.breaks = 2) +
  guides(x = guide_axis(angle = 90))

data %>%
  filter(residency %in% c("AUS", "INTL")) %>%
  ggplot(aes(mark)) +
  mark_histogram +
  scale_fill_brewer(type="qual", palette = 2) +
  facet_grid(residency~year) +
  labs(title = "marks by year & residency") +
  scale_x_continuous(n.breaks = 2) +
  guides(x = guide_axis(angle = 90))

data %>%
  filter(gender %in% c("F", "M")) %>%
  ggplot(aes(mark)) +
  mark_histogram +
  scale_fill_brewer(type="qual", palette = 2) +
  facet_wrap(~gender)

data %>%
  filter(gender %in% c("F", "M")) %>%
  ggplot(aes(mark)) +
  mark_histogram +
  facet_grid(gender~year) +
  scale_x_continuous(n.breaks = 2) +
  guides(x = guide_axis(angle = 90))

## this won't really be useful for the fake data (since the distributions don't
## change year-to-year) but it might be interesting for real data

data %>%
  ggplot(aes(year, mark)) +
  geom_point(alpha = 0.01) +
  geom_smooth(method = "lm") +
  labs(title = "marks over time")

## transform(year = cut(year, breaks = seq(1995, 2020, 5), right = FALSE)) %>%

data %>%
  group_by(program) %>%
  count() %>%
  filter(n > 100) %>%
  arrange(n) %>%
  print(n=Inf)

data %>%
  filter(gender %in% c("F", "M")) %>%
  group_by(year, gender) %>%
  count() %>%
  ggplot(aes(year, n, colour = gender)) +
  geom_line(size = 3) +
  scale_colour_brewer(type="qual")

data %>%
  filter(gender %in% c("F", "M")) %>%
  ggplot(aes(gender, fill = gender)) +
  geom_bar() +
  facet_wrap(~year)
