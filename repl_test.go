package main_test

import (
  "strings"
  . "github.com/onsi/ginkgo"
  . "github.com/onsi/gomega"
  "github.com/benchristel/a-lisp-i-think"
)

var _ = Describe("the REPL", func() {
  It("prints a welcome message and a prompt", func() {
    input := strings.NewReader("")
    output := &strings.Builder{}

    main.Repl(input, output)

    Expect(output.String()).To(Equal("Welcome to a Lisp, I Think!\n> "))
  })
})
