# TidyDataProject
ReadMe Course Project for Getting and Cleaning Data

### Background
The purpose of this project is to to demonstrate the ability to collect, work with, and clean a data set. The source of the UCI HAR Dataset is a zip file found at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip. The runanalysis.R script serves to produce a tidy dataset by wrangling and summarizing the data from the *Human Activity Recognition Using Smartphones* study that measured data collected from Samsung Galaxy S smartphone accelerometers.

**Data Source:**[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

**runanalysis.R Script Requirements**
The project criteria outline that the script performs each of the the following steps:

1. Merges the training and the test sets to create one data set
2. Extracts only the measurements on the mean and standard deviation for each measurement 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable - mean() and std() - for each activity and each subject

### Tidy Dataset Rationale
For the two datasets (UCIHAR_mean_std_data.csv and UCIHAR_variable_avg_data.csv), the rationale behind this script was to create a wide tidy dataset so that is only one row for each observation of a subject doing an activity. This conforms to the tidy data guideline that each different observation of that variable should be in a different row. The wide form also conforms to tidy data guideline that each measured variable is in a column. 

### runanalysis.R Explanation
**Assumptions**
This script assumes the user has the necessary packages installed (dplyr).

**0. Preparing the data**
* load the necessary libraries
* download the input files from the project mandated URL, unzips it, and sets the working directory
* read in the .txt data for the training and test sets, the training and test labels, and the training and test subject
* read in the .txt data for the features, then transposes the feature data and removes the featureid column, so that the feature measurements are formatted to be assigned as column names for their matching observations read in from the other .txt data sources in the next section of the code

**1. Merges the training and the test sets to create one data set**
* use rbind() to merge the training and test data into one feature set where each observation type has only one column and use colnames() to assign the transposed feature measurement descriptions as column names for their respective observations

**2. Extracts only the measurements on the mean and standard deviation for each measurement**
* use dplyr's filter() to return only the rows in the featuremeasure column of features.txt that match the conditions that matched the pattern set with grep1 with the argument pattern searching for matches to mean() and std
# by then subsetting the merged feature data by only the second row of the filtered data, the featureid observations are removed from the data set and we only extract the merged data where the feature measurements are mean() and std() or standard deviation

**Binding the other Columns**

While not one of the project's required steps, this step
* uses rbind() to merge the activity and subject observations from the training and testing datasets into a single activity column and a single subject column for use in our final data and then uses colnames() to assign column names to these intermediary datasets
* uses cbind() to bind the activity and subject columns to the extracted feature measurements, bringing all of the data requested into one table where each variable is in its own column and each different observation is in a different row

**3. Uses descriptive activity names to name the activities in the data set**
* use col.names() to name the column activity for the activity labels
* merge the two data tables by their ID columns so that the more descriptive activity column can be properly joined to the ybind training and testing activity data
* remove unecessary activityID column from the merged data

**4. Appropriately labels the data set with descriptive variable names**
Many of the variable name abbreviations and components are more thoroughly explained in UCI HAR dataset's README.txt and the feature_info.txt for the dataset, so use gsub() to replace all occurances in the text of the specified pattern matches with replacement text (i.e. replace all occurences of Mag with magnitude) for names() on our merged data
* feature_info.txt explains all the variables with the ending ...Mag to be measurements of the signal's magnitudes so use gsub() to replace Mag with magnitude
* feature_info.txt defines 'f' as indicating the frequency domain in all of the signal measurements it is assigned to so use gsub() to replace f with frequencydomain
* feature_info.txt defines 't' as indicating the time domain in all of the signal measurements it is assigned to so use gsub() to replace t with timedomain
* features_info.txt maps the pattern variable name of BodyAccJerk to the measurement name of body linear acceleration so use gsub() to replace BodyAccJerk with bodylinearacceleration
* features_info.txt maps the pattern variable name of BodyGyroJerk to the measurement name of angular velocity with Jerk signals so use gsub() to replace BodyGyroJerk with angularvelocityjerk
* feature_info.txt maps GravityyAcc to gravity acceleration so use gsub() to replace GravityAcc with gravityacceleration
* feature_info.txt maps BodyAcc to body acceleration so use gsub() to replace BodyAcc with bodyacceleration
* README.txt defines BodyGyro to be angular velocity so use gsub() to replace BodyGyro with angularvelocity
* -XYZ can be removed because according to features_info.txt all of the database features came from the 3-axials raw signals it denotes so use gsub() to replace XYZ with nothing ("")
* remove dashes to clean up the variable name so use gsub() to replace dashes with an underscore
* remove parentheses to clean up the variable name so replace parentheses with nothing ("")

**Create the first tidy dataset as a text file**
While not one of the project's required steps, this step
* uses write.csv() to create a CSV called UCIHAR_mean_std_data.csv

**5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable - mean() and std() - for each activity and each subject**
* converts the data to tbl class with tbl_df()
* with piping to enhance readability, uses group_by() to group the tidy data into rows with the same values of activity and subject and uses summarise_each to apply the mean() function to each column
* uses write.csv() to create a CSV called UCIHAR_variable_avg_data.csv
