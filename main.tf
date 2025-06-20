resource "oci_core_virtual_network" "vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "vcn-terraform"
}
resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "default-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "igw"
}
resource "oci_core_security_list" "http_ssh" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "http-ssh-security-list"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "oci_core_subnet" "subnet" {
  cidr_block        = "10.0.1.0/24"
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_virtual_network.vcn.id
  display_name      = "subnet-terraform"
  security_list_ids = [oci_core_security_list.http_ssh.id]
  route_table_id = oci_core_route_table.rt.id

  prohibit_public_ip_on_vnic = false
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  
}


resource "oci_core_instance" "vm" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E2.1.Micro"

  display_name = "vm-ubuntu"

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_public_ip = true
  }

 source_details {
  source_type           = "image"
  source_id                = data.oci_core_images.ubuntu.images[0].id
  boot_volume_size_in_gbs = 50
}


  metadata = {
    ssh_authorized_keys = file("C:\\Users\\Saulo\\Downloads\\.oci\\id_rsa.pub")
    user_data = base64encode(data.template_file.user_data.rendered)
  }
}