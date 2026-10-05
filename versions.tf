terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    # TODO: add the providers the module uses, each as a range over the major it supports, never an
    # exact version (docs/Development.md, "Dependencies and versions"), for example:
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = ">= 4.0.0, < 5.0.0"
    # }
  }
}
