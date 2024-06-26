run "unit_test" {
  command = plan
  module {
    source = "./examples/existing-users-and-groups"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/existing-users-and-groups"
  }
}
