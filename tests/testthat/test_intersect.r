library(testthat)

A = matrix(1:4, nrow=2, ncol=2, dimnames=list(c('a','b'),c('x','y')))
C = structure(c(1L, 2L, 3L, 4L, 6L, 5L), .Dim = 2:3,
    .Dimnames = list(c("a", "b"), c("x", "y", "z")))
E = C[,c(2,3,1)]
DF = structure(list(y=3:4, z=c(6,5), x=1:2, A=c("b", "a")),
               .Names=c("y","z","x","A"), row.names=1:2, class="data.frame")
DF2 = as.data.frame(E[1,,drop=FALSE])

AElist = intersect_list(list(A=A, E=E), along=2)

# provided env should not change global vars or non-ref'd list elms
ll = list(A=A, E=E, DF=DF)
AEenv = intersect(A, E, along=2, envir=ll)
expect_equal(ll$A, A)
expect_equal(ll$E, AElist$E)
expect_equal(ll$DF, DF)

intersect(A, E, along=2)
# > A         > E
#   x y         x y   # along dimension 2, all arrays have same extent
# a 1 3       a 1 3   # and same order of names; this function modifies
# b 2 4       b 2 4   # values in-place

AEref = structure(1:4, .Dim = c(2L, 2L),
                  .Dimnames = list(c("a", "b"), c("x", "y")))
expect_equal(A, AEref)
expect_equal(E, AEref)
expect_equal(AElist$A, AEref)
expect_equal(AElist$E, AEref)

ADFlist = intersect_list(list(A=A, DF=DF2))
expect_equal(ADFlist$A, AEref[1,,drop=FALSE])
expect_equal(ADFlist$DF, DF2)

ADFlist = intersect_list(list(A=A, DF=DF2), along=2, drop=TRUE)
intersect(A, DF2, along=2, drop=TRUE)
expect_equal(A, AEref)
expect_equal(DF2, list(x=1, y=3))
expect_equal(ADFlist$A, AEref)
expect_equal(ADFlist$DF, DF2)

DFref = DF[c(2,1),]
rownames(DFref) = as.character(rownames(DFref)) # why, R?
intersect(A, DF$A, along=1)
expect_is(A, "matrix")
expect_is(DF, "data.frame")
expect_equal(DF, DFref)
expect_true(all(DF == DFref))

ll = list(a=setNames(1:5, letters[1:5]), b=setNames(2:4, letters[2:4]))
lli = intersect_list(ll)
intersect(a,b,envir=ll)
expect_equal(ll$a, lli$a)
expect_equal(ll$b, lli$b)
