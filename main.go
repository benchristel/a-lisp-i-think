package main

import (
  "io"
  "os"
)

func main() {
  Repl(os.Stdin, os.Stdout)
}

func Repl(input io.Reader, output io.Writer) {
  output.Write([]byte("Welcome to a Lisp, I Think!\n"))
  output.Write([]byte("> "))
}
