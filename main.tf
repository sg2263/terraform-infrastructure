
resource "azurerm_resource_group" "tf_refer_rg" {
    name = "${var.resource_group_name}-${terraform.workspace}"
    location = var.location
 }

resource "azurerm_virtual_network" "tf_refer_vnet" {
    name = "${var.vnet_name}-${terraform.workspace}"
    resource_group_name = "${var.resource_group_name}-${terraform.workspace}"
    location = azurerm_resource_group.tf_refer_rg.location
    address_space = var.vnet_address_space

}

resource "azurerm_subnet" "dynamic_subnets" {
  for_each = var.subnets
  name                 = "${each.value.name}-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.tf_refer_rg.name
  virtual_network_name = azurerm_virtual_network.tf_refer_vnet.name
  address_prefixes     = [each.value.address_range]
}
/*resource "azurerm_subnet" "tf_refer_webserver" {
  name  = "webserver-subnet-tf"
  resource_group_name = azurerm_resource_group.tf_refer_rg.name
  virtual_network_name = azurerm_virtual_network.tf_refer_vnet.name
  address_prefixes = ["40.0.1.0/24"] 
}
resource "azurerm_subnet" "backend_subnet_tf" {
  name   = "backend-subnet-tf"
  resource_group_name  = azurerm_resource_group.tf_refer_rg.name
  virtual_network_name = azurerm_virtual_network.tf_refer_vnet.name
  address_prefixes = ["40.0.2.0/24"] 
}
resource "azurerm_subnet" "database_subnet" {
  name = "database-subnet-tf"
  resource_group_name  = azurerm_resource_group.tf_refer_rg.name
  virtual_network_name = azurerm_virtual_network.tf_refer_vnet.name
  address_prefixes  = ["40.0.3.0/24"] 
}*/


//NSG deployment 
# Frontend NSG 
resource "azurerm_network_security_group" "frontend_nsg" {
  name = "${var.frontend-nsg-name}-${terraform.workspace}"
    location = azurerm_resource_group.tf_refer_rg.location
  resource_group_name = azurerm_resource_group.tf_refer_rg.name

  security_rule {
    name = "${var.Allow-Http-Frontend}-${terraform.workspace}"
    priority = var.priority_100
    direction = var.direction_Inbound
    access = var.access
    protocol  = var.protocol
    source_port_range = var.http_port
    destination_port_range = var.http_port
    source_address_prefix = var.all_ip
    destination_address_prefix = var.all_ip
  }

  security_rule {
    name = "${var.Allow-Https-Frontend }-${terraform.workspace}"
    priority = var.priority_110
    direction = var.direction_Inbound
    access= var.access
    protocol = var.protocol
    source_port_range = var.https_port
    destination_port_range = var.https_port
    source_address_prefix = var.all_ip
    destination_address_prefix = var.all_ip
  }

  security_rule {
    name =  "${var.Allow-Http-Frontend-Outbound  }-${terraform.workspace}"
    priority = var.priority_100
    direction = var.direction_Outbound
    access = var.access
    protocol = var.protocol
    source_port_range  = var.http_port
    destination_port_range = var.all_port
    source_address_prefix = var.all_ip
    destination_address_prefix = var.all_ip
  }
    security_rule {
    name =  "${var.Allow-SSH-Frontend-Outbound }-${terraform.workspace}"
    priority = var.priority_110
    direction = var.direction_Outbound
    access = var.access
    protocol = var.protocol
    source_port_range  = var.ssh_port
    destination_port_range = var.ssh_port
    source_address_prefix = var.all_ip
    destination_address_prefix = var.all_ip
  }
      security_rule {
    name =  "${var.Allow-SSH-Frontend }-${terraform.workspace}"
    priority = var.priority_120
    direction = var.direction_Inbound
    access = var.access
    protocol = var.protocol
    source_port_range  = var.all_port
    destination_port_range = var.ssh_port
    source_address_prefix = var.all_ip
    destination_address_prefix = var.all_ip
  }

}
#associating frontend nsg to frontend subnet 
resource "azurerm_subnet_network_security_group_association" "tf_refer_frontendnsg" {
  subnet_id = azurerm_subnet.dynamic_subnets["frontend"].id
  network_security_group_id = azurerm_network_security_group.frontend_nsg.id
}

# Backend NSG
resource "azurerm_network_security_group" "backend_nsg" {
  name =   "${var.backend-nsg-name}-${terraform.workspace}"
  location  = azurerm_resource_group.tf_refer_rg.location
  resource_group_name = azurerm_resource_group.tf_refer_rg.name

  security_rule {
    name =   "${var.Allow-SSH-from-Frontend}-${terraform.workspace}"
    priority = var.priority_100
    direction = var.direction_Inbound
    access = var.access
    protocol = var.protocol
    source_port_range = var.all_port
    destination_port_range = var.ssh_port
    source_address_prefix = var.all_ip//azurerm_subnet.tf_refer_webserver.address_prefixes[0] 
    destination_address_prefix = var.all_ip
  }

    security_rule {
    name =  "${var.Allow-SSH-to-DB}-${terraform.workspace}"
    priority = var.priority_100
    direction = var.direction_Outbound
    access = var.access
    protocol = var.protocol
    source_port_range = var.all_port
    destination_port_range = var.ssh_port
    source_address_prefix = azurerm_subnet.dynamic_subnets["backend"].address_prefixes[0] 
    destination_address_prefix = azurerm_subnet.dynamic_subnets["database"].address_prefixes[0] 
  }
      security_rule {
    name ="${var.Allow-MYsql-Outbound}-${terraform.workspace}"
    priority = var.priority_110
    direction = var.direction_Inbound
    access = var.access
    protocol = var.protocol
    source_port_range = var.all_port
    destination_port_range = var.mysqlport
    source_address_prefix = azurerm_subnet.dynamic_subnets["backend"].address_prefixes[0] 
    destination_address_prefix = azurerm_subnet.dynamic_subnets["database"].address_prefixes[0] 
  }
        security_rule {
    name = "allow-http-${terraform.workspace}"
    priority = var.priority_120
    direction = var.direction_Inbound
    access = var.access
    protocol = var.protocol
    source_port_range = var.all_port
    destination_port_range = var.http_port
    source_address_prefix = var.all_ip
    destination_address_prefix = azurerm_subnet.dynamic_subnets["backend"].address_prefixes[0] 
  }
}
resource "azurerm_subnet_network_security_group_association" "tf_refer_backendnsg"{
  subnet_id = azurerm_subnet.dynamic_subnets["backend"].id
  network_security_group_id = azurerm_network_security_group.backend_nsg.id 
}

# Database NSG 
resource "azurerm_network_security_group" "database_nsg" {
  name  = "${var.database-nsg-name }-${terraform.workspace}"
  location = azurerm_resource_group.tf_refer_rg.location
  resource_group_name = azurerm_resource_group.tf_refer_rg.name

  security_rule {
    name = "${var.Allow-Mysql-from-backend }-${terraform.workspace}"
    priority = var.priority_100
    direction = var.direction_Inbound
    access = var.access
    protocol = var.protocol
    source_port_range = var.all_port
    destination_port_range = var.mysqlport
    source_address_prefix = var.all_ip//azurerm_subnet.dynamic_subnets["backend"].address_prefixes[0] 
    destination_address_prefix = var.all_ip
  }
  security_rule {
    name =  "${var.Allow-SSH-from-backend}-${terraform.workspace}"
    priority = var.priority_110
    direction = var.direction_Inbound
    access = var.access
    protocol = var.protocol
    source_port_range = var.all_port
    destination_port_range = var.ssh_port
    source_address_prefix = azurerm_subnet.dynamic_subnets["backend"].address_prefixes[0] 
    destination_address_prefix = var.all_ip
  }
    security_rule {
    name = "SSH-From-webserver-${terraform.workspace}"//var.Allow-SSH-from-backend
    priority = 105
    direction = var.direction_Inbound
    access = var.access
    protocol = var.protocol
    source_port_range = var.all_port
    destination_port_range = var.ssh_port
    source_address_prefix = azurerm_subnet.dynamic_subnets["frontend"].address_prefixes[0] 
    destination_address_prefix = var.all_ip
  }
  security_rule {
    name   = "${var.DenyALL}-${terraform.workspace}" 
    priority = var.priority_120
    direction = var.direction_Inbound
    access = var.noaccess
    protocol  = var.all_protocol
    source_port_range = var.all_port
    destination_port_range = var.all_port
    source_address_prefix = var.all_ip
    destination_address_prefix = var.all_ip
  }
}
resource "azurerm_subnet_network_security_group_association" "tf_refer_databasensg"{
  subnet_id = azurerm_subnet.dynamic_subnets["database"].id
  network_security_group_id = azurerm_network_security_group.database_nsg.id 
}

//IP provisioning for NAT and Virtual Machine 
resource "azurerm_public_ip" "tf_refer_publicip_frontend" {
  name = "${var.frontend-public-ip}-${terraform.workspace}" 
  resource_group_name = azurerm_resource_group.tf_refer_rg.name
  location = azurerm_resource_group.tf_refer_rg.location
  allocation_method = var.static_allocate  
  sku  = var.sku
}
resource "azurerm_public_ip" "tf_refer_publicip_nat" {
  name =  "${var.nat-public-ip}-${terraform.workspace}" 
  resource_group_name = azurerm_resource_group.tf_refer_rg.name
  location  = azurerm_resource_group.tf_refer_rg.location
  allocation_method  = var.static_allocate 
  sku = var.sku
}
//NAT Gateway creation , ip association and subnet association 
resource "azurerm_nat_gateway" "tf_refer_NAT" {
    name = "${var.nat-gateway}-${terraform.workspace}" 
    resource_group_name =azurerm_resource_group.tf_refer_rg.name
    location = azurerm_resource_group.tf_refer_rg.location
}
resource "azurerm_nat_gateway_public_ip_association" "tf_refer_NAT" {
    nat_gateway_id = azurerm_nat_gateway.tf_refer_NAT.id
    public_ip_address_id = azurerm_public_ip.tf_refer_publicip_nat.id
}
resource "azurerm_subnet_nat_gateway_association" "backend_subnet_nat"{
    subnet_id = azurerm_subnet.dynamic_subnets["backend"].id
    nat_gateway_id = azurerm_nat_gateway.tf_refer_NAT.id

}
resource "azurerm_subnet_nat_gateway_association" "database_subnet_nat"{
    subnet_id= azurerm_subnet.dynamic_subnets["database"].id
    nat_gateway_id = azurerm_nat_gateway.tf_refer_NAT.id

}
// NIC creation for 3 virtual machines 
resource "azurerm_network_interface" "tf_refer_frontend_nic"{
    name =  "${var.frontend_nic}-${terraform.workspace}" 
    resource_group_name = azurerm_resource_group.tf_refer_rg.name
    location = azurerm_resource_group.tf_refer_rg.location

    ip_configuration {
      name =   "${var.frontend-nic-conf}-${terraform.workspace}" 
      subnet_id = azurerm_subnet.dynamic_subnets["frontend"].id
      private_ip_address_allocation = var.dynamic_allocate
      public_ip_address_id = azurerm_public_ip.tf_refer_publicip_frontend.id
    }
}
resource "azurerm_network_interface" "tf_refer_backend_nic"{
    name =  "${var.backend_nic}-${terraform.workspace}" 
    resource_group_name = azurerm_resource_group.tf_refer_rg.name
    location = azurerm_resource_group.tf_refer_rg.location

    ip_configuration {
      name =  "${var.backend-nic-conf}-${terraform.workspace}" 
      subnet_id = azurerm_subnet.dynamic_subnets["backend"].id
      private_ip_address_allocation = var.dynamic_allocate
      
    }
}
resource "azurerm_network_interface" "tf_refer_database_nic"{
    name =  "${var.database_nic}-${terraform.workspace}" 
    resource_group_name = azurerm_resource_group.tf_refer_rg.name
    location = azurerm_resource_group.tf_refer_rg.location

    ip_configuration {
      name =  "${var.database-nic-conf}-${terraform.workspace}" 
      subnet_id = azurerm_subnet.dynamic_subnets["database"].id
      private_ip_address_allocation = var.dynamic_allocate
    }
}
//database Virtual Machine Creation and ssh key
resource "tls_private_key" "tf_refer_databaseKey"{
algorithm = var.algorithm
rsa_bits =   var.rsa_size
}
resource "local_file" "database_ssh_key" {
  filename  = "${var.env}_keys/${var.Database-VM}_key.pem" 
  content = tls_private_key.tf_refer_databaseKey.private_key_pem
  file_permission = "0600" 
}
resource "azurerm_linux_virtual_machine" "tf_refer_DatabaseVm" {
  name                  = "${var.Database-VM }-${terraform.workspace}" 
  resource_group_name   = azurerm_resource_group.tf_refer_rg.name
  location              = azurerm_resource_group.tf_refer_rg.location
network_interface_ids = [azurerm_network_interface.tf_refer_database_nic.id]
size = var.size
admin_username =  "${var.user}-${terraform.workspace}" 


os_disk{
    caching = var.caching
    storage_account_type = var.storage_account_type
}
source_image_reference {
    publisher = var.pub
    offer     = var.offer
    sku       = var.sku_image
    version   = var.versioning
}
admin_ssh_key {
    username   = "${var.user}-${terraform.workspace}" 
    public_key = tls_private_key.tf_refer_databaseKey.public_key_openssh
}


}
resource "null_resource" "configure_mysql" {
  connection {
    type                = var.connection-type
    host                = azurerm_linux_virtual_machine.tf_refer_DatabaseVm.private_ip_address
    user                = "${var.user}-${terraform.workspace}" 
    private_key         = tls_private_key.tf_refer_databaseKey.private_key_pem
    timeout             = var.timeout
    bastion_host        = azurerm_public_ip.tf_refer_publicip_frontend.ip_address
    bastion_user        = var.user
    bastion_private_key = tls_private_key.tf_refer_frontendKey.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mysql-server",

      "sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf",

      "sudo systemctl enable mysql",
      "sudo systemctl restart mysql",

      "sudo mysql -e \"CREATE DATABASE chatappdb;\"",
      "sudo mysql -e \"CREATE USER 'appuser'@'%' IDENTIFIED BY '${var.db_password}';\"",
      "sudo mysql -e \"GRANT ALL PRIVILEGES ON chatappdb.* TO 'appuser'@'%';\"",
      "sudo mysql -e \"FLUSH PRIVILEGES;\"",
      
    ]
  }
}

//Backend Virtual Machine creation , ip association , ssh key 
resource "tls_private_key" "tf_refer_backendKey"{
algorithm = var.algorithm
rsa_bits = var.rsa_size
}
resource "local_file" "backend_ssh_key" {
  filename  = "${var.env}_keys/${var.Backend-VM}_key.pem" 
  content = tls_private_key.tf_refer_backendKey.private_key_pem
  file_permission = "0600" 
}

resource "azurerm_linux_virtual_machine" "tf_refer_backendVm" {
  name                  =  "${var.Backend-VM}-${terraform.workspace}" 
  resource_group_name   = azurerm_resource_group.tf_refer_rg.name
  location              = azurerm_resource_group.tf_refer_rg.location
network_interface_ids = [azurerm_network_interface.tf_refer_backend_nic.id]
  size                  = var.size
  admin_username        = "${var.user}-${terraform.workspace}" 

  os_disk {
    caching              = var.caching
    storage_account_type = var.storage_account_type
}
source_image_reference {
    publisher = var.pub
    offer     = var.offer
    sku       = var.sku_image
    version   = var.versioning
}

admin_ssh_key {
    username   = "${var.user}-${terraform.workspace}" 
    public_key = tls_private_key.tf_refer_backendKey.public_key_openssh
}
}

//Frontend Virtual Machine creation , ip association , ssh key 
resource "tls_private_key" "tf_refer_frontendKey"{
algorithm = var.algorithm
rsa_bits = var.rsa_size
}
resource "local_file" "frontend_ssh_key" {
  filename  = "${var.env}_keys/${var.Frontend-VM}_key.pem" 
  content = tls_private_key.tf_refer_frontendKey.private_key_pem
  file_permission = "0600" 
}

resource "azurerm_linux_virtual_machine" "tf_refer_frontendVm" {
name = "${var.Frontend-VM}-${terraform.workspace}" 
resource_group_name =azurerm_resource_group.tf_refer_rg.name 
location = azurerm_resource_group.tf_refer_rg.location 
network_interface_ids = [azurerm_network_interface.tf_refer_frontend_nic.id]
size = var.size
admin_username ="${var.user}-${terraform.workspace}" 


os_disk{
    caching = var.caching
    storage_account_type = var.storage_account_type
}
source_image_reference {
    publisher = var.pub
    offer = var.offer
    sku = var.sku_image                   
    version = var.versioning
}
admin_ssh_key {
    username = "${var.user}-${terraform.workspace}" 
    public_key = tls_private_key.tf_refer_frontendKey.public_key_openssh
}
}
