variable "roles" {
  type = map(object({
    policies = list(string) # List of policy ARNs
  }))
}
