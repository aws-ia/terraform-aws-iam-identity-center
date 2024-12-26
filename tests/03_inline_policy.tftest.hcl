run "unit_test" {
  command = plan
  module {
    source = "./examples/inline-policy"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/inline-policy"
  }
}
