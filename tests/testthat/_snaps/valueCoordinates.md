# valueCoordinates finds NA values correctly

    Code
      valueCoordinates(df)
    Output
        column row
      2      1   1
      1      2   2
      3      2   3

# valueCoordinates finds specific values

    Code
      valueCoordinates(df, 2)
    Output
        column row
      1      2   2
      2      3   2

# valueCoordinates works with custom comparison function

    Code
      valueCoordinates(df, 2, function(x, y) !is.na(x) && x > y)
    Output
        column row
      2      1   1
      1      3   3

# valueCoordinates handles single-column dataframes

    Code
      valueCoordinates(df)
    Output
        column row
      1      1   2

