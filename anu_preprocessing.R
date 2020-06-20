library("tidyverse")
library("readxl")
library("lubridate")
library("diptest")
library("nortest")
library("moments")

## "min class size" threshold
min_students = 30

which_semester <- function(dttm){
  ifelse(month(dttm)<=6, 1, 2)
}

write_semester_grade_file <- function(year, semester, course, marks){
  marks = marks[!is.na(marks)] # remove NAs
  if (length(marks) > min_students) {
    filename = sprintf("anu/%d-%d-COMP-%d.csv", year, semester, course)
    cat(sprintf("anu;%d;%d;COMP;%d\n", year, semester, course), file = filename)
    cat(marks, file = filename, append = TRUE, sep = "\n")
  }
}

## read in the data
data = read_excel("anu.xlsx") %>%
  mutate(year = year(`Census Date`), semester = which_semester(`Census Date`), mark = as.numeric(`Grade Input`)) %>%
  select(Gender, Residency, year, semester, `Class Number`, mark, `Official Grade`) %>%
  rename(course = `Class Number`, gender = Gender, residency = Residency, grade = `Official Grade`)

## calculate the relevant statistics
stats = data %>%
  filter(!is.na(mark)) %>%
  group_by(year, semester, course) %>%
  filter(length(mark) > min_students) %>%
  summarize(n = length(mark),
            mean = mean(mark),
            sd = sd(mark),
            kurtosis = kurtosis(mark),
            skewness = skewness(mark),
            dip = dip.test(mark)[[1]],
            pDip = dip.test(mark)[[2]],
            shapiro = shapiro.test(mark)[[1]],
            pShapiro = shapiro.test(mark)[[2]],
            ad = ad.test(mark)[[1]],
            pAd = ad.test(mark)[[2]],
            logShapiro = shapiro.test(log(mark))[[1]],
            pLogShapiro = shapiro.test(log(mark))[[2]]) %>%
  summarize(shapRejected = mean(pShapiro < 0.05))

## write the individual csv files as required by the rest of the scripts
data %>%
  group_by(year, semester, course) %>%
  group_walk(~ write_semester_grade_file(.y$year, .y$semester, .y$course, .x$mark))

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
