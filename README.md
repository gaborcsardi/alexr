


# alexr

> Catch insensitive, inconsiderate writing

[![Linux Build Status](https://travis-ci.org/gaborcsardi/alexr.svg?branch=master)](https://travis-ci.org/gaborcsardi/alexr)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/gaborcsardi/alexr?svg=true)](https://ci.appveyor.com/project/gaborcsardi/alexr)
[![](http://www.r-pkg.org/badges/version/alexr)](http://www.r-pkg.org/pkg/alexr)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/alexr)](http://www.r-pkg.org/pkg/alexr)


Whether your own or someone else’s writing, alex helps you find gender
favouring, polarising, race related, religion inconsiderate, or other
unequal phrasing.

## Installation


```r
devtools::install_github("gaborcsardi/alexr")
```

## Usage


```r
library(alexr)
alex(<text>)
alex(file(<filename>))
```

If called without any arguments, `alex()` checks all `.md`, `.Rmd` files
in the working directory.

## Example

Let's say `example.md` looks like this:

> The boogeyman wrote all changes to the **master server**. Thus, the slaves
> were read-only copies of master. But not to worry, he was a cripple.

Then
```r
alex(file("example.md"))
```
yields
```
example.md
   1:5-1:14  warning  `boogeyman` may be insensitive, use `boogey` instead
  1:42-1:48  warning  `master` / `slaves` may be insensitive, use
                      `primary` / `replica` instead
  2:52-2:54  warning  `he` may be insensitive, use `they`, `it` instead
  2:59-2:66  warning  `cripple` may be insensitive, use
                      `person with a limp` instead
```

## License

MIT © Titus Wormer, Gábor Csárdi
