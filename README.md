# bimodality
Grade distribution analysis: are CS grades bimodal?
Elizabeth Patitsas, April 18, 2018

This is the code I used for the grade analysis study in https://dl.acm.org/citation.cfm?doid=2960310.2960312

Hopefully with the code freely available we can have some replications! :)

## The Data
I can't share the original data, so I have produced four data sets to let you see
how the anlysis would treat each of them, as well as what the input files should look like.

* Gauss University, where grades are normal
* Two Humps College, where grades are bimodal
* Neitherton Polytechnic, where grades are neither normal nor bimodal (triangular, to be specific)
* University of Truncation, where grades are normal but the students are all really good and too many of them would get grades above 100, but are truncated down to 100

## To run the code

R packages necessary:
* `install.packages('nortest')`
* `install.packages('diptest')`
* `install.packages('moments')`

Python3 packages necessary:
* `numpy`

## Analysis process

Analyisis proceeds with:

### Input
for each course there is a single file with a list of grades, each grade is on a new line

### data_analysis.py
1. for each file in the input folder, have `one_class_stats.r` execute and process the file. It computes the stats such as kurtosis, dip test, Shapiro-Wilk, and then outputs them to a file in `r_output/`
1. then we round up each file in `r_output` and concatenate them into a table so we can see the stats for all distributions of interest (a spreadsheet is put in `aggregate_statistics`)
1. with this table, we compute how many stat tests had their null hypotheses rejected or not

### Output

Will look like:
```
-----------------------------
Analysis of gaussuniversity 

Shapiro Wilk: if rejected, is not normally-distributed
110 tested	 9.09 % rejected and are not-normal	 91 % fail to reject

Hartigan Dip Test where Kurtosis < 3
65.45 % have kurtosis < 3	 2.9 mean kurtosis
2 reject NH (and so are multimodal)	 1.82 % of total are multimodal

-----------------------------
Analysis of twohumpscollege 

Shapiro Wilk: if rejected, is not normally-distributed
110 tested	 100.0 % rejected and are not-normal	 0 % fail to reject

Hartigan Dip Test where Kurtosis < 3
100.0 % have kurtosis < 3	 1.06 mean kurtosis
110 reject NH (and so are multimodal)	 100.0 % of total are multimodal

-----------------------------
Analysis of neithertonpolytechnic 

Shapiro Wilk: if rejected, is not normally-distributed
110 tested	 96.36 % rejected and are not-normal	 4 % fail to reject

Hartigan Dip Test where Kurtosis < 3
99.09 % have kurtosis < 3	 2.34 mean kurtosis
0 reject NH (and so are multimodal)	 0.0 % of total are multimodal

-----------------------------
Analysis of uoftruncation 

Shapiro Wilk: if rejected, is not normally-distributed
110 tested	 28.18 % rejected and are not-normal	 72 % fail to reject

Hartigan Dip Test where Kurtosis < 3
73.64 % have kurtosis < 3	 2.71 mean kurtosis
14 reject NH (and so are multimodal)	 12.73 % of total are multimodal
```

## How to replicate with your own data

If you have grades data from your own institution that you would like to run this analysis on it, it's straightforward to do so:

1. Make a folder to put your own data in. 
1. Each distribution should have its own file in that folder.
1. Have a look at the files in the other folders for how it should be formatted. It'll have one line like `gaussuniversity;2000;1;CSC;100` indicating that this the Term 1 offering from 2000 of CSC 100 at gauss university. The rest of the file has each grade from the class on a new line. You might need to write some scripts to munge your data into this format.
1. Head over to `data_analysis.py` and scroll down to the bottom of the program. You'll see a comment on how to update the file to have it use the data from your own folder.

If you're doing this analysis on multiple grades distributions from the same course (e.g. you want to run it on each assignment, each exam, etc) then feel free to make use of the semester parameter (or create a similar parameter) to keep track of the different distributions.
