#' A wrapper around reshape2::acast using a more intuitive formula syntax
#'
#' The construct() function can be called either with the data.frame as the
#' first argument or the formula and then specify `data=<data.frame>`
#'
#' @param data           A data frame
#' @param formula        A formula: value ~ axis1 [+ axis2 + axis n ..]
#' @param fill           Value to fill array with if undefined
#' @param name_axes      Keep column names of `data` as axis names
#' @return               A structured array
#' @export
construct = function(data, formula=guess_structure(data), fill=NA,
                     name_axes=TRUE) {
    if (!is.data.frame(data))
        stop("`data` needs to reference a data.frame")

    dep_var = all.vars(formula[[2]])
    if (length(dep_var) != 1)
        stop("The dependent variable (left side of ~) needs to reference exactly one variable")

    indep_vars = all.vars(formula[[3]]) #TODO: if factor, include all levels in matrix

    axis_NA = apply(is.na(data[indep_vars]), 1, any)
    if (any(axis_NA)) {
        warning("Omitting ", sum(axis_NA), " rows where axis columns are NA")
        data = data[!axis_NA,]
    }

    axes = data[indep_vars]
    values = data[[dep_var]]

    if (any(duplicated(axes)))
        stop("Duplicated entries in `data` are not allowed")

    dimNames = lapply(axes, unique)
    ndim = sapply(dimNames, length)

    order_df = do.call(data.frame, mapply(base::match, axes, dimNames, SIMPLIFY=FALSE))
    order_df$df = 1:nrow(order_df)
    order_ar = do.call(expand.grid, lapply(ndim, seq_len))
    order_ar$ar = 1:nrow(order_ar)

    idx = merge(order_ar, order_df, all.x=TRUE, sort=FALSE)
    idx = idx[order(idx$ar),]

    if (!name_axes)
        names(dimNames) = NULL

    array(values[idx$df], dim=unname(ndim), dimnames=dimNames)
}
