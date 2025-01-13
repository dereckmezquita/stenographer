# messageParallel handles basic string

    Code
      messageParallel("Hello World")

# messageParallel concatenates multiple arguments

    Code
      messageParallel("Hello", " ", "World")

# messageParallel handles empty strings

    Code
      messageParallel("")

# messageParallel handles special characters

    Code
      messageParallel("Hello\nWorld")
      messageParallel("Hello\tWorld")
      messageParallel("Hello \"World\"")

# messageParallel handles multiple lines

    Code
      messageParallel("Line 1\nLine 2\nLine 3")

# messageParallel handles numbers

    Code
      messageParallel(123)
      messageParallel(1.234)

# messageParallel handles mixing types

    Code
      messageParallel("Number: ", 123, " String: ", "test")

