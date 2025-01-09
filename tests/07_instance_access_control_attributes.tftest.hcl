run "unit_test" {
  command = plan
  module {
    source = "./examples/instance-access-control-attributes"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/instance-access-control-attributes"
  }
}