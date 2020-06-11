library("tidyverse")
library("readxl")
library("lubridate")

which_semester <- function(dttm){
  ifelse(month(dttm)<=6, 1, 2)
}

## to see all the unique year/month combos for the census dates
## unique(cbind(year(df[["Census Date"]]), month(df[["Census Date"]])))

## this function assumes that you're giving it a df which contains only the data
## for one class
## 2000-1-CSC-100.csv

write_bimodal_grade_file <- function(df){
  print(df)
  year = df$year[0]
  semester = df$semester[0]
  course = df$course[0]
  filename = sprintf("anu/%d-%d-COMP-%d.csv", year, semester, course)
  cat(sprintf("anu;%d;%d;COMP;%d\n", year, semester, course), file = filename)
  cat(df$mark, file = filename, append = TRUE, sep = "\n")
}

## if you want "COMPXXXX", then add this to the mutate() call: "course" =
## paste(Subject, `Class Number`, sep="")

## do all the things
df = read_excel("anu/all.xlsx") %>% mutate(year = year(`Census Date`), semester = which_semester(`Census Date`), mark = as.numeric(`Grade Input`)) %>% select(year, semester, `Class Number`, mark) %>% rename(course = `Class Number`)

## TODO doesn't quite work yet
write_bimodal_grade_file(head(df))
