library("tidyverse")
library("readxl")
library("lubridate")

## "min class size" threshold
min_students = 30

which_semester <- function(dttm){
  ifelse(month(dttm)<=6, 1, 2)
}

## to see all the unique year/month combos for the census dates
## unique(cbind(year(df[["Census Date"]]), month(df[["Census Date"]])))

## this function assumes that you're giving it a df which contains only the data
## for one class
## 2000-1-CSC-100.csv

write_semester_grade_file <- function(year, semester, course, marks){
  marks = marks[!is.na(marks)] # remove NAs
  if (length(marks) > min_students) {
    filename = sprintf("anu/%d-%d-COMP-%d.csv", year, semester, course)
    cat(sprintf("anu;%d;%d;COMP;%d\n", year, semester, course), file = filename)
    cat(marks, file = filename, append = TRUE, sep = "\n")
  }
}

mode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

## if you want "COMPXXXX", then add this to the mutate() call: "course" =
## paste(Subject, `Class Number`, sep="")

## read in the data
df = read_excel("anu.xlsx") %>% mutate(year = year(`Census Date`), semester = which_semester(`Census Date`), mark = as.numeric(`Grade Input`)) %>% select(Gender, Residency, year, semester, `Class Number`, mark, `Official Grade`) %>% rename(course = `Class Number`, gender = Gender, residency = Residency, grade = `Official Grade`)

## write the individual csv files as required by the rest of the scripts
df %>% group_by(year, semester, course) %>% group_walk(~ write_semester_grade_file(.y$year, .y$semester, .y$course, .x$mark))

## visualisation

theme_set(theme_gray(base_size = 25))

ggplot(df, aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  labs(title = "COMP marks (1996-2019)")

ggplot(df, aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  facet_wrap(~year) +
  labs(title = "COMP marks by year")

ggplot(df %>% filter(!is.na(residency)), aes(mark)) +
  geom_histogram(breaks = seq(0, 100, 5)) +
  facet_grid(residency~year) +
  labs(title = "COMP marks by year & residency")

ggplot(df, aes(year, mark)) +
  geom_point(alpha = 0.01) +
  geom_smooth(method = "lm") +
  labs(title = "COMP marks over time")

ggplot(df %>% filter(!is.na(residency)), aes(year, mark)) +
  geom_point(alpha = 0.01) +
  geom_smooth(method = "lm") +
  facet_wrap(~residency, dir="v") +
  labs(title = "COMP marks over time")

## ggplot(df, aes(mark)) +
##   geom_histogram(breaks = seq(0, 100, 5)) +
##   facet_wrap(~course) +
##   labs(title = "COMP marks by course")
