library("tidyverse")
library("readxl")
library("lubridate")

## read ANU data into a tidy tibble

## if there's already a "data" tibble (e.g. from fake_data.R) then this will
## overwrite it, so that may/may not be what you want - adjust variable names as
## necessary
data = read_excel("anu.xlsx") %>%
  mutate(institution = "ANU",
         year = year(`Census Date`),
         ## the ANU data dump doesn't explicitly include a "semester" column, so we'll
         ## just guess based on census date (this just guesses S1 or S2; doesn't handle
         ## summer/winter terms etc.)
         semester = if_else(month(`Census Date`)<=6, 1, 2),
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
         grade = `Official Grade`) %>%
  select(institution, year, semester, course, mark)
