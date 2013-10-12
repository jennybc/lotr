Original data file, sporting DOS/Windows line-ending characters and inconsistent quoting behavior that breaks github's display of delimited files, can be found here:

<http://www-958.ibm.com/software/data/cognos/manyeyes/datasets/words-spoken-by-character-race-scene/versions/1.txt>


That was very lightly processed to yield the more machine-readable file:

lotr_wordsSpoken.tsv

> Actually all I did was read it into R and write it back out to file.

Context:

When creating simple examples of automated data analysis pipelines for [STAT 545A](https://github.com/jennybc/STAT545A), I didn't want to use simulated data and I was sick of Gapminder. So I did this. Of course.
