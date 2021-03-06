## ---- echo = FALSE, results = "hide"------------------------------------------
options (width = 80)
library (datasets)

## -----------------------------------------------------------------------------
iris0 <- iris1 <- cbind (iris, N = 1:50)

## with some some cell differences
iris1[4, 1] <- 80
iris1[5, 2] <- 90
iris1[6, 3:4] <- 100 

## with some different rows
iris0 <- iris0[-(1:3),]
iris1 <- iris1[-150]

## with some different columns
iris0[,"mycol0"] <- "A"
iris1[,c ("mycol1", "mycol2")] <- "B"

## with some duplicated rows
iris0 <- rbind (iris0, iris0[10,])
iris1 <- rbind (iris1, iris1[20:21,])

## -----------------------------------------------------------------------------
head (iris0)
head (iris1)

## -----------------------------------------------------------------------------
library (tabdif)
dif <- compareDataFrames (iris0, iris1, rowKeys = c ("N", "Species"))
summary (dif)

## -----------------------------------------------------------------------------
dif$dif.cells

## -----------------------------------------------------------------------------
dfcomp2xlsx (dif, file = "dif_report.xlsx")

## ---- echo = FALSE, results = "hide"------------------------------------------
unlink ("dif_report.xlsx")

