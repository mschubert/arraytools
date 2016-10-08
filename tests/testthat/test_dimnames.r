library(testthat)

dn = list(c('a','b'),c('x','y'))
a = setNames(1:2, dn[[1]])
A = matrix(1:4, nrow=2, ncol=2, dimnames=dn)
DF = structure(list(y=3:4, z=c(6,5), x=1:2, A=c("b", "a")),
        .Names=c("y","z","x","A"), row.names=1:2, class="data.frame")
ll = list(a=a, A=A, DF=DF)

# vector
expect_equal(dimnames(a), dn[1])
expect_equal(dimnames(a, along=1), dn[[1]])
expect_equal(dimnames(a, along=1, drop=FALSE), dn[1])
expect_error(dimnames(a, along=2))

# matrix
expect_equal(dimnames(A), dn)
expect_equal(dimnames(A, along=2), dn[[2]])

# data.frame
expect_equal(dimnames(DF, along=1), as.character(1:2))

# list
dnl = dimnames(ll)
expect_equal(dnl$a, dn[1])
expect_equal(dnl$A, dn)
dnl1 = dimnames(ll, along=1)
expect_equal(dnl1$a, dnl1$A, dn[[1]])
