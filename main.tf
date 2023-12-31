data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-openctisentconn-we-234f"
  location = "West Europe"
}

locals {
  getindicatorsstream_playbook_name = "OpenCTI-GetIndicatorsStream"
  importtosentinel_playbook_name    = "OpenCTI-ImportToSentinel"
  connector_name                    = "OpenCTICustomConnector"
  host_name                         = var.host_name
  service_name                      = "https://${local.host_name}"
}

resource "azapi_resource" "opencti_connector" {
  count                     = var.deploy_opencti_connector ? 1 : 0
  type                      = "Microsoft.Web/customApis@2016-06-01"
  name                      = local.connector_name
  location                  = azurerm_resource_group.rg.location
  parent_id                 = azurerm_resource_group.rg.id
  schema_validation_enabled = false
  body                      = <<EOF
{
"properties": {
          "connectionParameters": {
            "api_key": {
              "type": "securestring",
               "uiDefinition": {
                              "displayName": "API Key",
                              "description": "The API Key for OpenCTI api",
                              "tooltip": "Provide your API Key starts with Bearer <<Key Value>>",
                              "constraints": {
                                  "tabIndex": 2,
                                  "clearText": false,
                                  "required": "true"
                              }
                          }
            }
          },
          "brandColor": "#FFFFFF",
          "description": "This connector helps to authenticate with ${local.connector_name} and running GraphQL queries",
          "displayName": "${local.connector_name} ",
          "iconUri": "data:image/jpeg;base64,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",
          "backendService": {
                      "serviceUrl": "${local.service_name}"
                  },
          "apiType": "Rest",
          "swagger": {
            "swagger": "2.0",
            "info": {
              "version": "1.0.0",
              "title": "OpenCTICustomConnector",
              "description": "This connector helps to authenticate with OpenCTI and running GraphQL queries"
            },
            "host": "${local.host_name}",
            "basePath": "/",
            "schemes": [
              "https"
            ],
            "consumes": [],
            "produces": [
              "application/json"
            ],
            "paths": {
              "/graphql": {
                "post": {
                  "summary": "Run GraphQL Query",
                  "description": "This helps to run GraphQL queries on OpenCTI and returns response in JSON format. You can run any kind of query that supported by OpenCTI",
                  "operationId": "RunGraphQLQuery",
                  "parameters": [
                    {
                      "name": "Content-Type",
                      "in": "header",
                      "required": true,
                      "type": "string",
                      "default": "application/json",
                      "description": "Content-Type",
                      "x-ms-visibility": "advanced"
                    },
                    {
                      "name": "GraphQL Query",
                      "in": "body",
                      "schema": {
                        "type": "object",
                        "properties": {
                          "query": {
                            "type": "string",
                            "description": "Type your query here",
                            "title": "GraphQL Query",
                            "x-ms-visibility": "important",
                            "default": "query{\n}"
                          }
                        },
                        "default": {
                          "query": "",
                          "variables": {}
                        },
                        "required": [
                          "query"
                        ],
                        "x-ms-visibility": "advanced"
                      },
                      "required": true,
                      "x-ms-visibility": "advanced"
                    }
                  ],
                  "responses": {
                    "default": {
                      "description": "default",
                      "schema": {}
                    }
                  }
                }
              }
            },
            "definitions": {},
            "parameters": {},
            "responses": {},
            "securityDefinitions": {
              "API Key": {
                "type": "apiKey",
                "in": "header",
                "name": "Authorization"
              }
            },
            "security": [
              {
                "API Key": []
              }
            ],
            "tags": []
          }
        }
        }
  EOF
}

resource "azapi_resource" "opencti_connector_connection" {
  count     = var.deploy_opencti_connector ? 1 : 0
  type      = "Microsoft.Web/connections@2016-06-01"
  name      = "${local.connector_name}-${local.getindicatorsstream_playbook_name}"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
  body      = <<BODY
{
"properties": {
                "displayName": "${local.connector_name}-${local.getindicatorsstream_playbook_name}",
                "customParameterValues": {
                },
                "api": {
                    "id": "${azapi_resource.opencti_connector.0.id}"
                }
            }
            }
BODY

  depends_on = [azapi_resource.opencti_connector]
}

resource "azapi_resource" "opencti_connector_graph_connection" {
  count                     = var.deploy_opencti_connector ? 1 : 0
  type                      = "Microsoft.Web/connections@2016-06-01"
  name                      = "MicrosoftGraphSecurity-${local.importtosentinel_playbook_name}"
  location                  = azurerm_resource_group.rg.location
  parent_id                 = azurerm_resource_group.rg.id
  schema_validation_enabled = false
  body                      = <<BODY
{
"properties":  {
                "displayName":  "MicrosoftGraphSecurity-${local.importtosentinel_playbook_name}",
                "customParameterValues":  {
                },
                "parameterValueType":  "Alternative",
                "api":  {
                    "id":  "/subscriptions/${var.azurerm_provider_subscription_id}/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/microsoftgraphsecurity"
                }
            }
            }
BODY

}

resource "azurerm_logic_app_workflow" "opencti_importtosentinel" {
  count               = var.deploy_opencti_connector ? 1 : 0
  name                = local.importtosentinel_playbook_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  workflow_schema  = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0"
  workflow_parameters = {
    "$connections" = <<BODY
{
  "defaultValue": {},
  "type": "Object"
}
BODY
  }

  parameters = {
    "$connections" = <<BODY
{
  "microsoftgraphsecurity": {
    "connectionId": "${azapi_resource.opencti_connector_graph_connection.0.id}",
    "connectionName": "MicrosoftGraphSecurity-${local.importtosentinel_playbook_name}",
    "id": "/subscriptions/${var.azurerm_provider_subscription_id}/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/microsoftgraphsecurity",
    "connectionProperties": {
      "authentication": {
        "type": "ManagedServiceIdentity"
      }
    }
  }
}
BODY
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azapi_resource.opencti_connector_graph_connection]
  lifecycle {
    ignore_changes = [
      parameters,
      workflow_parameters,
    ]
  }
}

resource "azurerm_logic_app_trigger_custom" "opencti_importtosentinel" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Batch_messages"
  logic_app_id = azurerm_logic_app_workflow.opencti_importtosentinel.0.id

  body = <<BODY
{
                            "type":  "Batch",
                            "inputs":  {
                                "configurations":  {
                                    "OpenCTIToSentinel":  {
                                        "releaseCriteria":  {
                                            "messageCount":  100,
                                            "recurrence":  {
                                                "frequency":  "Minute",
                                                "interval":  10
                                            }
                                        }
                                    }
                                },
                                "mode":  "Inline"
                            }
                        }
BODY
}

resource "azurerm_logic_app_action_custom" "opencti_Select" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Select"
  logic_app_id = azurerm_logic_app_workflow.opencti_importtosentinel.0.id

  body = <<BODY
{
                            "runAfter":  {
                            },
                            "type":  "Select",
                            "inputs":  {
                                "from":  "@triggerBody()['items']",
                                "select":  "@item()['content']"
                            }
                        }
BODY

  depends_on = [azurerm_logic_app_trigger_custom.opencti_importtosentinel]
}

resource "azurerm_logic_app_action_custom" "opencti_Submit_multiple_tiIndicators" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Submit_multiple_tiIndicators"
  logic_app_id = azurerm_logic_app_workflow.opencti_importtosentinel.0.id

  body = <<BODY
{
                            "runAfter":  {
                                "Select":  [
                                    "Succeeded"
                                ]
                            },
                            "type":  "ApiConnection",
                            "inputs":  {
                                "body":  {
                                    "value":  "@body('Select')"
                                },
                                "host":  {
                                    "connection":  {
                                        "name":  "@parameters('$connections')['microsoftgraphsecurity']['connectionId']"
                                    }
                                },
                                "method":  "post",
                                "path":  "/beta/security/tiIndicators/submitTiIndicators"
                            }
                        }
BODY

  depends_on = [azurerm_logic_app_action_custom.opencti_Select]
}

resource "azurerm_logic_app_workflow" "opencti_getindicators" {
  count               = var.deploy_opencti_connector ? 1 : 0
  name                = local.getindicatorsstream_playbook_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  workflow_schema  = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0"
  workflow_parameters = {
    "$connections" = <<BODY
{
  "defaultValue": {},
  "type": "Object"
}
BODY
  }

  parameters = {
    "$connections" = <<BODY
{
  "OpenCTICustomConnector": {
    "connectionId": "${azapi_resource.opencti_connector_connection.0.id}",
    "connectionName": "${local.connector_name}-${local.getindicatorsstream_playbook_name}",
    "id": "/subscriptions/${var.azurerm_provider_subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/customApis/${local.connector_name}"
  }
}
BODY
  }

  depends_on = [azapi_resource.opencti_connector, azapi_resource.opencti_connector_connection]
  lifecycle {
    ignore_changes = [
      parameters,
      workflow_parameters,
    ]
  }
}

resource "azurerm_logic_app_trigger_custom" "opencti_getindicators" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Sliding_Window"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
{
                "inputs": {
                    "delay": "PT10M"
                },
                "recurrence": {
                    "frequency": "Minute",
                    "interval": 10
                },
                "type": "SlidingWindow"
}
BODY
}

resource "azurerm_logic_app_action_custom" "openCTI_Parse_JSON" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Parse_JSON"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
 {
        "runAfter": {},
        "type": "ParseJson",
        "inputs": {
            "content": "@trigger()",
            "schema": {
                "properties": {
                    "clientTrackingId": {
                        "type": "string"
                    },
                    "code": {
                        "type": "string"
                    },
                    "endTime": {
                        "type": "string"
                    },
                    "inputs": {
                        "properties": {
                            "delay": {
                                "type": "string"
                            }
                        },
                        "type": "object"
                    },
                    "name": {
                        "type": "string"
                    },
                    "originHistoryName": {
                        "type": "string"
                    },
                    "outputs": {
                        "properties": {
                            "windowEndTime": {
                                "type": "string"
                            },
                            "windowStartTime": {
                                "type": "string"
                            }
                        },
                        "type": "object"
                    },
                    "scheduledTime": {
                        "type": "string"
                    },
                    "startTime": {
                        "type": "string"
                    },
                    "status": {
                        "type": "string"
                    },
                    "trackingId": {
                        "type": "string"
                    }
                },
                "type": "object"
            }
        }
    }
BODY

  depends_on = [azurerm_logic_app_workflow.opencti_getindicators]
}

resource "azurerm_logic_app_action_custom" "opencti_Run_Sample_GraphQL_Query_to_check_Auth_" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Run_Sample_GraphQL_Query_to_check_Auth_"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
{
        "runAfter": {
            "Parse_JSON": [
                "Succeeded"
            ]
        },
        "type": "ApiConnection",
        "inputs": {
            "body": {
                "query": "query{\n  about{\n    memory{\n      rss\n      heapTotal\n      heapUsed\n    }\n  }\n}"
            },
            "headers": {
                "Content-Type": "application/json"
            },
            "host": {
                "connection": {
                    "name": "@parameters('$connections')['OpenCTICustomConnector']['connectionId']"
                }
            },
            "method": "post",
            "path": "/graphql"
        }
    }
BODY

  depends_on = [azurerm_logic_app_action_custom.openCTI_Parse_JSON]
}

resource "azurerm_logic_app_action_custom" "opencti_Parse_OpenCTI_response" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Parse_OpenCTI_response"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
{
        "runAfter": {
            "Run_Sample_GraphQL_Query_to_check_Auth_": [
                "Succeeded"
            ]
        },
        "type": "ParseJson",
        "inputs": {
            "content": "@body('Run_Sample_GraphQL_Query_to_check_Auth_')",
            "schema": {
                "properties": {
                    "data": {
                        "properties": {
                            "about": {
                                "properties": {
                                    "memory": {
                                        "properties": {
                                            "heapTotal": {
                                                "type": "integer"
                                            },
                                            "heapUsed": {
                                                "type": "integer"
                                            },
                                            "rss": {
                                                "type": "integer"
                                            }
                                        },
                                        "type": "object"
                                    }
                                },
                                "type": "object"
                            }
                        },
                        "type": "object"
                    }
                },
                "type": "object"
            }
        }
    }
BODY

  depends_on = [azurerm_logic_app_action_custom.opencti_Run_Sample_GraphQL_Query_to_check_Auth_]
}

resource "azurerm_logic_app_action_custom" "opencti_Terminate_in_case_of_JSON_Parse_Failed" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Terminate_in_case_of_JSON_Parse_Failed"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
{
        "runAfter": {
            "Parse_OpenCTI_response": [
                "Failed",
                "TimedOut",
                "Skipped"
            ]
        },
        "type": "Terminate",
        "inputs": {
            "runError": {
                "code": "FAIL",
                "message": "@{body('Run_Sample_GraphQL_Query_to_check_Auth_')}"
            },
            "runStatus": "Failed"
        }
    }
BODY

  depends_on = [azurerm_logic_app_action_custom.opencti_Parse_OpenCTI_response]
}

resource "azurerm_logic_app_action_custom" "opencti_Initialize_variable_StartTime" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Initialize_variable_StartTime"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
{
        "runAfter": {
            "Parse_OpenCTI_response": [
                "Succeeded"
            ]
        },
        "type": "InitializeVariable",
        "inputs": {
            "variables": [
                {
                    "name": "StartTime",
                    "type": "string",
                    "value": "@body('Parse_JSON')?['outputs']?['windowStartTime']"
                }
            ]
        }
    }
BODY

  depends_on = [azurerm_logic_app_action_custom.opencti_Parse_OpenCTI_response]
}

resource "azurerm_logic_app_action_custom" "opencti_Initialize_variable_Cursor" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Initialize_variable_Cursor"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
{
        "runAfter": {
            "Initialize_variable_StartTime": [
                "Succeeded"
            ]
        },
        "type": "InitializeVariable",
        "inputs": {
            "variables": [
                {
                    "name": "Cursor",
                    "type": "string"
                }
            ]
        }
    }
BODY

  depends_on = [azurerm_logic_app_action_custom.opencti_Initialize_variable_StartTime]
}

resource "azurerm_logic_app_action_custom" "opencti_Initialize_variable_azureTenantId" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Initialize_variable_azureTenantId"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
{
        "runAfter": {
            "Initialize_variable_Cursor": [
                "Succeeded"
            ]
        },
        "type": "InitializeVariable",
        "inputs": {
            "variables": [
                {
                    "name": "azureTenantId",
                    "type": "string",
                    "value": "${data.azurerm_client_config.current.tenant_id}"
                }
            ]
        }
    }
BODY

  depends_on = [azurerm_logic_app_action_custom.opencti_Initialize_variable_Cursor]
}

resource "azurerm_logic_app_action_custom" "opencti_Until_hasNextPage_is_false" {
  count        = var.deploy_opencti_connector ? 1 : 0
  name         = "Until_hasNextPage_is_false"
  logic_app_id = azurerm_logic_app_workflow.opencti_getindicators.0.id

  body = <<BODY
{
        "actions": {
            "For_each_Indicator": {
                "foreach": "@body('Parse_JSON_Indicators')?['data']?['indicators']?['edges']",
                "actions": {
                    "Parse_JSON_Indicator_Info": {
                        "runAfter": {},
                        "type": "ParseJson",
                        "inputs": {
                            "content": "@items('For_each_Indicator')",
                            "schema": {
                                "properties": {
                                    "node": {
                                        "properties": {
                                            "created": {
                                                "type": "string"
                                            },
                                            "createdBy": {
                                                "properties": {
                                                    "confidence": {
                                                        "type": [
                                                            "integer",
                                                            "null"
                                                        ]
                                                    },
                                                    "id": {
                                                        "type": [
                                                            "string",
                                                            "null"
                                                        ]
                                                    },
                                                    "name": {
                                                        "type": [
                                                            "string",
                                                            "null"
                                                        ]
                                                    }
                                                },
                                                "type": "object"
                                            },
                                            "created_at": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "creators": {
                                                "items": {
                                                    "properties": {
                                                        "id": {
                                                            "type": "string"
                                                        },
                                                        "name": {
                                                            "type": "string"
                                                        }
                                                    },
                                                    "type": "object"
                                                },
                                                "type": "array"
                                            },
                                            "description": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "entity_type": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "id": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "name": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "pattern": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "pattern_type": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "status": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "valid_from": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "valid_until": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "x_opencti_main_observable_type": {
                                                "type": [
                                                    "string",
                                                    "null"
                                                ]
                                            },
                                            "x_opencti_score": {
                                                "type": [
                                                    "integer",
                                                    "null"
                                                ]
                                            }
                                        },
                                        "type": "object"
                                    }
                                },
                                "type": "object"
                            }
                        }
                    },
                    "Switch_2": {
                        "runAfter": {
                            "Parse_JSON_Indicator_Info": [
                                "Succeeded"
                            ]
                        },
                        "cases": {
                            "Case_Domain-Name": {
                                "case": "Domain-Name",
                                "actions": {
                                    "Compose_Domain-Name": {
                                        "runAfter": {},
                                        "type": "Compose",
                                        "inputs": {
                                            "action": "alert",
                                            "additionalInformation": "@{body('Parse_JSON_Indicator_Info')?['node']}",
                                            "azureTenantId": "@{variables('azureTenantId')}",
                                            "confidence": "@body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_score']",
                                            "description": "OpenCTI Indicator for @{body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_main_observable_type']}",
                                            "domainName": "@{body('Parse_JSON_Indicator_Info')?['node']?['name']}",
                                            "expirationDateTime": "@{body('Parse_JSON_Indicator_Info')?['node']?['valid_until']}",
                                            "ingestedDateTime": "@{utcNow()}",
                                            "targetProduct": "Azure Sentinel",
                                            "threatType": "WatchList",
                                            "tlpLevel": "amber"
                                        }
                                    },
                                    "OpenCTI-ImportToSentinel": {
                                        "runAfter": {
                                            "Compose_Domain-Name": [
                                                "Succeeded"
                                            ]
                                        },
                                        "type": "SendToBatch",
                                        "inputs": {
                                            "batchName": "${local.importtosentinel_playbook_name}",
                                            "content": "@outputs('Compose_Domain-Name')",
                                            "host": {
                                                "triggerName": "Batch_messages",
                                                "workflow": {
                                                    "id": "${azurerm_logic_app_workflow.opencti_importtosentinel.0.id}"
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            "Case_Email-Addr": {
                                "case": "Email-Addr",
                                "actions": {
                                    "Compose_Email-Addr": {
                                        "runAfter": {},
                                        "type": "Compose",
                                        "inputs": {
                                            "action": "alert",
                                            "additionalInformation": "@{body('Parse_JSON_Indicator_Info')?['node']}",
                                            "azureTenantId": "@{variables('azureTenantId')}",
                                            "confidence": "@body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_score']",
                                            "description": "OpenCTI Indicator for @{body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_main_observable_type']}",
                                            "emailSenderAddress": "@{body('Parse_JSON_Indicator_Info')?['node']?['name']}",
                                            "expirationDateTime": "@{body('Parse_JSON_Indicator_Info')?['node']?['valid_until']}",
                                            "ingestedDateTime": "@{utcNow()}",
                                            "targetProduct": "Azure Sentinel",
                                            "threatType": "WatchList",
                                            "tlpLevel": "amber"
                                        }
                                    },
                                    "OpenCTI-ImportToSentinel_2": {
                                        "runAfter": {
                                            "Compose_Email-Addr": [
                                                "Succeeded"
                                            ]
                                        },
                                        "type": "SendToBatch",
                                        "inputs": {
                                            "batchName": "${local.importtosentinel_playbook_name}",
                                            "content": "@outputs('Compose_Email-Addr')",
                                            "host": {
                                                "triggerName": "Batch_messages",
                                                "workflow": {
                                                    "id": "${azurerm_logic_app_workflow.opencti_importtosentinel.0.id}"
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            "Case_IPv4-Addr": {
                                "case": "IPv4-Addr",
                                "actions": {
                                    "Compose_IPv4-Addr": {
                                        "runAfter": {},
                                        "type": "Compose",
                                        "inputs": {
                                            "action": "alert",
                                            "additionalInformation": "@{body('Parse_JSON_Indicator_Info')?['node']}",
                                            "azureTenantId": "@{variables('azureTenantId')}",
                                            "confidence": "@body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_score']",
                                            "description": "OpenCTI Indicator for @{body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_main_observable_type']}",
                                            "expirationDateTime": "@{body('Parse_JSON_Indicator_Info')?['node']?['valid_until']}",
                                            "ingestedDateTime": "@{utcNow()}",
                                            "networkIPv4": "@{body('Parse_JSON_Indicator_Info')?['node']?['name']}",
                                            "targetProduct": "Azure Sentinel",
                                            "threatType": "WatchList",
                                            "tlpLevel": "amber"
                                        }
                                    },
                                    "OpenCTI-ImportToSentinel_4": {
                                        "runAfter": {
                                            "Compose_IPv4-Addr": [
                                                "Succeeded"
                                            ]
                                        },
                                        "type": "SendToBatch",
                                        "inputs": {
                                            "batchName": "${local.importtosentinel_playbook_name}",
                                            "content": "@outputs('Compose_IPv4-Addr')",
                                            "host": {
                                                "triggerName": "Batch_messages",
                                                "workflow": {
                                                    "id": "${azurerm_logic_app_workflow.opencti_importtosentinel.0.id}"
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            "Case_IPv6-Addr": {
                                "case": "IPv6-Addr",
                                "actions": {
                                    "Compose_IPv6-Addr": {
                                        "runAfter": {},
                                        "type": "Compose",
                                        "inputs": {
                                            "action": "alert",
                                            "additionalInformation": "@{body('Parse_JSON_Indicator_Info')?['node']}",
                                            "azureTenantId": "@{variables('azureTenantId')}",
                                            "confidence": "@body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_score']",
                                            "description": "OpenCTI Indicator for @{body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_main_observable_type']}",
                                            "expirationDateTime": "@{body('Parse_JSON_Indicator_Info')?['node']?['valid_until']}",
                                            "ingestedDateTime": "@{utcNow()}",
                                            "networkIPv6": "@{body('Parse_JSON_Indicator_Info')?['node']?['name']}",
                                            "targetProduct": "Azure Sentinel",
                                            "threatType": "WatchList",
                                            "tlpLevel": "amber"
                                        }
                                    },
                                    "OpenCTI-ImportToSentinel_5": {
                                        "runAfter": {
                                            "Compose_IPv6-Addr": [
                                                "Succeeded"
                                            ]
                                        },
                                        "type": "SendToBatch",
                                        "inputs": {
                                            "batchName": "${local.importtosentinel_playbook_name}",
                                            "content": "@outputs('Compose_IPv6-Addr')",
                                            "host": {
                                                "triggerName": "Batch_messages",
                                                "workflow": {
                                                    "id": "${azurerm_logic_app_workflow.opencti_importtosentinel.0.id}"
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            "Case_StixFile": {
                                "case": "StixFile",
                                "actions": {
                                    "Compose_StixFile": {
                                        "runAfter": {},
                                        "type": "Compose",
                                        "inputs": {
                                            "action": "alert",
                                            "additionalInformation": "@{body('Parse_JSON_Indicator_Info')?['node']}",
                                            "azureTenantId": "@{variables('azureTenantId')}",
                                            "confidence": "@body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_score']",
                                            "description": "OpenCTI Indicator for @{body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_main_observable_type']}",
                                            "expirationDateTime": "@{body('Parse_JSON_Indicator_Info')?['node']?['valid_until']}",
                                            "fileHashType": "unknown",
                                            "fileHashValue": "@{body('Parse_JSON_Indicator_Info')?['node']?['name']}",
                                            "ingestedDateTime": "@{utcNow()}",
                                            "targetProduct": "Azure Sentinel",
                                            "threatType": "WatchList",
                                            "tlpLevel": "amber"
                                        }
                                    },
                                    "OpenCTI-ImportToSentinel_3": {
                                        "runAfter": {
                                            "Compose_StixFile": [
                                                "Succeeded"
                                            ]
                                        },
                                        "type": "SendToBatch",
                                        "inputs": {
                                            "batchName": "${local.importtosentinel_playbook_name}",
                                            "content": "@outputs('Compose_StixFile')",
                                            "host": {
                                                "triggerName": "Batch_messages",
                                                "workflow": {
                                                    "id": "${azurerm_logic_app_workflow.opencti_importtosentinel.0.id}"
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            "Case_Url": {
                                "case": "Url",
                                "actions": {
                                    "Compose_Url": {
                                        "runAfter": {},
                                        "type": "Compose",
                                        "inputs": {
                                            "action": "alert",
                                            "additionalInformation": "@{body('Parse_JSON_Indicator_Info')?['node']}",
                                            "azureTenantId": "@{variables('azureTenantId')}",
                                            "confidence": "@body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_score']",
                                            "description": "OpenCTI Indicator for @{body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_main_observable_type']}",
                                            "expirationDateTime": "@{body('Parse_JSON_Indicator_Info')?['node']?['valid_until']}",
                                            "ingestedDateTime": "@{utcNow()}",
                                            "targetProduct": "Azure Sentinel",
                                            "threatType": "WatchList",
                                            "tlpLevel": "amber",
                                            "url": "@{body('Parse_JSON_Indicator_Info')?['node']?['name']}"
                                        }
                                    },
                                    "OpenCTI-ImportToSentinel_6": {
                                        "runAfter": {
                                            "Compose_Url": [
                                                "Succeeded"
                                            ]
                                        },
                                        "type": "SendToBatch",
                                        "inputs": {
                                            "batchName": "${local.importtosentinel_playbook_name}",
                                            "content": "@outputs('Compose_Url')",
                                            "host": {
                                                "triggerName": "Batch_messages",
                                                "workflow": {
                                                    "id": "${azurerm_logic_app_workflow.opencti_importtosentinel.0.id}"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        "default": {
                            "actions": {}
                        },
                        "expression": "@body('Parse_JSON_Indicator_Info')?['node']?['x_opencti_main_observable_type']",
                        "type": "Switch"
                    }
                },
                "runAfter": {
                    "Set_variable_Cursor": [
                        "Succeeded"
                    ]
                },
                "type": "Foreach"
            },
            "Parse_JSON_Indicators": {
                "runAfter": {
                    "Run_GraphQL_Query_Get_Indicators": [
                        "Succeeded"
                    ]
                },
                "type": "ParseJson",
                "inputs": {
                    "content": "@body('Run_GraphQL_Query_Get_Indicators')",
                    "schema": {
                        "properties": {
                            "data": {
                                "properties": {
                                    "indicators": {
                                        "properties": {
                                            "edges": {
                                                "items": {
                                                    "properties": {
                                                        "node": {
                                                            "properties": {
                                                                "created": {
                                                                    "type": "string"
                                                                },
                                                                "createdBy": {
                                                                    "properties": {},
                                                                    "type": "object"
                                                                },
                                                                "created_at": {
                                                                    "type": [
                                                                        "string",
                                                                        "null"
                                                                    ]
                                                                },
                                                                "creators": {
                                                                    "type": "array"
                                                                },
                                                                "description": {
                                                                    "type": [
                                                                        "string",
                                                                        "null"
                                                                    ]
                                                                },
                                                                "id": {
                                                                    "type": [
                                                                        "string",
                                                                        "null"
                                                                    ]
                                                                },
                                                                "name": {
                                                                    "type": [
                                                                        "string",
                                                                        "null"
                                                                    ]
                                                                },
                                                                "status": {
                                                                    "type": [
                                                                        "string",
                                                                        "null"
                                                                    ]
                                                                },
                                                                "valid_from": {
                                                                    "type": [
                                                                        "string",
                                                                        "null"
                                                                    ]
                                                                },
                                                                "valid_until": {
                                                                    "type": [
                                                                        "string",
                                                                        "null"
                                                                    ]
                                                                },
                                                                "x_opencti_main_observable_type": {
                                                                    "type": [
                                                                        "string",
                                                                        "null"
                                                                    ]
                                                                },
                                                                "x_opencti_score": {
                                                                    "type": [
                                                                        "integer",
                                                                        "null"
                                                                    ]
                                                                }
                                                            },
                                                            "type": "object"
                                                        }
                                                    },
                                                    "required": [
                                                        "node"
                                                    ],
                                                    "type": "object"
                                                },
                                                "type": "array"
                                            },
                                            "pageInfo": {
                                                "properties": {
                                                    "endCursor": {
                                                        "type": [
                                                            "string",
                                                            "null"
                                                        ]
                                                    },
                                                    "globalCount": {
                                                        "type": [
                                                            "integer",
                                                            "null"
                                                        ]
                                                    },
                                                    "hasNextPage": {
                                                        "type": [
                                                            "boolean",
                                                            "null"
                                                        ]
                                                    },
                                                    "hasPreviousPage": {
                                                        "type": [
                                                            "boolean",
                                                            "null"
                                                        ]
                                                    },
                                                    "startCursor": {
                                                        "type": [
                                                            "string",
                                                            "null"
                                                        ]
                                                    }
                                                },
                                                "type": "object"
                                            }
                                        },
                                        "type": "object"
                                    }
                                },
                                "type": "object"
                            }
                        },
                        "type": "object"
                    }
                }
            },
            "Run_GraphQL_Query_Get_Indicators": {
                "runAfter": {},
                "type": "ApiConnection",
                "inputs": {
                    "body": {
                        "query": "query{\n  indicators(\nfirst:100\n after:\"@{variables('Cursor')}\"\n orderBy:created\n orderMode:asc\n  filters: \n    [ \n      {key: created_at values:\"@{body('Parse_JSON')?['outputs']?['windowStartTime']}\" operator:\"gte\"},\n      {key: created_at values:\"@{body('Parse_JSON')?['outputs']?['windowEndTime']}\" operator:\"lt\"}\n    ]\n    filterMode:and\n)\n    { \n    edges {\n      node {\n        created_at\n        entity_type\n    pattern\n    pattern_type\n        x_opencti_main_observable_type\n        name\n        id\n        created\n        creators {         \n          name\n          id\n        }\n        createdBy {\n          id\n          name\n          confidence\n        }\n        created_at\n        indicator_types\n        description\n        x_opencti_score\n        status{\n          disabled\n          id\n          type\n        }\n        valid_from\n        valid_until\n      }\n    }\n    pageInfo {\n      hasNextPage\n      hasPreviousPage\n      startCursor\n      endCursor\n      globalCount\n    }\n  }\n}"
                    },
                    "headers": {
                        "Content-Type": "application/json"
                    },
                    "host": {
                        "connection": {
                            "name": "@parameters('$connections')['OpenCTICustomConnector']['connectionId']"
                        }
                    },
                    "method": "post",
                    "path": "/graphql"
                }
            },
            "Set_variable_Cursor": {
                "runAfter": {
                    "Parse_JSON_Indicators": [
                        "Succeeded"
                    ]
                },
                "type": "SetVariable",
                "inputs": {
                    "name": "Cursor",
                    "value": "@{body('Parse_JSON_Indicators')?['data']?['indicators']?['pageInfo']?['endCursor']}"
                }
            }
        },
        "runAfter": {
            "Initialize_variable_azureTenantId": [
                "Succeeded"
            ]
        },
        "expression": "@equals(body('Parse_JSON_Indicators')?['data']?['indicators']?['pageInfo']?['hasNextPage'], false)",
        "limit": {
            "count": 4999,
            "timeout": "PT4H"
        },
        "type": "Until"
    }
BODY

  depends_on = [azurerm_logic_app_action_custom.opencti_Initialize_variable_azureTenantId]
}
