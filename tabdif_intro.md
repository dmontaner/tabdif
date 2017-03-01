




About
================================================================================


Usage
================================================================================


Imagine we have two simmilar data.frames


```r
library (datasets)
iris0 <- iris1 <- cbind (iris, N = 1:50)
```

with some some cell differences


```r
iris1[4, 1] <- 80
iris1[5, 2] <- 90
iris1[6, 3:4] <- 100 
```

with some different rows


```r
iris0 <- iris0[-(1:3),]
iris1 <- iris1[-150]
```

wth some different columns



```r
iris0[,"mycol0"] <- "A"
iris1[,c ("mycol1", "mycol2")] <- "B"
```

Imagine some of the rows are duplicated 
(or better that they have dulicated id)



```r
iris0 <- rbind (iris0, iris0[10,])
iris1 <- rbind (iris1, iris1[20:21,])
```



```r
head (iris0)
```

```
##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species N mycol0
## 4          4.6         3.1          1.5         0.2  setosa 4      A
## 5          5.0         3.6          1.4         0.2  setosa 5      A
## 6          5.4         3.9          1.7         0.4  setosa 6      A
## 7          4.6         3.4          1.4         0.3  setosa 7      A
## 8          5.0         3.4          1.5         0.2  setosa 8      A
## 9          4.4         2.9          1.4         0.2  setosa 9      A
```

```r
head (iris1)
```

```
##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species N mycol1 mycol2
## 1          5.1         3.5          1.4         0.2  setosa 1      B      B
## 2          4.9         3.0          1.4         0.2  setosa 2      B      B
## 3          4.7         3.2          1.3         0.2  setosa 3      B      B
## 4         80.0         3.1          1.5         0.2  setosa 4      B      B
## 5          5.0        90.0          1.4         0.2  setosa 5      B      B
## 6          5.4         3.9        100.0       100.0  setosa 6      B      B
```


```r
library (tabdif)

dif <- compareDataFrames (iris0, iris1, rowKeys = c ("N", "Species"))
```

```
## NOTE: completely duplicated rows found in old
## NOTE: completely duplicated rows found in new
```

```r
summary (dif)
```

```
##  
## Number of rowKeys used in this table: 2
## rowKey: N
## rowKey: Species
##  
## Number of Deleted Columns: 1
##  
## Number of New Columns: 2
##  
## Number of Changed Column Classes: 0
##  
## Number of Duplicated Rows Old Table: 2
##  
## Number of Duplicated Rows New Table: 4
##  
## Number of Deleted Rows: 2
##  
## Number of New Rows: 4
##  
## Number of Changed Cells: 4
```

```r
dfcomp2xlsx (dif, file = "dif_report.xlsx")

dif
```

```
## 
## Deleted Columns
##   del.cols
## 1   mycol0
## 
## New Columns
##   new.cols
## 1   mycol1
## 2   mycol2
## 
## Duplicated Rows Old Table
##    N Species Petal.Length Petal.Width Sepal.Length Sepal.Width
## 1 13  setosa          1.4         0.1          4.8           3
## 2 13  setosa          1.4         0.1          4.8           3
## 
## Duplicated Rows New Table
##    N Species Petal.Length Petal.Width Sepal.Length Sepal.Width
## 1 20  setosa          1.5         0.3          5.1         3.8
## 2 20  setosa          1.5         0.3          5.1         3.8
## 3 21  setosa          1.7         0.2          5.4         3.4
## 4 21  setosa          1.7         0.2          5.4         3.4
## 
## Deleted Rows
##    N Species Petal.Length Petal.Width Sepal.Length Sepal.Width
## 1 20  setosa          1.5         0.3          5.1         3.8
## 2 21  setosa          1.7         0.2          5.4         3.4
## 
## New Rows
##    N Species Petal.Length Petal.Width Sepal.Length Sepal.Width
## 1 13  setosa          1.4         0.1          4.8         3.0
## 2  1  setosa          1.4         0.2          5.1         3.5
## 3  2  setosa          1.4         0.2          4.9         3.0
## 4  3  setosa          1.3         0.2          4.7         3.2
## 
## Changed Cells
##   N Species       column old new
## 1 4  setosa Sepal.Length 4.6  80
## 2 5  setosa  Sepal.Width 3.6  90
## 3 6  setosa Petal.Length 1.7 100
## 4 6  setosa  Petal.Width 0.4 100
```
