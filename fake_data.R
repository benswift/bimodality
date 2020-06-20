library("tidyverse")
library("triangle")

## helper function
clamp_mark <- function(x, lower = 0, upper = 100) {
  pmax( lower, pmin( x, upper))
}

## fake_data function generates a data frame of data for a fake institution
## takes two parameters
##
## 1. name of the institution (string)
## 2. function which takes one arg (n) and returns a vector of marks (of length n)

## feel free to change this variable to taste
students_per_class = 30

gen_fake_data <- function(institution_name, mark_fn) {
  tibble(institution = institution_name,
         crossing(
           year = 2010:2019,
           term = 1:2,
           course = c(100:110, 200:210, 300:310, 400:410))) %>%
    group_by(institution, year, term, course) %>%
    mutate(mark = list(mark_fn(students_per_class))) %>%
    unnest(cols = c(mark))
}

## reproduce the fake institutions from the original repo
data = bind_rows(
  gen_fake_data("Gaussian University", function(n) clamp_mark(rnorm(n, 50, 10))),

  gen_fake_data("University of Truncation", function(n) clamp_mark(rnorm(n, 80, 10))),

  gen_fake_data("Neitherton Polytechnic", function(n) clamp_mark(rtriangle(n, 0, 100, 100))),

  gen_fake_data("Two Humps University", function(n) {
    c(clamp_mark(rnorm(n/2, 85, 2)), clamp_mark(rnorm(n/2, 40, 2)))
  })
)
