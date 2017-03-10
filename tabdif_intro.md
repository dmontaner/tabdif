


About
--------------------------------------------------------------------------------

The `tabdif` library is devised to find differences between two tables (data.fames).
This is usefull for instance when you want to find changes between two versions of the same dataset.

The function `compareDataFrames` creates a list of class `dfcomp` containing the following information about the differences:

- __Deleted Columns__:           Column names in the first (_old_) data.frame not found in the second (_new_) data.frame.
- __New Columns__:               Column names in the second        data.frame not found in the first          data.frame.
- __Changed Column Classes__:    Columns with different class in the first and second data.frames.
- __Duplicated Rows Old Table__: Rows with duplicated IDs in the first  data.frame. This rows are not compared.
- __Duplicated Rows New Table__: Rows with duplicated IDs in the second data.frame. This rows are not compared.
- __Deleted Rows__:              Rows in the first  data.frame which ID is not found in the second data.frame.
- __New Rows__:                  Rows in the second data.frame which ID is not found in the first  data.frame.
- __Changed Cells__:             Cells which have changed from one dataset to the other.

One or several columns which have to be common in both datasets are used as _row keys_;
together with the other columns names they should uniquely identify cells for the comparison to be done. 

Example Data
--------------------------------------------------------------------------------

Imagine we have two similar data.frames `iris0` and `iris1`


```r
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

Usage
--------------------------------------------------------------------------------

The function `compareDataFrames` finds the differences between the two tables.
In our example _row keys_ are defined by 2 columns: "N" and "Species".


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

The elements of the `dfcomp` list created by `compareDataFrames` 
resume the differences between our two tables.
For instance `dif$dif.cells` indicates the cells which have changed.


```r
dif$dif.cells
```

```
##   N Species       column old new
## 1 4  setosa Sepal.Length 4.6  80
## 2 5  setosa  Sepal.Width 3.6  90
## 3 6  setosa Petal.Length 1.7 100
## 4 6  setosa  Petal.Width 0.4 100
```


Export
--------------------------------------------------------------------------------

The `dfcomp` list can easily be exported to an _xlsx_ file. 
Each element of the list will be in a separated sheet of the _xlsx_ file,
including a summary of the differences in the first page. 


```r
dfcomp2xlsx (dif, file = "dif_report.xlsx")
```


