
#' ---
#' title: "Exploring the `lotr` data"
#' author: "Jenny Bryan"
#' date: "May 19th, 2019"
#' ---

library(tidyverse)


#' This is a quick and dirty exploration so I can build an
#' example for STAT 545A. Those scripts had to be lean, so I
#' did more fiddling here

lotr <- read.delim("lotr_wordsSpoken.tsv")

str(lotr)

head(lotr)



#' ### Reorder `Film` factor based on story order:  
lotr <- lotr %>% 
  mutate(Film = fct_relevel(Film, 
                            c("The Fellowship Of The Ring", 
                              "The Two Towers", 
                              "The Return Of The King")))


#' ### Getting rid of some observations: 
#' * I've always found the Ent parts really boring 
#' * Nazgul and the Dead just don't talk enough 
#' * Gollum is not a Race!
lotr <- lotr %>% 
  filter(!(Race %in% c("Gollum", "Ent", "Dead", "Nazgul"))) %>% 
  droplevels()
  
#' ### Modifying `Race` for Wizards and Men: 
#' * the wizards' Race is Istari (singular: Istar), a subset
#' of the Ainur
#' * Men should be Man, for consistency
lotr <- lotr %>% 
  mutate(Race = case_when(Character %in% c("Gandalf", 
                                           "Saruman") ~ "Istar", 
                          TRUE ~ as.character(Race)) %>% as.factor()) %>% 
  
  mutate(Race = fct_recode(Race, 
                           Man = "Men"))


#' ### Who speaks a lot?
words <-
  lotr %>% 
  count(Race, 
        wt = Words, 
        sort = TRUE, 
        name = "total_words")


#' ### Reorder `Race` based on words spoken
lotr <- lotr %>% 
  mutate(Race = fct_reorder(Race,
                            Words, 
                            sum))

levels(lotr$Race)


#' ### Exploring with visualizations: 
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