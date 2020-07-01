library("tidyverse")
library("readxl")
library("lubridate")
library("fs")
library("stringr")

## EXAMPLE 1: loop over directory full of csv files

## NOTE: this example is based on the old data format for this project (one file
## per class, naming convention '2000-1-CSC-100.csv')

## here's a function for reading a single one of the files (and returning a tibble)
read_single_class_csv <- function(filename, institution_name) {
  match = str_match(filename, "([0-9]+)-([0-9])-[A-Z]+-([0-9]+).csv")
  if(anyNA(match)){
    stop(str_glue("couldn't extract year/term/class info from filename {filename}, stopping."))
  }
  tibble(
    institution = institution_name,
    year = strtoi(match[2]),
    term = (match[3]),
    course = (match[4]),
    mark = read_csv(filename)[[1]] ## don't use the header, just get the first column
  )
}

## here's the code for mapping that function over all the CSVs in a directory
data = tibble(filename = dir_ls("data/gaussuniversity", regexp = "\\.csv$")) %>%
  split(.$filename) %>%
  map_dfr(~ read_single_class_csv(.$filename, "Gaussian University"))

## EXAMPLE 2: read an Excel (.xlsx) spreadsheet into a tidy tibble

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
  rename(course = `Catalogue Number`) %>%
  ## select the desired columns for the analysis (since the ANU data spreadsheet
  ## contains many more columns)
  select(institution,
         year,
         term,
         course,
         mark)

