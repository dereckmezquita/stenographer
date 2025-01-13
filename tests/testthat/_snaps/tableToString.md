# tableToString handles basic data frames

    Code
      tableToString(df)
    Output
      [1] "  a b\n1 1 a\n2 2 b\n3 3 c"

# tableToString handles single-row data frames

    Code
      tableToString(df)
    Output
      [1] "  a b\n1 1 x"

# tableToString handles empty data frames

    Code
      tableToString(df)
    Output
      [1] "data frame with 0 columns and 0 rows"

# tableToString handles data frames with NA values

    Code
      tableToString(df)
    Output
      [1] "   a    b\n1  1    x\n2 NA    y\n3  3 <NA>"

# tableToString converts matrices to data frames

    Code
      tableToString(mat)
    Output
      [1] "  V1 V2\n1  1  3\n2  2  4"

# tableToString handles lists

    Code
      tableToString(lst)
    Output
      [1] "  a b\n1 1 a\n2 2 b\n3 3 c"

# tableToString handles vectors

    Code
      tableToString(vec)
    Output
      [1] "  obj\n1   1\n2   2\n3   3"

# tableToString handles factors

    Code
      tableToString(fct)
    Output
      [1] "  obj\n1   a\n2   b\n3   a"

# tableToString handles data frames with different column types

    Code
      tableToString(df)
    Output
      [1] "  num char  bool fct\n1 1.0    a  TRUE   x\n2 2.5    b FALSE   y\n3 3.0    c  TRUE   x"

