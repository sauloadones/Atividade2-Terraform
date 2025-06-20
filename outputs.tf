output "public_ip" {
  value = oci_core_instance.vm.public_ip
}

output "ubuntu_image_id" {
  value = data.oci_core_images.ubuntu.images[0].id
}