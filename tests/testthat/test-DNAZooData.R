context("test-DNAZooData")

test_that("DNAZooData function works", {
    expect_no_warning(DNAZooData())
    expect_error(DNAZooData('sdvsd'))
    expect_no_warning(s <- DNAZooData(species = 'Hypsibius_dujardini'))
    expect_s4_class(s, 'HicFile')
})
