# Terraform Azure setup

Sign up for Azure:

  * Go to https://portal.azure.com

  * You'll need a credit card

If you want install Python, PIP, and Azure on a Mac:

    brew install python
    pip install --pre azure

Get your subscription id:

  * Go to https://portal.azure.com

  * To see your subscription id, look on the web page left side icon column.

  * click the "Billing" icon. 

  * You see "Active subscriptions you've cereated" and a column "SUBSCRIPTION ID" column. 

  * Make a note of your subscription id.

See https://www.terraform.io/docs/providers/azurerm/


Example:

    # Configure the Microsoft Azure Provider
    provider "azurerm" {
      subscription_id = "d521ea4e-a074-11e6-9fad-3c15c2dca7b2"
      client_id       = "..."
      client_secret   = "..."
      tenant_id       = "..."
    }

# Create a resource group
resource "azurerm_resource_group" "production" {
    name     = "production"
    location = "West US"
}

# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "network" {
  name                = "productionNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.production.name}"

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
  }
}

