# _common.R -- sourced by knitr before rendering each Rmd
# Normalize options to avoid vector-to-logical coercion errors in bookdown
try({
  cur_in <- tryCatch(knitr::current_input(), error = function(e) NULL)
  ir <- knitr::opts_knit$get("input_rmd")
  if (length(ir) != 1) {
    knitr::opts_knit$set(input_rmd = if (is.null(cur_in)) "index.Rmd" else cur_in)
  }
  pv <- knitr::opts_knit$get("preview")
  if (length(pv) != 1) {
    knitr::opts_knit$set(preview = FALSE)
  }
  knitr::opts_knit$set(root.dir = getwd(), input.dir = getwd())
}, silent = TRUE)
