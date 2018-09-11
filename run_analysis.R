# Getting and Cleaning Data Course Project
# 
# The purpose of this project is to demonstrate your ability to collect, work with, and 
# clean a data set. The goal is to prepare tidy data that can be used for later analysis. 
#
# You will be graded by your peers on a series of yes/no questions related to the project. 
#
# You will be required to submit: 
# 1) a tidy data set as described below, 
# 2) a link to a Github repository with your script for performing the analysis, and 
# 3) a code book that describes the variables, the data, and any transformations or work that
#    you performed to clean up the data called CodeBook.md. 
# 
# You should also include a README.md in the repo with your scripts. 
# This repo explains how all of the scripts work and how they are connected.
# 
# One of the most exciting areas in all of data science right now is wearable computing - see 
# for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop 
# the most advanced algorithms to attract new users. The data linked to from the course website 
# represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
# A full description is available at the site where the data was obtained:
#         
#         http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# 
# Here are the data for the project:
#         
#         https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 
# You should create one R script called run_analysis.R that does the following.
# 
# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names.
# 5.From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.

# 1.Merges the training and the test sets to create one data set.

# Check if data directory exists.  If it doesn't exist, download file and unzip
if (!file.exists("UCI HAR Dataset")) {
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile = "./dataset.zip", mode="wb")

        dateDownloaded <- date()
        dateDownloaded
        
        unzip("./dataset.zip")
}

# Read train data set
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)

# Read test data set
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)

# Read features names
features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE)

# Add column names
names(X_train)  <- features[,2]
names(y_train) <- "activityID"
names(subject_train) <- "subject"

names(X_test) <- features[,2]
names(y_test) <- "activityID"
names(subject_test) <- "subject"

# Generate rowId's for train and test data sets
rowID_train = data.frame(rowID=1:nrow(X_train))
rowID_test = data.frame(rowID=1:nrow(X_test))

# Merge TRAIN rowID, subject, activity and X measurements
trainData <- cbind(rowID_train, subject_train, y_train, X_train)

# Merge TEST rowID, subject, activity and X measurements
testData <- cbind(rowID_test, subject_test, y_test, X_test)

# Merge train and test datasets
allData <- rbind(trainData, testData)

# 2.Extracts only the measurements on the mean and standard deviation for each measurement.
variableNames <- names(allData)

# We want column names containing -mean() or -std(), and also rowID, subject and activityID columns
interestingColumns <- grep("-mean\\()|-std\\()|rowID|subject|activityID",variableNames)

# Extract only the columns we need
smallData <- allData[,interestingColumns]

# 3.Uses descriptive activity names to name the activities in the data set

# Read activity labels
activities <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE)

# Add column names
names(activities) <- c("activityID", "activity")

# Merge activity names
finalData <- merge(activities, smallData, by.x = "activityID", by.y = "activityID")


# 4.Appropriately labels the data set with descriptive variable names.
variableNames <- names(finalData)

# Delete "-" and "()" from variable names
variableNames <- gsub("-","",variableNames)
variableNames <- gsub("()","",variableNames, fixed = TRUE)

# Upercase Mean and Std
variableNames <- gsub("mean","Mean",variableNames)
variableNames <- gsub("std","Std",variableNames)

# Replace variable names
names(finalData) <- variableNames

# 5.From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.

library(dplyr)

# Group by activity and subject, calculate the mean of each other column
averageData <- finalData %>% group_by(activity, subject) %>% summarise_all("mean")

# Remove columns actitityID and rowID
averageData <- subset(averageData, select=-c(activityID,rowID))

# Write data to file
write.table(averageData, file = 'average_data.txt', row.names = FALSE)
