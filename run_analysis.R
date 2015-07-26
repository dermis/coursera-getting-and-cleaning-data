## run_analysis.R
## This script should be placed in UCI HAR Dataset folder (main folder)

setwd("03-Data-Cleaning/w3/UCI HAR Dataset/")

## Load required library
library(data.table)

## Step 1 - read all data

## Read data from test folder
test.subjects <- read.table("test/subject_test.txt", col.names="subject")
test.data <- read.table("test/X_test.txt")
test.labels <- read.table("test/y_test.txt", col.names="label")

## Read data from train folder
train.subjects <- read.table("train/subject_train.txt", col.names="subject")
train.data <- read.table("train/X_train.txt")
train.labels <- read.table("train/y_train.txt", col.names="label")

## Merge test and train dataset
merged.data <- rbind(cbind(test.subjects, test.labels, test.data),
              cbind(train.subjects, train.labels, train.data))

## Step 2 - read features file
features <- read.table("features.txt", strip.white=TRUE, stringsAsFactors=FALSE)
# retain mean and standard deviations values
features.mean.std <- features[grep("mean\\(\\)|std\\(\\)", features$V2), ]

# select only the means and standard deviations from data
# increment by 2 because data has subjects and labels in the beginning
data.mean.std <- merged.data[, c(1, 2, features.mean.std$V1+2)]

## Step 3 - read the labels for activities
labels <- read.table("activity_labels.txt", stringsAsFactors=FALSE)
# replace labels in data with label names
data.mean.std$label <- labels[data.mean.std$label, 2]

## Step 4 - assign columns name
good.colnames <- c("subject", "label", features.mean.std$V2)
# standardize column names
good.colnames <- tolower(gsub("[^[:alpha:]]", "", good.colnames))
# update column names for data
colnames(data.mean.std) <- good.colnames

## Step 5 - find the mean for each combination of subject and label
aggr.data <- aggregate(data.mean.std[, 3:ncol(data.mean.std)],
                       by=list(subject = data.mean.std$subject, 
                               label = data.mean.std$label),
                       mean)

## Submission
# write the data for submission as averages.txt
write.table(format(aggr.data, scientific=T), "averages.txt", row.names=F, col.names=F, quote=2)
