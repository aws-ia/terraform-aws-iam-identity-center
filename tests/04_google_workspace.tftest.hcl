run "unit_test" {
  command = plan
  module {
    source = "./examples/google-workspace"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/google-workspace"
  }
}
