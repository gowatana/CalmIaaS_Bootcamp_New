#cloud-config
users:
  - name: centos
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
chpasswd:
  list: |
    centos:@@{VM_CENTOS.secret}@@
  expire: False
ssh_pwauth:   true
