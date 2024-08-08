terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = file("/root/key.json")
  cloud_id = "b1gu7174canjcro9e9l7"
  folder_id = "b1gl3iani8oqt0tp1rli"
  zone = "ru-central1-a"
}

resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8t2tl92i4i96khgg06"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8t2tl92i4i96khgg06"
}

resource "yandex_compute_instance" "vm1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = "e9bljefmp3smnc0tvact"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/id_ed25519.pub")}"
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          groups: [sudo]
          shell: /bin/bash
    EOF
  }

}
resource "yandex_compute_instance" "vm2" {
  name = "terraform2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = "e9bljefmp3smnc0tvact"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/id_ed25519.pub")}"
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          groups: [sudo]
          shell: /bin/bash
    EOF
  }
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm2.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm2.network_interface.0.nat_ip_address
}

resource "local_file" "ansible_inventory" {
  filename = "/etc/ansible/hosts"
  content  = <<EOT
[cert_emp_deploy]
${yandex_compute_instance.vm1.network_interface.0.nat_ip_address} ansible_user=ubuntu ansible_ssh_private_key_file=/root/.ssh/id_ed25519 ansible_ssh_host_key_checking=False
[cert_emp_prod]
${yandex_compute_instance.vm2.network_interface.0.nat_ip_address} ansible_user=ubuntu ansible_ssh_private_key_file=/root/.ssh/id_ed25519 ansible_ssh_host_key_checking=False
EOT
}
