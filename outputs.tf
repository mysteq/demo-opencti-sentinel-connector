output "managed_identity_principal_id" {
  value = azurerm_logic_app_workflow.opencti_importtosentinel.identity[0].principal_id
}