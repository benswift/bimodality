library("tidyverse")
library("readxl")
library("lubridate")
library("diptest")
library("nortest")
library("moments")

## "min class size" threshold
min_students = 30

## the ANU data dump doesn't explicitly include a "semester" column, so we'll
## just guess based on census date (this just guesses S1 or S2; doesn't handle
## summer/winter terms etc.)
which_semester <- function(dttm){
  ifelse(month(dttm)<=6, 1, 2)
}

## read data into a tidy tibble
data = read_excel("anu.xlsx") %>%
  mutate(institution = "ANU",
         year = year(`Census Date`),
         semester = which_semester(`Census Date`),
         mark = as.numeric(`Grade Input`)) %>%
  select(institution,
         Gender,
         Residency,
         year,
         semester,
         `Class Number`,
         mark,
         `Official Grade`) %>%
  rename(course = `Class Number`,
         gender = Gender,
         residency = Residency,
         grade = `Official Grade`)

## calculate the relevant statistics
stats = data %>%
  filter(!is.na(mark)) %>%
  group_by(institution, year, semester, course) %>%
  filter(length(mark) > min_students) %>%
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

## visualisation

theme_set(theme_gray(base_size = 25))

ggplot(data, aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  labs(title = "COMP marks (1996-2019)")

ggplot(data, aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  facet_wrap(~year) +
  labs(title = "COMP marks by year")

ggplot(data %>% filter(!is.na(residency)), aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  facet_grid(residency~year) +
  labs(title = "COMP marks by year & residency")

ggplot(data, aes(year, mark)) +
  geom_point(alpha = 0.01) +
  geom_smooth(method = "lm") +
  labs(title = "COMP marks over time")

ggplot(data %>% filter(!is.na(residency)), aes(year, mark)) +
  geom_point(alpha = 0.01) +
  geom_smooth(method = "lm") +
  facet_wrap(~residency, dir="v") +
  labs(title = "COMP marks over time")
