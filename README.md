# bimodality

Grade distribution analysis: are CS grades bimodal?

by Elizabeth Patitsas (<elizabeth.patitsas@mcgill.ca>), April 18, 2018

code refactor by Ben Swift (<ben.swift@anu.edu.au>), June 2020

This is the code I used for the grade analysis study in
<https://dl.acm.org/citation.cfm?doid=2960310.2960312>

Hopefully with the code freely available we can have some replications! :)

## The Data

This repo doesn't contain any actual student data (since there are restrictions
around sharing that stuff). Instead, it contains functionality (in
`fake_data.R`) for generating fake student data with arbitrary mark
distributions.

Out-of-the-box, `fake_data.R` will generate data for the following "fake"
institutions:

- **Gauss University**, where grades are normal
- **Two Humps College**, where grades are bimodal
- **Neitherton Polytechnic**, where grades are neither normal nor bimodal
  (triangular, to be specific)
- **University of Truncation**, where grades are normal but the students are all
  really good and too many of them would get grades above 100, but are truncated
  down to 100

## Setup

The following R packages are necessary:

- `install.packages("tidyverse")`
- `install.packages("readxl")`
- `install.packages("lubridate")`
- `install.packages("diptest")`
- `install.packages("nortest")`
- `install.packages("moments")`
- `install.packages("triangle")`

## Use

The main script file is `bimodality.R`. It's written in
[tidyverse](https://www.tidyverse.org/) style, and is designed to be run
interactively (although you could run it as a batch job; in that case you can
probably comment out the visualisation code at the end).

### Data input

The `bimodality.R` script assumes that the data for your courses is loaded into
a [tibble](https://tibble.tidyverse.org/) (which is just like a DataFrame)
called `data`. Each row of `data` represents **one student's mark**, and has the
following columns:

- `institution` (_character_): the name of the institution
- `year` (_int_): the year the course was taken
- `term` (_int_): the term (semester) the course was taken in (to help
  disambiguate between courses which run multiple times per year)
- `course` (_int_ or _character_): the course code (or course name; the only
  requirement is that it's a unique identifier for that particular course)
- `mark` (_double_): the student's mark

No other identifying information about the student (e.g. name, student ID) is
required---just the mark.

Here's an example (from the fake data mentioned above)

```R
R> data
# A tibble: 105,600 x 5
# Groups:   institution, year, term, course [3,520]
   institution               year  term course  mark
   <chr>                    <int> <int>  <int> <dbl>
 1 University of Truncation  2010     1    100  95.5
 2 University of Truncation  2010     1    100  87.9
 3 University of Truncation  2010     1    100  88.4
 4 University of Truncation  2010     1    100  69.4
 5 University of Truncation  2010     1    100  82.4

## ... a bunch more rows here...

 6 Gaussian University       2010     1    100  49.7
 7 Gaussian University       2010     1    100  49.8
 8 Gaussian University       2010     1    100  57.3
 9 Gaussian University       2010     1    100  58.6
10 Gaussian University       2010     1    100  52.9
# … with 105,590 more rows
```

How you create your `data` tibble is up to you---you could store your mark data
in a csv file and use
[`read_csv()`](https://readr.tidyverse.org/reference/read_delim.html), or some
other way.

If you're after some more guidance on how to prepare your `data` tibble, there
are a couple of examples in `preprocessing.R`:

- **example 1**: iterating over a directory full of CSV files with a specific
  naming pattern, loading them all into a single tibble (NOTE: this example is
  based on the old data format used in this project, `git checkout 481b408` for
  more details)

- **example 2**: loading (and optionally re-shaping) the data from Excel spreadsheet

### Analysis

After you've prepared your `data`, the next stage of the script will calculate a
bunch of different statistics (e.g. kurtosis, Hartigan dip test, Shapiro-Wilk)
and put them in a `stats` data frame.

Finally, the script runs the "are my CS grades bimodal?" tests and prints the
results to the R console. They should look something like this:

```R
R> stats %>%
+   group_by(institution) %>%
+   summarise(percent_shapiro_rejected = mean(p_shapiro < 0.05) * 100,
+             percent_dip_test_rejected = mean(kurtosis < 3 & p_dip < 0.05) * 100)
+
# A tibble: 4 x 3
  institution              percent_shapiro_rejected percent_dip_test_rejected
  <chr>                                       <dbl>                     <dbl>
1 Gaussian University                          5.57                     0.114
2 Neitherton Polytechnic                      48.4                      0.909
3 Two Humps College                          100                      100
4 University of Truncation                     4.55                     0.227
```

In terms of interpreting this output:

- `percent_shapiro_rejected` is the number of courses that **are not** normally
  distributed; more precisely it's the percentages of courses where the null
  hypothesis under Shapiro-Wilk (that the data is normally distributed) can be
  rejected at p < 0.05

- `percent_dip_test_rejected` is the number of courses that **are** multimodal;
  more precisely it's the percentages of courses where the kurtosis is less than
  3 _and_ the null hypothesis under the Hartigan dip test (that the data is not
  multimodal) can be rejected at p < 0.05

### Visualisation

There's also some simple data visualisation examples at the bottom of
`bimodality.R` which use the amazing
[`ggplot2`](https://ggplot2.tidyverse.org/index.html) library. They might be a
helpful starting point for any other ways you might want to look at the data.

## Contributing

Sharing real grade data around between institutions is tricky, but having
individuals perform this analysis on the CS marks from their own institution and
sharing the results should be much more do-able. So get on it, and let us know!
