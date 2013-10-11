lotrDat <- read.delim("Words Spoken, By Character, Race, & Scene, in the Extended Editi.txt")
str(lotrDat)
write.table(lotrDat, "lotr_wordsSpoken.tsv", quote = FALSE,
            sep = "\t", row.names = FALSE)