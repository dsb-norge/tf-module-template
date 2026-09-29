# Unit tests: plan the module without credentials. CI runs files named unit-*.tftest.hcl in the
# 'unit' lane, which has no credentials (.github/workflows/test.yaml).
#
# Once the module requires a provider, mock it so the plan still needs no credentials:
# mock_provider "azurerm" {}

run "the_module_plans" {
  command = plan
}
