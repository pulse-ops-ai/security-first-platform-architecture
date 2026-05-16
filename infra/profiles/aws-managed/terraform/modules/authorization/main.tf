# modules/authorization/main.tf
#
# Reference module — Layer 4 (Authorization).
# Provisions an AWS Verified Permissions policy store with a minimal Cedar
# schema. Real policies are deployed by the consuming environment, not here.

resource "aws_verifiedpermissions_policy_store" "this" {
  validation_settings {
    mode = var.validation_mode
  }

  description = "Policy store for ${var.name} — security-first platform L4."
}

resource "aws_verifiedpermissions_schema" "this" {
  policy_store_id = aws_verifiedpermissions_policy_store.this.id

  definition {
    # Minimal starter Cedar schema. Expand per product.
    value = jsonencode({
      "Platform" : {
        "entityTypes" : {
          "User"    : { "shape" : { "type" : "Record", "attributes" : {} } },
          "Service" : { "shape" : { "type" : "Record", "attributes" : {} } },
          "Agent"   : {
            "shape" : {
              "type" : "Record",
              "attributes" : {
                "actor"    : { "type" : "Entity", "name" : "User",    "required" : false },
                "tenant"   : { "type" : "Entity", "name" : "Tenant",  "required" : true }
              }
            }
          },
          "Tenant"  : { "shape" : { "type" : "Record", "attributes" : {} } },
          "Resource" : {
            "memberOfTypes" : ["Tenant"],
            "shape" : {
              "type" : "Record",
              "attributes" : {
                "owner" : { "type" : "Entity", "name" : "User", "required" : false }
              }
            }
          }
        },
        "actions" : {
          "view"   : { "appliesTo" : { "principalTypes" : ["User", "Agent"], "resourceTypes" : ["Resource"] } },
          "edit"   : { "appliesTo" : { "principalTypes" : ["User", "Agent"], "resourceTypes" : ["Resource"] } },
          "delete" : { "appliesTo" : { "principalTypes" : ["User"],          "resourceTypes" : ["Resource"] } }
        }
      }
    })
  }
}
