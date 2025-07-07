terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

#----------------------------
# Resource Group
#----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "aks-secure-rg"
  location = "westeurope"
}

#----------------------------
# Virtual Network
#----------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#----------------------------
# Subnets
#----------------------------
resource "azurerm_subnet" "intranet" {
  name                 = "intranet-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "internet" {
  name                 = "internet-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "agic_intranet" {
  name                 = "agic-intranet-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/28"]
}

resource "azurerm_subnet" "agic_internet" {
  name                 = "agic-internet-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/28"]
}

#----------------------------
# NSGs for each subnet
#----------------------------
resource "azurerm_network_security_group" "intranet_nsg" {
  name                = "intranet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "internet_nsg" {
  name                = "internet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "agic_intranet_nsg" {
  name                = "agic-intranet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "agic_internet_nsg" {
  name                = "agic-internet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#----------------------------
# NSG Association
#----------------------------
resource "azurerm_subnet_network_security_group_association" "intranet_assoc" {
  subnet_id                 = azurerm_subnet.intranet.id
  network_security_group_id = azurerm_network_security_group.intranet_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "internet_assoc" {
  subnet_id                 = azurerm_subnet.internet.id
  network_security_group_id = azurerm_network_security_group.internet_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "agic_intranet_assoc" {
  subnet_id                 = azurerm_subnet.agic_intranet.id
  network_security_group_id = azurerm_network_security_group.agic_intranet_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "agic_internet_assoc" {
  subnet_id                 = azurerm_subnet.agic_internet.id
  network_security_group_id = azurerm_network_security_group.agic_internet_nsg.id
}

#----------------------------
# AKS Cluster with Node Pools
#----------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "secure-aks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "secureaks"

  kubernetes_version  = "1.29.2"
  sku_tier            = "Standard"

  default_node_pool {
    name                = "systemnp"
    min_count           = 1
    max_count           = 3
    enable_auto_scaling = true
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    mode                = "System"
    zones               = ["1", "2", "3"]
    vnet_subnet_id      = azurerm_subnet.intranet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    outbound_type       = "userDefinedRouting"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "intranetnp" {
  name                  = "intranetnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  min_count             = 1
  max_count             = 26
  enable_auto_scaling   = true
  vnet_subnet_id        = azurerm_subnet.intranet.id
  mode                  = "User"
  zones                 = ["1", "2", "3"]
  orchestrator_version  = "1.29.2"
}

resource "azurerm_kubernetes_cluster_node_pool" "internetnp" {
  name                  = "internetnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  min_count             = 1
  max_count             = 29
  enable_auto_scaling   = true
  vnet_subnet_id        = azurerm_subnet.internet.id
  mode                  = "User"
  zones                 = ["1", "2", "3"]
  orchestrator_version  = "1.29.2"
}

#----------------------------
# Add-ons via Helm
#----------------------------
resource "kubernetes_namespace" "kubegreen" {
  metadata {
    name = "kubegreen"
  }
}

resource "helm_release" "kubegreen" {
  name       = "kubegreen"
  namespace  = kubernetes_namespace.kubegreen.metadata[0].name
  repository = "https://kube-green.github.io/helm-charts"
  chart      = "kube-green"
  version    = "0.4.2"
}

resource "kubernetes_namespace" "azure_workload_identity" {
  metadata {
    name = "workload-identity-system"
  }
}

resource "helm_release" "workload_identity" {
  name       = "azure-workload-identity"
  namespace  = kubernetes_namespace.azure_workload_identity.metadata[0].name
  repository = "https://azure.github.io/azure-workload-identity/charts"
  chart      = "workload-identity-webhook"
  version    = "1.1.0"
}

resource "kubernetes_namespace" "csi_driver" {
  metadata {
    name = "csi-secrets-store"
  }
}

resource "helm_release" "csi_driver" {
  name       = "csi-secrets-store-provider-azure"
  namespace  = kubernetes_namespace.csi_driver.metadata[0].name
  repository = "https://azure.github.io/secrets-store-csi-driver-provider-azure/charts"
  chart      = "csi-secrets-store-provider-azure"
  version    = "1.4.0"
}

resource "kubernetes_namespace" "agic" {
  metadata {
    name = "agic"
  }
}

resource "helm_release" "agic" {
  name       = "agic"
  namespace  = kubernetes_namespace.agic.metadata[0].name
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  chart      = "ingress-azure"
  version    = "1.5.0"
}