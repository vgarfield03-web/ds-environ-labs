# String Processing & Debugging

## Lecture summary
Practical **string processing** with base R and the tidyverse (`stringr`) plus core **debugging** strategies. We cover regular expressions (regex), pattern detection and extraction, and robust text-cleaning pipelines. Then we practice reading errors and tracebacks, using interactive debuggers (`browser()`, `debugonce()`), and applying a reproducible debugging checklist. The lab applies regex to real-world text and steps through common failure modes.

### Learning objectives

By the end of this chapter you will be able to:

- Recognize and write common **regex** patterns (IDs, dates, codes) and test them.
- Use `stringr` verbs (`str_detect`, `str_extract`, `str_match`, `str_replace`, `str_split`) fluently in pipelines.
- Build tidy **text-cleaning** workflows that parse, reshape, and standardize messy columns.
- Diagnose and fix errors using **traceback**, **rlang::last_trace()**, and interactive tools.
- Apply a **debugging checklist** to isolate minimal failing examples and document fixes.




**String manipulation in base R**

A few of the basic R functions for manipulating strings are *paste*, *strsplit*, and *substring*. *paste* and *strsplit* are basically inverses of each other: *paste* concatenates together an arbitrary set of strings (or a vector, if using the *collapse*
argument) with a user-specified separator character, while *strsplit* splits apart based on a delimiter/separator. *substring* splits apart the elements of a character vector based on fixed widths. *nchar* returns the number of characters in a string. Note that all of these operate in a vectorized fashion.


``` r
out <- paste("My", "name", "is", "Lauren", ".", sep = " ")
out
```

```
## [1] "My name is Lauren ."
```

``` r
## split the string by spaces
strsplit(out, split = ' ')
```

```
## [[1]]
## [1] "My"     "name"   "is"     "Lauren" "."
```

``` r
## count the total number of characters in my string
nchar(out)
```

```
## [1] 19
```
Note that *strsplit* returns a list because it can operate on a character vector (i.e., on multiple strings).



``` r
times <- c("04:18:04", "12:12:53", "13:47:00")
time.pieces <- strsplit(times, ":")
time.pieces
```

```
## [[1]]
## [1] "04" "18" "04"
## 
## [[2]]
## [1] "12" "12" "53"
## 
## [[3]]
## [1] "13" "47" "00"
```

``` r
sapply(time.pieces, length)
```

```
## [1] 3 3 3
```

``` r
sapply(time.pieces, function(x) x[3])
```

```
## [1] "04" "53" "00"
```


*substring* takes the start and end element number to extract or replace. 


``` r
times <- c("04:18:04", "12:12:53", "13:47:00")
substring(times, 7, 8)
```

```
## [1] "04" "53" "00"
```

``` r
substring(times[3], 1, 2) <- '01'   ## replacement
times
```

```
## [1] "04:18:04" "12:12:53" "01:47:00"
```


To identify particular subsequences in strings, there are several related R functions. *grep* will look for a specified string within an R character vector and report back indices identifying the elements of the vector in which the string was found. Note that using the `fixed=TRUE` argument ensures that regular expressions are NOT used. *grepl* will return TRUEs and FALSEs if a pattern is found within a string. 

*gregexpr* will indicate the position in each string that the specified string is found (use *regexpr* if you only want the first occurrence). 

*gsub* can be used to replace a specified string with a replacement string (use *sub* if you only want to replace only the first occurrence). 


``` r
dates <- c("2016-08-03", "2007-09-05", "2016-01-02")
grep("2016", dates)
```

```
## [1] 1 3
```

``` r
grepl("2016", dates)
```

```
## [1]  TRUE FALSE  TRUE
```

``` r
## start/end position of each match
gregexpr("2016", dates)
```

```
## [[1]]
## [1] 1
## attr(,"match.length")
## [1] 4
## attr(,"index.type")
## [1] "chars"
## attr(,"useBytes")
## [1] TRUE
## 
## [[2]]
## [1] -1
## attr(,"match.length")
## [1] -1
## attr(,"index.type")
## [1] "chars"
## attr(,"useBytes")
## [1] TRUE
## 
## [[3]]
## [1] 1
## attr(,"match.length")
## [1] 4
## attr(,"index.type")
## [1] "chars"
## attr(,"useBytes")
## [1] TRUE
```

``` r
gsub("2016", "16", dates)
```

```
## [1] "16-08-03"   "2007-09-05" "16-01-02"
```

**String manipulation using stringr**

The *stringr* package wraps the various core string manipulation functions to provide a common interface. It also removes some of the clunkiness involved in some of the string operations with the base string functions, such as having to to call *gregexpr* and then *regmatches* to pull out the matched strings. For anything but very simple takss, I'd suggest using *stringr* functions in place of R's base string functions.

Table 1 provides an overview of the key functions related to working with patterns, which are basically
wrappers for *grep*, *gsub*, *gregexpr*, etc.


|  Function                         | What it does
|-----------------------------------|---------------------------------------------------------------------
| str_detect                        |                 detects pattern, returning TRUE/FALSE
| str_count                         |                 counts matches
| str_locate/str_locate_all         |                  detects pattern, returning positions of matching characters
| str_extract/str_extract_all       |                  detects pattern, returning matches
| str_replace/str_replace_all       |                  detects pattern and replaces matches

The analog of *regexpr* vs. *gregexpr* and *sub* vs. *gsub* is that most of the functions have versions that return all the matches, not just the first match, e.g. *str_locate_all* *str_extract_all*, etc. Note that the *_all* functions return lists while the non-*_all* functions return vectors.

To specify options, you can wrap these functions around the pattern argument: `fixed(pattern, ignore_case)` and `regex(pattern, ignore_case)`. The default is *regex*, so you only need to specify that if you also want to specify additional arguments, such as *ignore_case* or others listed under `help(regex)` (invoke the help after loading *stringr*)

Let's see *stringr*'s versions of some of the base string functions mentioned in the previous sections.


``` r
str <- c("Apple Computer", "IBM", "Apple apps")

str_locate(str, fixed("app", ignore_case = TRUE))
```

```
##      start end
## [1,]     1   3
## [2,]    NA  NA
## [3,]     1   3
```

``` r
## Not just the first
str_locate_all(str, fixed("app", ignore_case = TRUE))
```

```
## [[1]]
##      start end
## [1,]     1   3
## 
## [[2]]
##      start end
## 
## [[3]]
##      start end
## [1,]     1   3
## [2,]     7   9
```

``` r
dates <- c("2016-08-03", "2007-09-05", "2016-01-02")
## regular expression: years begin in 2010
str_locate(dates, "20[^0][0-9]") 
```

```
##      start end
## [1,]     1   4
## [2,]    NA  NA
## [3,]     1   4
```

The basic interface to *stringr* functions is `function(strings, pattern, [replacement])`. 

**Regular expressions (regex/regexp)**

Regular expressions are a domain-specific language for finding patterns and are one of the key functionalities in scripting languages such as Perl and Python, as well as the UNIX utilities *sed*, *awk* and *grep*. 

The basic idea of regular expressions is that they allow us to find matches of strings or patterns in strings, as well as do substitution.

Regular expressions are good for tasks such as:
 - extracting pieces of text - for example finding all the links in an html document;
 -  cleaning and transforming text (ex. values in a column) into a uniform format;
 -  creating variables from information found in text;
 -  mining text by treating documents as data; and
 -  scraping the web for data.

Also, here's a [cheatsheet on regular expressions](https://github.com/rstudio/cheatsheets/blob/main/regex.pdf) and here is a [website where you can interactively test regular expressions on example strings](https://regex101.com).

**Versions of regular expressions**

One thing that can cause headaches is differences in version of regular expression syntax used.  As can be seen in `help(regex)`, In R, *stringr* provides *ICU regular expressions*, which are based on Perl regular expressions. More details can be found in the [regex Wikipedia page](https://en.wikipedia.org/wiki/Regular_expression).

**Commonly used regex building blocks**
Square brackets can be used to define a list or range of characters to be found. So:

- `[ABC]` matches A or B or C.
- `[A-Z]` matches any upper case letter.
- `[A-Za-z]` matches any upper or lower case letter.
- `[A-Za-z0-9]` matches any upper or lower case letter or any digit.
- `[:digit:]` matches any digit

Then there are:

- `.` matches any character.
- `\d` matches any single digit.
- `\w` matches any part of word character (equivalent to `[A-Za-z0-9]`).
- `\s` matches any space, tab, or newline.
- `\` used to escape the following character when that character is a special character. So, for example, a regular expression that found `.com` would be `\.com` because `.` is a special character that matches any character.
- `^` is an "anchor" which asserts the position at the start of the line. So what you put after the caret will only match if they are the first characters of a line. 
- `$` is an "anchor" which asserts the position at the end of the line. So what you put before it will only match if they are the last characters of a line.

- `\b` asserts that the pattern must match at a word boundary. 
Putting this either side of a word stops the regular expression matching longer variants of words. So:
  - the regular expression `mark` will match not only `mark` but also find `marking`, `market`, `unremarkable`, and so on.
  - the regular expression `\bword` will match `word`, `wordless`, and `wordlessly`.
  - the regular expression `comb\b` will match `comb` and `honeycomb` but not `combine`.
  - the regular expression `\brespect\b` will match `respect` but not `respectable` or `disrespectful`.

Other useful special characters are:

- `*` matches the preceding element zero or more times. For example, ab\*c matches "ac", "abc", "abbbc", etc.
- `+` matches the preceding element one or more times. For example, ab+c matches "abc", "abbbc" but not "ac".
- `?` matches when the preceding character appears zero or one time.
- `{VALUE}` matches the preceding character the number of times defined by VALUE; ranges, say, 1-6, can be specified with the syntax `{VALUE,VALUE}`, e.g. `\d{1,9}` will match any number between one and nine digits in length.
- `|` means **or**.

**General principles for working with regex**

The syntax is very concise, so it's helpful to break down individual regular expressions into the component parts to understand them.  Since regex are their own language, it's a good idea to build up a regex in pieces as a way of avoiding errors just as we would with any computer code. *str_detect* in R's *stringr* is particularly useful in seeing *what* was matched to help in understanding and learning regular expression syntax and debugging your regex. 

The *grep*, *gregexpr* and *gsub* functions and their *stringr* analogs are more powerful when used with regular expressions. In the following examples, we'll illustrate usage of *stringr* functions, but  with their base R analogs as comments.

**Working with patterns**

First let's see the use of character sets and character classes.


``` r
text <- c("Here's my number: 919-543-3300.", "hi John, good to meet you",
          "They bought 731 bananas", "Please call 919.554.3800")
str_detect(text, "[[:digit:]]")
```

```
## [1]  TRUE FALSE  TRUE  TRUE
```

``` r
## grep("[[:digit:]]", text, perl = TRUE)
```


``` r
# Match a single character present in the list below [:,\t.]
str_detect(text, "[:,\t.]")
```

```
## [1]  TRUE  TRUE FALSE  TRUE
```

``` r
## grep("[:,\t.]", text)

str_locate_all(text, "[:,\t.]")
```

```
## [[1]]
##      start end
## [1,]    17  17
## [2,]    31  31
## 
## [[2]]
##      start end
## [1,]     8   8
## 
## [[3]]
##      start end
## 
## [[4]]
##      start end
## [1,]    16  16
## [2,]    20  20
```

``` r
## gregexpr("[:,\t.]", text)

# + matches the previous token between one to unlimited times
# [:digit:] matches a digit [0-9] (also written as \d)

str_extract_all(text, "[[:digit:]]+")
```

```
## [[1]]
## [1] "919"  "543"  "3300"
## 
## [[2]]
## character(0)
## 
## [[3]]
## [1] "731"
## 
## [[4]]
## [1] "919"  "554"  "3800"
```

``` r
## matches <- gregexpr("[[:digit]]+", text)
## regmatches(text, matches)

str_replace_all(text, "[[:digit:]]", "Z")
```

```
## [1] "Here's my number: ZZZ-ZZZ-ZZZZ." "hi John, good to meet you"      
## [3] "They bought ZZZ bananas"         "Please call ZZZ.ZZZ.ZZZZ"
```

``` r
## gsub("[[:digit:]]", "Z", text)
```

## In class challenge: What will the regular expression `^[Oo]rgani.e\b` match?




Now let's make use of repetitions.

Let's search for US/Canadian/Caribbean phone numbers in the example text we've been using: 



``` r
text <- c("Here's my number: 919-543-3300.", "hi John, good to meet you",
          "They bought 731 bananas", "Please call 919.554.3800")
pattern <- "[[:digit:]]{3}[-.][[:digit:]]{3}[-.][[:digit:]]{4}"
str_extract_all(text, pattern)
```

```
## [[1]]
## [1] "919-543-3300"
## 
## [[2]]
## character(0)
## 
## [[3]]
## character(0)
## 
## [[4]]
## [1] "919.554.3800"
```

``` r
## matches <- gregexpr(pattern, text)
## regmatches(text, matches)
```

### In class challenge 2: How would I extract an email address from an arbitrary text string?



**Groups**

- Parentheses () in a regular expression define a capturing group.

- The backreference \\1 refers to the first capturing group in the same regex.

For example, here we'll find any numbers and add underscores before and after them:


``` r
text <- c("Here's my number: 919-543-3300.", "hi John, good to meet you",
          "They bought 731 bananas", "Please call 919.554.3800")

# Match a single character present in the list below [0-9]
# + matches the previous token between one to unlimited times
# 0-9 matches a single character in the range between 0

str_replace_all(text, "([0-9]+)", "_\\1_")
```

```
## [1] "Here's my number: _919_-_543_-_3300_."
## [2] "hi John, good to meet you"            
## [3] "They bought _731_ bananas"            
## [4] "Please call _919_._554_._3800_"
```

In class challenge 3: Suppose a text string has dates in the form “Aug-3”, “May-9”, etc. and I want them in the form “3 Aug”, “9 May”, etc. How would I do this search/replace?

**Other comments**

Regular expression can be used in a variety of places. E.g., to split by any number of white space characters


``` r
line <- "a dog\tjumped\nover \tthe moon."
cat(line)
```

```
## a dog	jumped
## over 	the moon.
```

``` r
str_split(line, "[[:space:]]+")
```

```
## [[1]]
## [1] "a"      "dog"    "jumped" "over"   "the"    "moon."
```

``` r
str_split(line, "[[:blank:]]+")
```

```
## [[1]]
## [1] "a"            "dog"          "jumped\nover" "the"          "moon."
```

Using backslashes to 'escape' particular characters can be tricky. One rule of thumb is to just keep adding backslashes until you get what you want!


``` r
## last case here is literally a backslash and then 'n'
strings <- c("Hello", "Hello.", "Hello\nthere", "Hello\\nthere")
cat(strings, sep = "\n")
```

```
## Hello
## Hello.
## Hello
## there
## Hello\nthere
```

``` r
str_detect(strings, ".")           ## . means any character
```

```
## [1] TRUE TRUE TRUE TRUE
```

``` r
## str_detect(strings, "\.")       ## \. looks for the special symbol \.
str_detect(strings, "\\.")         ## \\ says treat \ literally, which then escapes the .
```

```
## [1] FALSE  TRUE FALSE FALSE
```

``` r
str_detect(strings, "\n")          ## \n looks for the special symbol \n
```

```
## [1] FALSE FALSE  TRUE FALSE
```

``` r
## str_detect(strings, "\\")       ## \\ says treat \ literally, but \ is not meaningful regex
str_detect(strings, "\\\\")        ## R parser removes two \ to give \\; then in regex \\ treats second \ literally
```

```
## [1] FALSE FALSE FALSE  TRUE
```


**Additional resources**

- Wickham (2019) *R for Data Science*, Chapters on Strings & Regular Expressions.  
- RStudio cheatsheets: **Stringr**, **Regex**, **Debugging**.  
