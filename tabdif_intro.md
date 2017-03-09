




About
--------------------------------------------------------------------------------


Example Data
--------------------------------------------------------------------------------

Imagine we have two similar data.frames `iris0` and `iris1`


```r
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

with some different columns


```r
iris0[,"mycol0"] <- "A"
iris1[,c ("mycol1", "mycol2")] <- "B"
```

Imagine some of the rows are duplicated 
(or better that they have duplicated id)



```r
iris0 <- rbind (iris0, iris0[10,])
iris1 <- rbind (iris1, iris1[20:21,])
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


Usage
--------------------------------------------------------------------------------

Then we can use the function `compareDataFrames` 
in the `tabdif` package to spot differences between the two tables.

`compareDataFrames` creates a list of class `dfcomp` with the following information:

- Deleted Columns: Column names in the first (_old_) data.frame not found in the second one (_new_).
- New Columns:     Column names in the second        data.frame not found in the first  one.
- Changed Column Classes: Columns with different class in the first and second data.frames.
- Duplicated Rows Old Table: Rows with duplicated ids in the first  data.frame. This rows are not compared.
- Duplicated Rows New Table: Rows with duplicated ids in the second data.frame. This rows are not compared.
- Deleted Rows: Rows in the first  data.frame which ID is not found in the second data.frame.
- New Rows:     Rows in the second data.frame which ID is not found in the first  data.frame.
- Changed Cells: Cells which have changed from one dataset to the other.



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


The `dfcomp` object can easily be exported to an _xlsx_ file. 
Each element of the list above mentioned will be in a tab of the _xlsx_ file. 


```r
dfcomp2xlsx (dif, file = "dif_report.xlsx")
```


