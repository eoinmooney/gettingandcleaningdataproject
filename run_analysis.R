library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load Activity and feature labels
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[,2] <- as.character(actLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract Mean and Sdev data
featureswanted <- grep(".*mean.*|.*std.*", features[,2])
featureswanted.names <- features[featureswanted,2]
featureswanted.names = gsub('-mean', 'Mean', featureswanted.names)
featureswanted.names = gsub('-std', 'Std', featureswanted.names)
featureswanted.names <- gsub('[-()]', '', featureswanted.names)


# Load Train data
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featureswanted]
trainAct <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSub <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSub, trainAct, train)

#load Test data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featureswanted]
testAct <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSub <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSub, testAct, test)

# merge and label
all <- rbind(train, test)
colnames(all) <- c("subject", "activity", featureswanted.names)

# Factor activities and subjects
all$activity <- factor(all$activity, levels = actLabels[,1], labels = actLabels[,2])
all$subject <- as.factor(all$subject)

# combine and compute means
all.melted <- melt(all, id = c("subject", "activity"))
all.mean <- dcast(all.melted, subject + activity ~ variable, mean)

# Create the output file tidy.txt
write.table(all.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
