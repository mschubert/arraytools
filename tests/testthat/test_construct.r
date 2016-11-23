context("construct")

DF = data.frame(expand.grid(LETTERS[1:3], LETTERS[4:5])[-3,], value=1:5)

Gref = structure(c(1L, 2L, 0L, 3L, 4L, 5L), .Dim = c(3L, 2L),
                 .Dimnames = list(c("A", "B", "C"), c("D", "E")))

test_that("summing elements from data.frame to array", {
    G = construct(value ~ Var1 + Var2, data=DF, fun.aggregate=sum)
    #   D E
    # A 1 3
    # B 2 4
    # C 0 5

    expect_equal(G, Gref)
})

test_that("axis variable is NA, should be omitted + print warning", {
    DFna = rbind(DF, NA)
    Gna = construct(value ~ Var1 + Var2, data=DFna, fun.aggregate=sum)
    expect_equal(Gna, Gref)
})

test_that("ambiguous row", {
    DFa = rbind(DF, c("A","D",6))
    expect_error(construct(value ~ Var1 + Var2, data=DFa))
})
