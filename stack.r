.u = import('./util')

#' Stacks arrays while respecting names in each dimension
#'
#' @param arrayList  A list of n-dimensional arrays
#' @param along      Which axis arrays should be stacked on (default: new axis)
#' @param fill       Value for unknown values (default: \code{NA})
#' @return           A stacked array, either n or n+1 dimensional
stack = function(arrayList, along=length(dim(arrayList[[1]]))+1, fill=NA, drop=FALSE) {
    if (!is.list(arrayList))
        stop(paste("arrayList needs to be a list, not a", class(arrayList)))
    length0 = sapply(arrayList, length) == 0
    if (any(length0)) {
        dnames = .u$dimnames(arrayList[length0], null.as.integer=TRUE)
        warning("dropping empty elements: ", paste(dnames, collapse=", "))
        arrayList = arrayList[!length0]
    }
    if (length(arrayList) == 0)
        stop("No element remaining after removing NULL entries")
    if (length(arrayList) == 1)
        return(arrayList[[1]])

    # for vectors: if along=1 row vecs, along=2 col vecs, etc.
    if (all(is.null(unlist(lapply(arrayList, dim))))) {
        if (along == 1)
            arrayList = lapply(seq_along(arrayList), function(i) {
                re = t(as.matrix(arrayList[[i]]))
                rownames(re) = names(arrayList)[i]
                re
            })
        else if (along == 2)
            arrayList = lapply(seq_along(arrayList), function(i) {
                re = as.matrix(arrayList[[i]])
                colnames(re) = names(arrayList)[i]
                re
            })
    }

    newAxis = FALSE
    if (along > length(dim(arrayList[[1]])))
        newAxis = TRUE

    # get dimension names
    dn = lapply(arrayList, .u$dimnames)
    dimNames = lapply(1:length(dn[[1]]), function(j) 
        unique(c(unlist(sapply(1:length(dn), function(i) 
            dn[[i]][[j]]
        ))))
    )

    # track the stacking dimension index if there are no names
    stack_offset = FALSE
    ndim = sapply(dimNames, length)
    if (along <= length(ndim) && ndim[along] == 0) {
        ndim[along] = sum(sapply(arrayList, function(x) dim(x)[along]))
        stack_offset = TRUE
    }
    if (any(ndim == 0))
        stop("Names are required for all dimensions except the one stacked along.
  Use bind() if you want to just bind together arrays without names.")

    # if creating new axis, amend ndim and dimNames
    if (newAxis) {
        dimNames = c(dimNames, list(names(arrayList)))
        ndim = c(ndim, length(arrayList))
    }

    # create an empty result matrix
    result = array(fill, dim=ndim, dimnames=dimNames)

    # fill each result matrix slice with matched values of arrayList
    offset = 0
    for (i in .u$dimnames(arrayList, null.as.integer=TRUE)) {
        dm = .u$dimnames(arrayList[[i]], null.as.integer=TRUE)
        if (stack_offset) {
            dm[[along]] = dm[[along]] + offset
            offset = offset + dim(arrayList[[i]])[along]
        }

        # make sure there are no NAs in names
        if (any(is.na(unlist(dm))))
            stop("NA found in array names, do not know how to stack those")
        if (newAxis)
            dm[[along]] = i
        else {
            # do not overwrite values unless empty or the same
            slice = do.call("[", c(list(result), dm, drop=FALSE))
            if (!all(slice==fill | is.na(slice) | slice==arrayList[[i]]))
                stop("value aggregation not allowed, stack along new axis+summarize after")
        }

        # assign to the slice if there are any values in it
        result = do.call("[<-", c(list(result), dm, list(arrayList[[i]])))
    }

    if (drop)
        drop(result)
    else
        result
}

if (is.null(module_name())) {
    A = matrix(1:4, nrow=2, ncol=2, dimnames=list(c('a','b'),c('x','y')))
    B = matrix(5:6, nrow=2, ncol=1, dimnames=list(c('b','a'),'z'))

    C = stack(list(A, B), along=2)
    #    x y z
    #  a 1 3 6   # B is stacked correctly according to its names
    #  b 2 4 5
    Cref = structure(c(1L, 2L, 3L, 4L, 6L, 5L), .Dim = 2:3,
                     .Dimnames = list(  c("a", "b"), c("x", "y", "z")))
    testthat::expect_equal(C, Cref)

    D = stack(list(m=A, n=C), along=3)
    # , , m          , , n
    #
    #   x y  z         x y z
    # a 1 3 NA       a 1 3 6
    # b 2 4 NA       b 2 4 5
    Dref = structure(c(1L, 2L, 3L, 4L, NA, NA, 1L, 2L, 3L, 4L, 6L, 5L),
                     .Dim = c(2L,3L, 2L), .Dimnames = list(c("a", "b"),
                     c("x", "y", "z"), c("m", "n")))
    testthat::expect_equal(D, Dref)

    # same as first but without colnames
    colnames(A) = NULL
    colnames(B) = NULL
    colnames(C) = NULL
    Cnull = stack(list(A, B), along=2)
    testthat::expect_equal(C, Cnull)

    # vector stacking
    a = b = setNames(1:5, LETTERS[1:5])
    testthat::expect_equal(stack(list(a=a, b=b), along=1),
                           t(stack(list(a=a, b=b), along=2)))
    testthat::expect_equal(stack(list(a=a, a=b), along=1, drop=TRUE), a)
}
