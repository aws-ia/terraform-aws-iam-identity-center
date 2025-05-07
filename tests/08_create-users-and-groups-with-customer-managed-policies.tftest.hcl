run "unit_test" {
  command = plan
  module {
    source = "./examples/create-users-and-groups-with-customer-managed-policies"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/create-users-and-groups-with-customer-managed-policies"
  }
}