library("tidyverse")
library("readxl")
library("lubridate")

## read an Excel (.xlsx) spreadsheet into a tidy tibble

## this example is real code that [Ben](https://benswift.me) uses to work with
## the spreadsheet that comes out of the student mark reporting system at the
## Australian National University, so it probably won't work for you as-is, but
## might help you get your own data into shape.

data = read_excel("data/anu.xlsx") %>%
  mutate(institution = "ANU",
         # extract the year only from the timestamp in the "Census Date" column
         year = year(`Census Date`),
         ## the ANU data dump doesn't explicitly include a "term" column, so we'll
         ## just guess based on census date (this just guesses S1 or S2; doesn't handle
         ## summer/winter terms etc.)
         term = if_else(month(`Census Date`)<=6, 1, 2),
         ## as.numeric makes sure that any non-numeric grades are converted to NAs
         mark = as.numeric(`Grade Input`)) %>%
  ## rename any columns that don't *exactly* match the expected names in
  ## bimodality.R (otherwise that script won't work properly)
  rename(course = `Class Number`) %>%
  ## select the desired columns for the analysis (since the ANU data spreadsheet
  ## contains many more columns)
  select(institution,
         year,
         term,
         course,
         mark)
