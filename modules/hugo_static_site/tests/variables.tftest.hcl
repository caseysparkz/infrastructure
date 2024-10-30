###############################################################################
# Variables.
#

variables {
  turnstile_site_key   = "0x0000000000000000000000"
  turnstile_secret_key = "0x111111111111111111111111111111111"
  artifact_bucket_id   = ""
  root_domain          = "test.com"
  subdomain            = "www.test.com"
  site_title           = "Test Title"
  hugo_dir             = "./hugo"
}

variable "artifact_bucket_id" {
  type        = string
  description = "ID of the S3 bucket in which lambda functions are kept."
  sensitive   = false
}
