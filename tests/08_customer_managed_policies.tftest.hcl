run "unit_test" {
  command = plan
  module {
    source = "./examples/customer-managed-policies"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/customer-managed-policies"
  }
}
