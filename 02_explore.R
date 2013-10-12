library(ggplot2)
library(plyr)

## quick and dirty exploration so I can build example for STAT 545A

## those scripts had to be lean, so I did more fiddling here

lotrDat <- read.delim("lotr_wordsSpoken.tsv")

str(lotrDat)
# 'data.frame':  731 obs. of  5 variables:
# $ Film     : Factor w/ 3 levels "The Fellowship Of The Ring",..: 1 1 1 ..
# $ Chapter  : Factor w/ 188 levels "01: Prologue",..: 1 1 1 1 4 8 8 8 8 ..
# $ Character: Factor w/ 74 levels "Aragorn","Arwen",..: 3 11 21 26 3 3 1..
# $ Race     : Factor w/ 10 levels "Ainur","Dead",..: 7 4 4 6 7 7 7 1 7 7..
# $ Words    : int  4 5 460 20 214 70 128 197 10 12 ...

## reorder Film factor based on story
oldLevels <- levels(lotrDat$Film)
jOrder <- sapply(c("Fellowship", "Towers", "Return"),
                 function(x) grep(x, oldLevels))
lotrDat <- within(lotrDat,
                  Film <- factor(as.character(lotrDat$Film),
                                 oldLevels[jOrder]))

## getting rid of some observations
## I've always found the Ent parts really boring
## Nazgul and the Dead just don't talk enough
## Gollum is not a Race!
lotrDat <-
  droplevels(subset(lotrDat,
                    !(Race %in% c("Gollum", "Ent", "Dead", "Nazgul"))))

## no one knows that the Ainur are the wizards
## Men should be Man, for consistency
lotrDat <-
  within(lotrDat, Race <- revalue(Race, c(Ainur = "Wizard",
                                          Men = "Man")))

p <- ggplot(lotrDat, aes(x = Race, weight = Words))
p + geom_bar()

## who speaks alot?
wordTotals <-
  ddply(lotrDat, ~ Race, summarize, totalWords = sum(Words))
arrange(wordTotals, desc(totalWords))
#     Race totalWords
# 1 Hobbit       8796
# 2    Man       8712
# 3 Wizard       5961
# 4    Elf       3737
# 5  Dwarf       1265
# 6    Orc        723

## reorder Race based on words spoken
lotrDat <- within(lotrDat, Race <- reorder(Race, Words, sum))
levels(lotrDat$Race)

p <- ggplot(lotrDat, aes(x = Race, weight = Words))

p + geom_bar()

p + geom_bar(aes(fill = Film), position = position_dodge(width = 0.7))

p <- ggplot(lotrDat, aes(x = Race, y = Words, color = Film)) +
  scale_y_log10()
p + geom_point(alpha = 1/2, position = position_dodge(width=0.5))

p <- ggplot(lotrDat, aes(x = Race, y = Words)) + scale_y_log10() +
  geom_jitter(alpha = 1/2, position = position_jitter(width = 0.1))
p + stat_summary(fun.y = median, pch = 21, fill = "orange",
                 geom = "point", size = 6)

write.table(lotrDat, "lotr_clean.tsv", quote = FALSE,
            sep = "\t", row.names = FALSE)