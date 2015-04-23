

# Read in the data
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- scan(file = "./UCI HAR Dataset/train/y_train.txt")
subject_train <- scan(file = "./UCI HAR Dataset/train/subject_train.txt")

X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- scan(file = "./UCI HAR Dataset/test/y_test.txt")
subject_test <- scan(file = "./UCI HAR Dataset/test/subject_test.txt")


# Name the columns (each column is a differnt type of measurement)
features <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE, col.names = c("number", "feature"))
colnames(X_train) <- features$feature
colnames(X_test) <- features$feature


# Select only the columns for mean and std measurements for each data frame
# Not including the last "angle function" measurements
colIndices <- grep("mean[(][)]|std[(][)]", features$feature[1:554])
X_train <- X_train[colIndices]
X_test <- X_test[colIndices]


# Append columns for the activity and the subject number
activitylabels <- read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE, col.names = c("number", "label"))
X_train$activity <- factor(y_train, levels = activitylabels$number, labels = activitylabels$label)
X_test$activity  <- factor(y_test,  levels = activitylabels$number, labels = activitylabels$label)

X_train$subject <- subject_train
X_test$subject  <- subject_test


# Merge the data frames
X_all <- rbind(X_train, X_test)


# Now create a new summary data frame.
# We first melt the data frame and then compute the average for each activity
# and for each subject for each variable in our original data frame. 
# Finally we combine the two data frames into one summary data frame.
X_melt <- melt(X_all, id=colnames(X_all[67:68]), measure.vars=colnames(X_all[1:66]))

X_summary_activity <- dcast(X_melt, activity ~ variable, mean)
rownames(X_summary_activity) <- as.character(X_summary_activity$activity)
X_summary_activity$activity <- NULL

X_summary_subject <- dcast(X_melt, subject ~ variable, mean)
rownames(X_summary_subject) <- as.character(X_summary_subject$subject)
X_summary_subject$subject <- NULL

X_summary <- rbind(X_summary_activity, X_summary_subject)
X_summary$category <- rownames(X_summary)

write.table(X_summary, file="wearables_mean_summary.txt", row.names=FALSE)
