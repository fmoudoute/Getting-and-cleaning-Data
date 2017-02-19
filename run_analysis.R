library(plyr)
library(qdapTools)

if(!file.exists("./Data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./Data/UCI.zip",method="curl")
unzip(zipfile="./Data/UCI.zip",exdir="./Data")

path_rf <- file.path("./Data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files
y_Test  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
y_Train <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
subject_train <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
subject_test  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
x_Test  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
x_Train <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
activities <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
features  <- read.table(file.path(path_rf, "features.txt"),header = FALSE)





# Merging Datasets
x_dataset <- rbind(x_Train, x_Test)
y_dataset <- rbind(y_Train, y_Test)
subject_dataset <- rbind(subject_test, subject_train)
names(subject_dataset)<-c("Subject")
names(activities)<- c("Activity")

#Using Descriptive Activity Names and Re-labelling all datasets
colnames(activities)[1] <- 'ActivityID'
colnames(activities)[2] <- 'ActivityName'
colnames(features)[1] <- 'FeaturesID'
colnames(features)[2] <- 'FeaturesName'
names(x_dataset) <- features$FeaturesName
colnames(y_dataset)[1] <- 'ActivityID'
y_datasetModified <- merge(x = y_dataset, y = activities, by = "ActivityID", all.y  = TRUE)
y_datasetModified$ActivityID <- NULL


#Extracting Only Measurements on the mean and STD for each measurement
x_dataset2 <- x_dataset[ , grepl("mean\\(\\)|std\\(\\)" , names(x_dataset))]
MegaDataSet <- cbind(subject_dataset, y_datasetModified, x_dataset2)


#Creating the averageData with average of each variable for each activity and each subject
AverageDataSetFinal <-aggregate(. ~MegaDataSet$Subject + MegaDataSet$ActivityName, MegaDataSet, mean)
AverageDataSetFinal<-AverageDataSetFinal[order(AverageDataSetFinal$Subject,AverageDataSetFinal$Activity),]
#Cleaning Up
colnames(AverageDataSetFinal)[1] <- 'SubjectID'
colnames(AverageDataSetFinal)[2] <- 'ActivityName'
AverageDataSetFinal[3] <- NULL
AverageDataSetFinal[3] <- NULL


names(AverageDataSetFinal)<-gsub("^t", "Time", names(AverageDataSetFinal))
names(AverageDataSetFinal)<-gsub("^f", "Frequency", names(AverageDataSetFinal))
names(AverageDataSetFinal)<-gsub("Acc", "Accelerometer", names(AverageDataSetFinal))
names(AverageDataSetFinal)<-gsub("Gyro", "Gyroscope", names(AverageDataSetFinal))
names(AverageDataSetFinalta)<-gsub("Mag", "Magnitude", names(AverageDataSetFinal))
names(AverageDataSetFinal)<-gsub("BodyBody", "Body", names(AverageDataSetFinal))



write.table(AverageDataSetFinal, file = "~/documents/coursera/UCI HAR Dataset/tidydata.txt",row.name=FALSE)


library(knitr)

knit2html("codebook.Rmd")

