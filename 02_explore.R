
library(tidyverse)


## quick and dirty exploration so I can build example for STAT 545A

## those scripts had to be lean, so I did more fiddling here

lotr <- read.delim("lotr_wordsSpoken.tsv")

str(lotr)
# 'data.frame':  731 obs. of  5 variables:
# $ Film     : Factor w/ 3 levels "The Fellowship Of The Ring",..: 1 1 1 ..
# $ Chapter  : Factor w/ 188 levels "01: Prologue",..: 1 1 1 1 4 8 8 8 8 ..
# $ Character: Factor w/ 74 levels "Aragorn","Arwen",..: 3 11 21 26 3 3 1..
# $ Race     : Factor w/ 10 levels "Ainur","Dead",..: 7 4 4 6 7 7 7 1 7 7..
# $ Words    : int  4 5 460 20 214 70 128 197 10 12 ...

head(lotr)



## reorder Film factor based on story
lotr <- lotr %>% 
  mutate(Film = fct_relevel(Film, 
                            c("The Fellowship Of The Ring", 
                              "The Two Towers", 
                              "The Return Of The King")))


## getting rid of some observations
## I've always found the Ent parts really boring
## Nazgul and the Dead just don't talk enough
## Gollum is not a Race!
lotr <- lotr %>% 
  filter(!(Race %in% c("Gollum", "Ent", "Dead", "Nazgul"))) %>% 
  droplevels()
  

## The wizards' Race is Istari, a subset of the Ainur 
## Men should be Man, for consistency

lotr <- lotr %>% 
  mutate(Race = case_when(Character %in% c("Gandalf", 
                                           "Saruman") ~ "Istar", 
                          TRUE ~ as.character(Race)) %>% as.factor()) %>% 


    
  # mutate(Race = as.character(Race)) %>% 
  # mutate(Race = ifelse(Character %in% c("Gandalf", 
  #                                       "Saruman"), 
  #                      "Istar", 
  #                      Race) %>% as.factor()) %>% 
  mutate(Race = fct_recode(Race, 
                           Man = "Men"))




p <- ggplot(lotr, aes(x = Race, weight = Words))
p + geom_bar()

## who speaks alot?
wordTotals <-
  lotr %>% 
  group_by(Race) %>% 
  summarise(total_words = sum(Words)) %>% 
  arrange(desc(total_words))
  
# Race   total_words
# <fct>        <int>
# 1 Hobbit        8796
# 2 Man           8712
# 3 Istari        5918
# 4 Elf           3737
# 5 Dwarf         1265
# 6 Orc            723
# 7 Ainur           43

## reorder Race based on words spoken
lotr %<>% 
  mutate(Race = reorder(Race, 
                        Words, 
                        sum))

levels(lotr$Race)

p1 <- lotr %>% 
  ggplot(aes(x = Race, 
             weight = Words)) +
  geom_bar(aes(fill = Film), 
             position = position_dodge(width = 0.7)) + 
  labs(y = "total words spoken") + 
  theme_light() +
  theme(panel.grid.minor = element_line(colour = "grey95"), 
      panel.grid.major = element_line(colour = "grey95")); p1
    

p2 <- lotr %>% 
  ggplot(aes(x = Race,
             y = Words, 
             color = Film, 
             fill = Film)) + 
  scale_color_brewer(type = "seq", 
                     palette = 7) + 
  scale_fill_brewer(type = "seq", 
                    palette = 7) + 
  scale_y_log10() + 
  geom_jitter(alpha = 1/2, 
             position = position_dodge(width=0.5)) + 
  stat_summary(fun.y = median, 
               pch = 21, 
               geom = "point", 
               size = 6, 
               col = "grey80") + 
  labs(y = "words spoken", 
       subtitle = "Except for Orcs and Hobbits, there's less talking by every \nrace as the films progress \n\nEach data point is number of words spoken by a character \nin a specific chapter", 
       title = "The Lord of the Rings film trilogy") + 
  theme_light() +
  theme(panel.grid.minor = element_line(colour = "grey95"), 
      panel.grid.major = element_line(colour = "grey95")); p2
  



p3 <- lotr %>% 
  filter(Character %in% c("Frodo", 
                          "Sam")) %>% 
  group_by(Character, Film) %>% 
  summarise(total_words = sum(Words)) %>% 
  ggplot(aes(x = Character,
             y = total_words, 
             color = Film, 
             fill = Film)) + 
  scale_color_brewer(type = "seq", 
                     palette = 7) + 
  scale_fill_brewer(type = "seq", 
                    palette = 7) + 
  geom_col(position = "dodge") + 
  labs(y = "Words spoken", 
       subtitle = "Sam really comes into the spotlight as Frodo begins to \nsuccumb to his injuries and the weight of carrying the Ring", 
       title = "The Lord of the Rings film trilogy") + 
  theme_light() +
  theme(panel.grid.minor = element_line(colour = "grey95"), 
        panel.grid.major = element_line(colour = "grey95")); p3



  
write.table(lotr, "lotr_clean.tsv", quote = FALSE,
            sep = "\t", row.names = FALSE)