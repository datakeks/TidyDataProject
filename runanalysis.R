##-------------------------------------------------------------------------------------------------
## runanalysis.R

## Assumptions: that the required R packages dyplyr is already installed

## Tidy Dataset Rationale: For the two datasets (UCIHAR_mean_std_data.csv and UCIHAR_variable_avg_data.csv),
## the rationale behind this script was to create a wide tidy dataset so that is only one row for each
## observation of a subject doing an activity. This conforms to the tidy data guideline that each different
## observation of that variable should be in a different row. The wide form also conforms to tidy data
## guideline that each measured variable is in a column. 

## Data Source: [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L.
##              Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass
##              Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted
##              Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

## The script performs each of the the following steps:
## 1. Merges the training and the test sets to create one data set
## 2. Extracts only the measurements on the mean and standard deviation for each measurement 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names
## 5. From the data set in step 4, creates a second, independent tidy data set with the
##    average of each variable - mean() and std() - for each activity and each subject
##-------------------------------------------------------------------------------------------------
############ Checking for necessary libraries
library("dplyr")

############ Downloading the input files
if (!file.exists("data")) {dir.create("data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "data/UCI HAR Dataset.zip", method = "curl")
unzip("data/UCI HAR Dataset.zip", exdir = "./data")
setwd("./data/UCI HAR Dataset")

############ Read in the data
xtrain <- read.table("train/X_train.txt")
# training set 
ytrain <- read.table("train/y_train.txt", col.names = "activityid")
# training labels
subjtrain <- read.table("train/subject_train.txt", col.names = "subjectid")

xtest <- read.table("test/x_test.txt")
# test set
ytest <- read.table("test/y_test.txt", col.names = "activityid")
# test labels
subjtest <- read.table("test/subject_test.txt", col.names = "subjectid")

inputfeat <- read.table("features.txt", col.names = c("featureid","featuremeasure"))
columnfeat <- (t(select(inputfeat, -featureid)))
# transposed the feature data and removed the featureid column, so that the feature measurements
# would be formatted to be assigned as column names for their matching observations in
# x_train and x_test in the next section of the code

############ 1. Merge the training and test sets to create one feature set
features <-rbind(xtrain, xtest)
# use rbind() to merge the training and test data into one feature set where each observation type
# has only one column and 
colnames(features) <- columnfeat
# used colnames() to assign the transposed feature measurement descriptions as column names for
# their respective observations

############ 2. Extract only the measurements on the mean and standard deviation for each measurement
meanstd <- t(filter(inputfeat, grepl('mean\\(\\)|std\\(\\)', featuremeasure)))
# used dplyr's filter() to return only the rows in the featuremeasure column of features.txt
# that match the conditions that matched the pattern set with grep1 with the argument pattern
# searching for matches to mean() and std()
extracted <- features[,meanstd[2,]]
# by subsetting the merged feature data by only the second row of the filtered data, the featureid
# observations are removed from the data set and we only extract the merged data where the
# feature measurements are mean() and std() or standard deviation

############ Binding the other Columns 
ybind <-rbind(ytrain, ytest)
colnames(ybind) <- "activity"
subject <-rbind(subjtrain, subjtest)
colnames(subject) <- "subject"
# use rbind() to merge the activity and subject observations from the training and testing datasets
# into a single activity column and a single subject column for use in our final data.
# used colnames() to assign column names to these intermediary datasets

datamerge <- cbind(ybind, subject, extracted)
# use cbind() to bind the activity and subject columns to the extracted feature measurements,
# bringing all of the data requested into one table where each variable is in its own column and 
# each different observation is in a different row

############ 3. Use descriptive activity names to name the activities in the data set
inputactiv <- read.table("activity_labels.txt", col.names = c("activityid", "activity")) 
# use col.names() to name the column activity for the activity labels
datamerge1 = merge(inputactiv, datamerge, by.x = "activityid", by.y = "activity", all = TRUE)
# merge the two data tables by their ID columns so that the more descriptive activity column can be properly
# joined to the ybind training and testing activity data
datamerge <- select(datamerge1, -activityid)
# remove the unecessary activityid column

############ 4. Appropriately label the data set with descriptive variable names
# many of the variable name abbreviations and components are more thoroughly explained in  README.txt and
# feature_info.txt for the dataset, so we can use gsub() to replace all occurances in the text of the specified
# pattern matches with replacement text (i.e. replace all occurences of Mag with magnitude)
names(datamerge) <- gsub("Mag", "magnitude", names(datamerge))
# feature_info.txt explains all the variables with the ending ...Mag to be measurements of the signal's magnitudes
names(datamerge) <- gsub("^f", "frequencydomain", names(datamerge))
# feature_info.txt defines 'f' as indicating the frequency domain in all of the signal measurements it is assigned to
names(datamerge) <- gsub("^t", "timedomain", names(datamerge))
# feature_info.txt defines 't' as indicating the time domain in all of the signal measurements it is assigned to
names(datamerge) <- gsub("BodyAccJerk", "bodylinearacceleration", names(datamerge))
# features_info.txt maps the pattern variable name of BodyAccJerk to the measurement name of body linear acceleration
names(datamerge) <- gsub("BodyGyroJerk", "angularvelocityjerk", names(datamerge))
# features_info.txt maps the pattern variable name of BodyGyroJerk to the measurement name of angular velocity jerk
names(datamerge) <- gsub("GravityAcc", "gravityacceleration", names(datamerge))
# feature_info.txt maps GravityyAcc to gravity acceleration
names(datamerge) <- gsub("BodyAcc", "bodyacceleration", names(datamerge))
# feature_info.txt maps BodyAcc to body acceleration
names(datamerge) <- gsub("BodyGyro", "angularvelocity", names(datamerge))
# README.txt defines BodyGyro to be angular velocity
names(datamerge) <- gsub("XYZ", "", names(datamerge))
# -XYZ can be removed because according to features_info.txt all of the database features came from the 3-axials raw
# signals it denotes
names(datamerge) <- gsub("-", "_", names(datamerge))
# dashes are removed to clean up the variable name
names(datamerge) <- gsub("\\(\\)", "", names(datamerge))
# parentheses removed to clean up the variable name

############ Create the first tidy dataset as a text file
write.table(datamerge, "UCIHAR_mean_std_data.txt", row.names =FALSE)
# uses write.table() to create UCIHAR_mean_std_data.txt

############ 5. From the data set in step 4, creates a second, independent tidy data set with the average of each
############ variable - mean() and std() - for each activity and each subject
tidydata <- tbl_df(datamerge)
# converts the data to tbl class with tbl_df()
tidydata <- tidydata %>% group_by(activity,subject) %>% summarise_each(funs(mean))
# with piping to enhance readability, uses group_by() to group the tidy data into rows with the same values of
# activity and subject and uses summarise_each to apply the mean() function to each column
write.table(tidydata, "UCIHAR_variable_avg_data.txt", row.names =FALSE)
# uses write.table() to create UCIHAR_variable_avg_data.txt
