#' Return dimension names of an array respecting the number of dimensions
#'
#' Act on each element if 'x' is a list
#'
#' @param x      An n-dimensional array
#' @param along  Limit to dimension (default: all)    
#' @param null_as_integer  Whether nameless dimensions should be \code{NULL} or numbered
#' @param drop   Drop list of only one axis requested (default: TRUE)
#' @return       A list of dimension names with length \code{length(ndim(X))}
#' @export
dimnames = function(x, along=TRUE, null_as_integer=FALSE, drop=TRUE) {
    UseMethod("dimnames")
}

#' @export
dimnames.data.frame = function(x, along=TRUE, null_as_integer=FALSE, drop=TRUE) {
    dimnames(as.matrix(x), along=along, null_as_integer=null_as_integer, drop=drop)
}

#' @export
dimnames.list = function(x, along=TRUE, null_as_integer=FALSE, drop=TRUE) {
    lapply(x, function(x) dimnames(x, along=along, null_as_integer=null_as_integer, drop=drop))
}

#' @export
dimnames.default = function(x, along=TRUE, null_as_integer=FALSE, drop=TRUE) {
#    if (!is.data.frame(x))
        x = as.array(x)

    dn = base::dimnames(x)
    if (is.null(dn))
        dn = rep(list(NULL), length(dim(x)))

    if (null_as_integer == TRUE)
        dn = lapply(1:length(dn), function(i) {
            if (is.null(dn[[i]]))
                1:dim(x)[i]
            else
                dn[[i]]
        })

    if (!identical(along, TRUE) && length(along) == 1 && drop==TRUE)
        dn[[along]]
    else
        dn[along]
}
