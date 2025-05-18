# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "West US"
}

# Define a custom policy to enforce that resources have at least one tag
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-tags-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require At Least One Tag"

  policy_rule = <<POLICY_RULE
{
  "if": {
    "field": "tags",
    "exists": "false"
  },
  "then": {
    "effect": "deny"
  }
}
POLICY_RULE
}

# Assign the policy to the Resource Group
resource "azurerm_resource_group_policy_assignment" "require_tags_assignment" {
  name                 = "require-tags-assignment"
  resource_group_id    = azurerm_resource_group.example.id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  description          = "Ensure all resources in the Resource Group have at least one tag"
  display_name         = "Require Tags Assignment"
}