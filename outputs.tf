output "consul_public_ip" {
  value = "${azurerm_public_ip.consul.*.ip_address}"
}