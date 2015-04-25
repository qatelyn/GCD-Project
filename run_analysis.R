# You should create one R script called run_analysis.R that does the following. 
# 
# 1-Merges the training and the test sets to create one data set.
# 2-Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3-Uses descriptive activity names to name the activities in the data set
# 4-Appropriately labels the data set with descriptive variable names. 
# 5-From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


# Load required packages
library("data.table")
library("reshape2")

# Load files
features <- read.table("features.txt")[,2]
labels <- read.table("./activity_labels.txt")[,2]
X_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")
X_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")
subject_train <- read.table("./train/subject_train.txt")

# Merge test & train data
X_all = rbind(X_train, X_test)
y_all = rbind(y_train, y_test)
subject_all = rbind(subject_train,subject_test)

#Assign names 
names(X_all) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_all = X_all[,grepl("mean|std", features)]

# Load activity labels
y_all[,2] = labels[y_all[,1]]
names(y_all) = c("ID", "Activity")
names(subject_all) = "subject"

# Bind data
all_data <- cbind(as.data.table(subject_all), y_all, X_all)


id_labels   = c("subject", "ID", "Activity")
data_labels = setdiff(colnames(all_data), id_labels)
melt_data   = melt(all_data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity ~ variable, mean)

write.table(tidy_data, file = "tidy_data.txt",sep=";",row.names=FALSE)

