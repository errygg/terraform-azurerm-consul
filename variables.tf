variable "consul_subnet" {
  description = "Subnet CIDR for PTFE"
  default     = "10.0.0.0/24"
}

variable "location" {
  description = "Location (Region) of Azure"
  default     = "westus"
}

# Required
variable "namespace" {
  description = "Unique namespace for the resource group name"
}

variable "network_space" {
  description = "Virtual network address space"
  default     = "10.0.0.0/16"
}

variable "public_ip_name" {
  description = "Public IP address name"
  default     = "consul-public-ip"
}

# Required
variable "ssh_key_file" {
  description = "SSH key file"
}

variable "subnet_name" {
  description = "Name of the subnet that resources will be placed in"
  default     = "consul-subnet"
}

variable "virtual_network_name" {
  description = "Name of the main Virtual Network to place all of the Azure resources"
  default     = "consul-virtual-network"
}





