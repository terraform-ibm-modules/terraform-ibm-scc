terraform {
  required_version = ">= 1.3.0"
  # If your module requires any terraform providers, uncomment the "required_providers" section below and add all required providers.
  # Each required provider's version should be a flexible range to future proof the module's usage with upcoming minor and patch versions.

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.77.1, <2.0.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.1, <1.0.0"
    }
  }
}
