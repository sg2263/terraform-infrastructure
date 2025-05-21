variable "resource_group_name" {
  type    = string
 
}
variable "location" {
  type    = string
  
}
variable "vnet_name" {
  type    = string

}
variable "vnet_address_space" {

  type    = list(string)

}

variable "subnets" {
  type = map(object(
    {
      name          = string
      address_range = string
    }
  ))
  default = {
    frontend = {
      name          = "webserver-subnet-tf"
      address_range = "40.0.1.0/24"
    }
    backend = {
      name          = "backend-subnet-tf"
      address_range = "40.0.2.0/24"
    }
    database = {
      name          = "database-subnet-tf"
      address_range = "40.0.3.0/24"
    }
  }

}
variable "ssh_port" {
  type = string
  default = "22"
}
variable "http_port" {
  type = string
  default = "80"
}
variable "https_port" {
  type = string
  default = "443"
}
variable "all_port" {
  type = string
  default = "*"
}
variable "all_ip" {
  type = string
  default = "*"
}
variable "protocol" {
  type = string
  default = "Tcp"
}
variable "access" {
  type = string
  default = "Allow"
}
variable "priority_100" {
  type = number
  default = 100
}
variable "priority_110" {
  type = number
  default = 110
}
variable "priority_120" {
  type = number
  default = 120
}
variable "direction_Outbound" {
  type    = string
  default = "Outbound"
}
variable "direction_Inbound" {
  type    = string
  default = "Inbound"
}
variable "Allow-Http-Frontend" {
  type    = string
  default = "AllowHTTP"
}
variable "mysqlport" {
  type    = string
  default = "3306"
}
variable "noaccess" {
  type    = string
  default = "Deny"
}
variable "all_protocol" {
  type    = string
  default = "*"
}
variable "sku" {
  type    = string
  default = "Standard"
}
variable "static_allocate" {
  type    = string
  default = "Static"
}
variable "dynamic_allocate" {
  type    = string
  default = "Dynamic"
}
variable "size" {
  type    = string
  default = "Standard_B1s"
}
variable "user" {
  type    = string
  default = "adminuser"
}
variable "algorithm" {
  type    = string
  default = "RSA"
}
variable "rsa_size" {
  type    = number
  default = 4096
}
variable "caching" {
  type    = string
  default = "ReadWrite"
}
variable "storage_account_type" {
  type    = string
  default = "Standard_LRS"
}
variable "pub" {
  type    = string
  default = "Canonical"
}
variable "offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}
variable "sku_image" {
  type    = string
  default = "22_04-LTS"
}
variable "versioning" {
  type    = string
  default = "latest"
}
variable "storage_account_name" {
  type    = string
  default = "tfstate8181"
}
variable "account_replication_type" {
  type    = string
  default = "GRS"
}
variable "container_name" {
  type    = string
  default = "tf-states"
}
variable "container_access_type" {
  type    = string
  default = "private"
}
variable "storagekey" {
  type    = string
  default = "prod.terraform.tfstate"
}

//names 
variable "frontend-nsg-name" {
  type    = string
  default = "frontend-nsg"
}
variable "Allow-Https-Frontend" {
  type    = string
  default = "AllowHTTPS"
}
variable "Allow-Http-Frontend-Outbound" {
  type    = string
  default = "AllowHTTtoanywhere"
}
variable "Allow-SSH-Frontend-Outbound" {
  type    = string
  default = "AllowSSHtobackend"
}
variable "Allow-SSH-Frontend" {
  type    = string
  default = "AllowSSH"
}
variable "backend-nsg-name" {
  type    = string
  default = "backend-nsg"
}
variable "Allow-SSH-from-Frontend" {
  type    = string
  default = "AllowFrontend"
}
variable "Allow-SSH-to-DB" {
  type    = string
  default = "Allowtodbssh"
}
variable "Allow-MYsql-Outbound" {
  type    = string
  default = "Allowtodbmysql"
}
variable "database-nsg-name" {
  type    = string
  default = "database-nsg"
}
variable "Allow-Mysql-from-backend" {
  type    = string
  default = "AllowBackend"
}
variable "Allow-SSH-from-backend" {
  type    = string
  default = "AllowBackendssh"
}
variable "DenyALL" {
  type    = string
  default = "DenyAllInbound"
}
variable "frontend-public-ip" {
  type    = string
  default = "frontend-public-ip"
}
variable "nat-public-ip" {
  type    = string
  default = "nat-public-ip"
}
variable "nat-gateway" {
  type    = string
  default = "nat-tf"
}

//nic
variable "frontend_nic" {
  type    = string
  default = "frontend_nic"
}
variable "frontend-nic-conf" {
  type    = string
  default = "frontend-nic-conf"
}
variable "backend_nic" {
  type    = string
  default = "backend_nic"
}
variable "backend-nic-conf" {
  type    = string
  default = "backend-nic-conf"
}
variable "database_nic" {
  type    = string
  default = "database_nic"
}
variable "database-nic-conf" {
  type    = string
  default = "database-nic-conf"
}

//vms
variable "Database-VM" {
  type    = string
  default = "Database-VM"
}
variable "Backend-VM" {
  type    = string
  default = "Backend-VM"
}
variable "Frontend-VM" {
  type    = string
  default = "Frontend-VM"
}
variable "connection-type" {
  type    = string
  default = "ssh"
}
variable "timeout" {
  type    = string
  default = "10m"
}
variable "db_password" {
  type    = string
  default = "null"
}
variable "env" {
  type = string
  
}