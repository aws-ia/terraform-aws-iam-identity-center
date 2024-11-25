run "unit_test" {
  command = plan
  module {
    source = "./examples/create-apps-and-assignments"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/create-apps-and-assignments"
  }
}
