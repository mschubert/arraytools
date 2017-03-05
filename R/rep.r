#' Repeats an array along an arbitrary axis
#'
#' @param x      An array object
#' @param n      Integer, how often to repeat
#' @param along  Along which axis to repeat (default: 1)
#' @return       An array that is repeated `n` times on axis `along`
rep = function(x, n, along=1) {
    xl = rep(list(x), n)
    bind(xl, along=along)
}

#' @rdname rep
crep = function(x, n) rep(x, n, along=2)

#' @rdname rep
rrep = function(x, n) rep(x, n, along=1)
