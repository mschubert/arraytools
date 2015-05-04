.s = import('./subset')

#' Splits and array along a given axis, either totally or only subsets
#'
#' @param X        An array that should be split
#' @param along    Along which axis to split
#' @param subsets  Whether to split each element or keep some together
#' @return         A list of arrays that combined make up the input array
split = function(X, along, subsets=c(1:dim(X)[along]), drop=FALSE) {
    if (!is.array(X) && !is.vector(X) && !is.data.frame(X))
        stop("X needs to be either vector, array or data.frame")
#    .check$all(X, along, subsets, x.to.array=FALSE) # breaks data.frame

    usubsets = unique(subsets)
    lus = length(usubsets)
    idxList = rep(list(rep(list(TRUE), length(dim(X)))), lus)

    for (i in 1:lus)
        idxList[[i]][[along]] = subsets==usubsets[i]

    if (length(usubsets)!=dim(X)[along] || !is.numeric(subsets))
        lnames = usubsets
    else
        lnames = base::dimnames(X)[[along]]
    setNames(lapply(idxList, function(ll) .s$subset(X, ll, drop=drop)), lnames)
}
