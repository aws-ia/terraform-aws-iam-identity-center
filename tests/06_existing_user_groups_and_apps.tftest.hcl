run "unit_test" {
  command = plan
  module {
    source = "./examples/existing-users-groups-create-apps"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/existing-users-groups-create-apps"
  }
}
