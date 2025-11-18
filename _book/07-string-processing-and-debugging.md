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




### String manipulation in base R

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

### String manipulation using *stringr*

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

### Regular expressions (regex/regexp)

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

### General principles for working with regex

The syntax is very concise, so it's helpful to break down individual regular expressions into the component parts to understand them.  Since regex are their own language, it's a good idea to build up a regex in pieces as a way of avoiding errors just as we would with any computer code. *str_detect* in R's *stringr* is particularly useful in seeing *what* was matched to help in understanding and learning regular expression syntax and debugging your regex. 

The *grep*, *gregexpr* and *gsub* functions and their *stringr* analogs are more powerful when used with regular expressions. In the following examples, we'll illustrate usage of *stringr* functions, but  with their base R analogs as comments.

### Working with patterns

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

## In class challenge 2: How would I extract an email address from an arbitrary text string?



### Groups

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

### Other comments

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


### Additional resources

- Wickham (2019) *R for Data Science*, Chapters on Strings & Regular Expressions.  
- RStudio cheatsheets: **Stringr**, **Regex**, **Debugging**.  


## Dicussion & Reflection: Debugging in R 


How to use R's debugging tools, handle errors, and avoid bugs

### 1) Basic debugging strategies

1. Read and think about the error message. Sometimes it's inscrutable, but often it just needs a bit of deciphering. Looking up a given error message on Stack Overflow or simply doing a web search with the exact message in double quotes can be a good strategy.

2. Fix errors from the top down - fix the first error that is reported, because later errors are often caused by the initial error. It's common to have a string of many errors, which looks daunting, caused by a single initial error.

3. Is the bug reproducible - does it always happen in the same way at at the same point? It can help to restart R and see if the bug persists - this can sometimes help in figuring out if there is a scoping issue and we are using a global variable that we did not mean to. 

4. Another basic strategy is to build up code in pieces (or tear it back in pieces to a simpler version). This allows you to isolate where the error is occurring.

5. If you've written your code modularly with lots of functions, you can test individual functions. Often the error will be in what gets passed into and out of each function.

6. You can have warnings printed as they occurred, rather than saved, using `options(warn = 1)`. This can help figure out where in a loop a warning is being generated. You can also have R convert warnings to error using `options(warn = 2)`. 

7. At the beginning of time (the 1970s?), the standard debugging strategy was to insert print statements in one's code to see the value of a variable and thereby decipher what could be going wrong. We have better tools nowadays, but this approach is still useful, particularly when you are having an issue with control statements (for loops, if/else). 

8. R is a scripting language, so you can usually run your code line by line to figure out what is happening. This can be a decent approach, particularly for simple code. However, when you are trying to find errors that occur within a series of many nested function calls or when the errors involve variable scoping (how R looks for variables that are not local to a function), or in other complicated situations, using formal debugging tools can be much more effective.  Finally, if the error occurs inside of functions provided by R, rather than ones you write, it can be hard to run the code in those functions line by line. 


###  R's interactive debugging tools

This section gives an overview of the various debugging tools. 

Note that RStudio wraps all of functionality of these tools in its graphical interface, so you can use all the tools there, but the tools will be provided with some additional graphical functionality from RStudio.

#### Interactive debugging via the browser

The core strategy for interactive debugging is to use the *browser* function, which pauses the current execution, and provides an interpreter, allowing you to view the current state of R. You can invoke *browser* in four ways

 - by inserting a call to `browser()` in your code if you suspect where things are going wrong

 - by invoking the browser after every step of a function using *debug*

 - by using `options(error = recover)` to invoke the browser when an error occurs

 - by temporarily modifying a function to allow browsing using *trace* 

Once in the browser, you can execute any R commands you want. In particular, using *ls* to look at the objects residing in the current function environment, looking at the values of objects, and examining the classes of objects is often helpful.

Type Q in the Console to exit browser. 

#### Using *debug* to step through code

To step through a function, use `debug(nameOfFunction)`. Then run your code. When the function is executed, R will pause execution just before the first line of the function. You are now using the browser and can examine the state of R and execute R statements.

Once in the browser context, you can use 'n' or <return> to step to the next line, 'f' to finish executing the entire current function or current loop, 'c' to continue to any subsequent browser calls, or 'Q'  to stop debugging. We'll see this in the screencast demo.

To unflag the function so that calling it doesn't invoke debug, use `undebug(nameOfFunction)`. In addition to working with functions you write you can use *debug* with standard R functions and functions from packages. For example you could do `debug(glm)`.

If you know you only want to run the function once in debugging mode (to avoid having to use *undebug*), use `debugonce(nameOfFunction)`. 

#### Tracing errors in the call stack

*traceback* and *recover* allow you to see the call stack at the time of the error - i.e., they will show you all the functions that have been called, in the order called. This helps pinpoint where in a series of function calls the error may be occurring.

If you've run the code and gotten an error, you can invoke *traceback* after things have gone awry. R will show you the call stack, which can help pinpoint where an error is occurring. 

More helpful is to be able to browse within the call stack. To do this invoke `options(error = recover)` (potentially in your *.Rprofile* if you do a lot of programming). Then when an error occurs, *recover* gets called, usually from the function in which the error occurred. The call to *recover* allows you to navigate the stack of active function calls at the time of the error and browse within the desired call. You just enter the number of the call you'd like to enter (or 0 to exit). You can then look around in the frame of a given function, entering <return> when you want to return to the list of calls again. 

You can also combine this with `options(warn = 2)`, which turns warnings into errors to get to the point where a warning was issued. 

#### Using *trace* to temporarily insert code

*trace* lets you temporarily insert code into a function (including standard R functions and functions in packages!) that can then be easily removed. You can use trace in a variety of ways. 

The most flexible way to use *trace* is to use the argument `edit = TRUE` and then insert whatever code you want wherever you want in the function given as the first argument to *trace*. If I want to ensure I use a particular editor, such as emacs, I can use the argument `edit = “emacs”`. A standard approach would be to add a line with `browser()` at some point in the function to be able to step through the code from that point.  

You can also use *trace* without directly editing the function. Here are a couple examples:

 - `trace(lm, recover)` # invoke *recover* when the function (*lm* in this case) starts
 - `trace(lm, exit = browser)` # invoke *browser* when the function ends

You call *untrace*, e.g., `untrace(lm)`, to remove the temporarily inserted code; otherwise it's removed when the session ends. 

To figure out why warnings are being issued, you can do `trace(warning, recover)` which will insert a call to *recover* whenever *warning* is called.

Of course you can manually change the code in a function without using *trace*, but it's very easy to forget to change things back (and a pain to remember exactly what you changed) and hard to do this with functions in packages, so *trace* is a nice way to do things. 


### Some common causes of bugs

Some of these are R-specific, while others are common to a variety of languages.

 - Parenthesis mis-matches
 - `[[...]]` vs. `[...]`
 - `==` vs. `=`
 - Comparing real numbers exactly using `==` is dangerous because numbers on a computer are only represented to limited numerical precision. For example,
    
 - You expect a single value but execution of the code gives a vector
 - You want to compare an entire vector but your code just compares the first value (e.g., in an if statement) -- consider using *identical* or *all.equal*
 - Silent type conversion when you don't want it, or lack of coercion where you're expecting it
 - Using the wrong function or variable name
 - Giving unnamed arguments to a function in the wrong order
 - In an if-else statement, the `else` cannot be on its own line (unless all the code is enclosed in `{}`) because R will see the `if` part of the statement, which is a valid R statement, will execute that, and then will encounter the `else` and return an error.
 - Forgetting to define a variable in the environment of a function and having R, via lexical scoping, get that variable as a global variable from one of the enclosing environments. At best the types are not compatible and you get an error; at worst, you use a garbage value and the bug is hard to trace. In some cases your code may work fine when you develop the code (if the variable exists in the enclosing environment), but then may not work when you restart R if the variable no longer exists or is different.
- R (usually helpfully) drops matrix and array dimensions that are extraneous. This can sometimes confuse later code that expects an object of a certain dimension.

### Tips for avoiding bugs and catching errors

#### Practice defensive programming

When writing functions, and software more generally, you'll want to warn the user or stop execution when there is an error and exit gracefully, giving the user some idea of what happened. Here are some things to consider:

 - check function inputs and warn users if the code will do something they might not expect or makes particular choices;
 - check inputs to `if` and the ranges in `for` loops;
 - provide reasonable default arguments;
 - document the range of valid inputs;
 - check that the output produced is valid; and
 - stop execution based on checks and give an informative error message.

The *warning* and *stop* functions allow you to do stop execution and issue warnings or errors in the same way that base R code does; in general they would be called based on an `if` statement. More succinctly, to stop code if a condition is not satisfied, you can use *stopifnot*. This allow you to catch errors that can be anticipated. I also recommend using some of R's packages for doing such checks, such as *assertthat*, *assertr*, and *checkmate*.

Here's an example of building a robust square root function using *stop* and *warning*. Note you could use `stopifnot(is.numeric(x))` or `assert_that(is.numeric(x))` in place of one of the checks here.



#### Catch run-time errors with  `try` statements

Also, sometimes a function you call will fail, but you want to continue execution. For example, suppose you are doing a stratified analysis in which you take subsets of your data based on some categorical variable and fit a statistical model for each value of the categorical variable. If some of the subsets have no or very few observations, the statistical model fitting might fail. To do this, you might be using a for loop or *lapply*. You want your code to continue and fit the model for the rest of the cases even if one (or more) of the cases cannot be fit.  You can wrap the function call that may fail within the `try` function (or `tryCatch`) and then your code won't stop, even when an error occurs. Here's a toy example.


```
## Error in lm.fit(x, y, offset = offset, singular.ok = singular.ok, ...) : 
##   0 (non-NA) cases
```

The seventh stratum had no observations, so that call to *lm* failed, but the loop continued because we 'caught' the error with *try*. In this example, we could have checked the sample size for the subset before doing the regression, but in other contexts, we may not have an easy way to check in advance whether the function call will fail.

You can also use `browser` with `try` to inspect what is breaking your code. 



#### Find and avoid global variables

In general, using global variables (variables that are not created or passed into a function) results in code that is not robust. Results will change if you or a user modifies that global variable, usually without realizing/remembering that a function depends on it.

Start every script by removing any lingering objects. 


This can also be accomplished with the "bloom" in the environment panel in R studio. 

To be systematic, the *codetools* library has some useful tools for checking code, including a function, *findGlobals*, that let's you look for the use of global variables

#### Miscellaneous tips

 - Use core R functionality and algorithms already coded. Figure out if a functionality already exists in (or can be adapted from) an R package (or potentially in a C/Fortran library/package): code that is part of standard mathematical/numerical packages will probably be more efficient and bug-free than anything you would write.
 - Code in a modular fashion, making good use of functions, so that you don't need to debug the same code multiple times. Smaller functions are easier to debug, easier to understand, and can be combined in a modular fashion (like the UNIX utilities).
 - Write code for clarity and accuracy first; then worry about efficiency. Write an initial version of the code in the simplest way, without trying to be efficient (e.g., you might use for loops even if you're coding in R); then make a second version that employs efficiency tricks and check that both produce the same output.
 - Plan out your code in advance, including all special cases/possibilities.
 - Write tests for your code early in the process.
 - Build up code in pieces, testing along the way. Make big changes in small steps, sequentially checking to see if the code has broken on test case(s).
 - Be careful that the conditions of `if` statements and the sequences of `for` loops are robust when they involve evaluating R code.
 - Don't hard code numbers - use variables (e.g., number of iterations, parameter values in simulations), even if you don't expect to change the value, as this makes the code more readable and reduces bugs when you use the same number multiple times; e.g. `speedOfLight <- 3e8` or `nIts <- 1000`.

### How to get help online

####  Mailing lists and online forums

There are several mailing lists that have lots of useful postings. In general if you have an error, others have already posted about it.

 - [Stack overflow](http://stackoverflow.com): R stuff will be tagged with 'R': [http://stackoverflow.com/questions/tagged/r](http://stackoverflow.com/questions/tagged/r)
 - R help special interest groups (SIG) such as r-sig-hpc (high performance computing), r-sig-mac (R on Macs), etc. Unfortunately these are not easily searchable, but can often be found by simple web searchs, potentially including the name of the SIG in the search.
 - Simple web searches: You may want to include "in R", with the quotes in the search. To search a SIG you might include the name of the SIG in the search string

####  Asking questions online

If you've searched the archive and haven't found an answer to your problem, you can often get help by posting to the R-help mailing list or one of the other lists mentioned above. A few guidelines (generally relevant when posting to mailing lists beyond just the R lists):

Search the archives and look through relevant R books or manuals first.

Boil your problem down to the essence of the problem, giving an example, including the output and error message

Say what version of R, what operating system and what operating system version you're using. Both *sessionInfo* and *Sys.info* can be helpful for getting this information.

Read the [R mailing list posting guide](https://www.r-project.org/posting-guide.html).

The R mailing lists are a way to get free advice from the experts, who include some of the world's most knowledgeable R experts - seriously - members of the R core development team contribute frequently. The cost is that you should do your homework and that sometimes the responses you get may be blunt, along the lines of “read the manual”. I think it's a pretty good tradeoff - where else do you get the foremost experts in a domain actually helping you?

##### Pre‑class reflection (please submit short answers via canvas)

1. **Your debugging workflow.**  Describe the steps you currently take when code fails. Which step from the reading would most improve your process, and why?

##### In‑class small‑group prompts

1. Step through with browser() (10–12 min)

Goal: Practice pausing and inspecting local state.

Add a breakpoint and re-run:


``` r
good <- function(x) {
  browser()               # step in: n (next), c (continue)
  y <- x + 1
  mean(y, na.rm = TRUE)
}
debugonce(good)
good(c(1, 2, NA, 4))
```

While paused:

- Inspect objects (ls(), str(x), class(x)), then step and re-inspect.
- Change x in place and continue — what happens?
- Remove the breakpoint and create a quick unit-style check that would have caught the bug earlier.






## Lab: Regular expressions and cleaning OBA data (Student Version)

### Lesson Overview

**Conservation/ecology Topics** 

- Species distributions 

**Computational Topics**
-  Use regular expressions to clean and categorize data

-------------------------------


###   Lab question 1: Oregon bee atlas data exploration 

Import the OBA data using your favorite parsing function, name the data oba. 

-1a. 

``` r
## your code here
```


-1b. Examine the unique entries of 'Associated.plant' using any function you find useful. What are at least 10 patterns in the associated taxa string what should be removed if we want consistent plant names? (Make a list together as a class). Only print the first 10 here to avoid having a giant output. 

1. ...

In week in lecture last I used a brute force pattern to remove some of these issues so we could plot them as a network. Now that we are familiar with regular expressions we can do better. 

-1c. Work together as a class to resolve the issues you listed with the associated taxa column using any function combination that uses regular expressions. You can reassign the contents of the column Associated.plant or create a new column. Return the sorted, unique values, ex: sort(unique(oba$Associated.plant)). Leave the plants resolved only to genus of family for later. 

I have removed a really strange issue with special characters (R converted an apostrophe into a special character) to start things off. 

Hint: You must \ any special characters. For example to use \s (matches any space, tab, or newline) you must use \\s in your pattern.


``` r
###  # Remove the special character
oba$Associated.plant <- str_replace_all(oba$Associated.plant, "\x92", "")

###  # To check that it worked
sort(unique(oba$Associated.plant))[1:10]

###   Removing common names in ()
oba$Associated.plant <- gsub("\\s*\\(.*?\\)", "", oba$Associated.plant)

###   3. Removing lists
oba <- oba[!grepl(",", oba$Associated.plant),]
#5
oba$Associated.plant = str_replace_all(oba$Associated.plant, "net", "")
#6
oba$Associated.plant = str_replace_all(oba$Associated.plant, "[A-Za-z]+[.]", "")
###   4. Removing blanks
oba <- oba[oba$Associated.plant != "",]
###   7.
oba$Associated.plant <- str_replace_all(oba$Associated.plant, "[A-Za-z]++[Xx]", "")

###   Determining plant resolution
oba$Plant.resolution <- sapply(oba$Associated.plant, function(x) {
  words <- unlist(strsplit(x, " "))
  if (length(words) == 1){
    "Family/Genus/Common Name"
  } else if (length(words) == 2 && grepl("//.", x)) {
    "Genus"
    } else if (length(words) == 2) {
    "GenusSpecies"
} else {
      "Missing/Complex"
  }
})
```

### Lab question 2: Making a column for plant resolution

-2a. Some plant species are resolved to species/subspecies, others to genus and others to family. If there are two or three words, we can assume the plant is resolved to species and subspecies, respectively, except if the string ends in "sp." If there is only one word, this could be a genus or a family name. Family names always end in "aceae", for example Lamiaceae (mints), Asteraceae (daisies). 

We want to make a new column called plantResolution and assign it to "Family", "Genus" or "Species" depending on the level of resolution associated taxa is resolved to. We will do this in two steps. 

First use regular expressions to count up the number of words in each element of associated taxa. Assign the count to a new column called plantTaxaWordCount. Print the first 50 elements.

Hint: `str_count` may be useful. 


``` r
## your code here
```

-2b. Write a for loop to assigned each entry of the column plantResolution to be "family", "genus" or "species". `table()` the final result. 
Hint: Don't forget to initialize the new column. Starting with all NAs may be useful. 
Hint hint: The function `ifelse` returns one value if a TRUE and another if FALSE. It could be useful depending on your approach. 
Hint hint hint: `grepl` will return or TRUE or FALSE depending on whether it finds the pattern. Be careful with periods in patterns because alone they are a wild card character.  



-2c. For those that are identified to genus but are lacking an sp., add that now so that they will not be treated as separate plant species (i.e., Rosa vs Rosa sp.). You can do this with a regular expression and using 'gsub' or 'string_replace_all' or by counting up the number of words in Associated.plant. 

``` r
## your code here

## To check that it worked, uncomment the below
#unique(oba$Associated.plant[oba$plantResolution == "genus"])
```

-2d. Create a new column called plantGenus that is the genus if the associated taxa was resolved to species or genus, and NA if it was resolved to family. 

``` r
## To check finish with
# table(oba$plantGenus)
```

Now you have nice clean plant data to make networks out of, or more easily count up the number of plant species in an area. 
