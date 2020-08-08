![alt tag](https://raw.githubusercontent.com/lateralblast/vamp/master/images/vamp.jpg)

VAMP
====

Virtualisation Ansible Module in Python

Introduction
------------

This is an Ansible module for VirtualBox, and KVM.

I couldn't find a suitable Anisible Module for driving VirtualBox or KVM, 
and calling VirtualBox or KVM from Ansible via shell module was tedious.

At the moment it is a simple wrapper with some handling to make it
easier to use than calling vboxmanage or virsh itself.

Usage
-----

Add path where module is to ---module-path in anisble-playbook command line.

License
-------

This software is licensed as CC-BA (Creative Commons By Attrbution)

http://creativecommons.org/licenses/by/4.0/legalcode


Requirements
------------

The following components are required:

- ansible
- python

Structure
---------

I've added some additional modularity/flexible and debugging to the module.

For example, if you want to run in debug mode without running the actual command, set the execute parameter to no:

```
- name: Don't execute function
  vamp:
    engine:   kvm
    function: list
    type:     pool
    execute:  no
```

The engine (virtualisation platform) can be automatically determined from the file name. 

To do this symlink the engine to vamp:

```
ln -s vamp kvm
```

Then do the following:

```
- name: Example with symlinked file to set engine
  kvm:
    function: list
    type:     pool
```

The engine (virtualisation platform) and function can be automatically determined from the file name, so you can symlink vbox to vamp:

To do this symlink the engine and function to vamp in the following method:

```
ln -s vamp kvm_list
```

Then do the following:

```
- name: Example with symlinked file to set engine
  kvm_list:
    type:     pool
```

Examples
--------

Check VM has 2 CPUs:

```
- name: Check CPU configuration
  vamp:
    engine:   vbox
    vmname:   vm_name
    function: modifyvm
    param:    cpus
    value:    "2"
```

Check VM has 8G:

```
- name: Check memory configuration
  vamp:
    engine:   vbox
    vmname:   vm_nsme
    function: modifyvm
    param:    memory
    value:    "8192"
```

Get List of VMs and register it:

```
- name: Get VM List and register it
  vamp:
    engine:   vbox
    function: list
    param:    vms
  register:   vm_list
```

Check VM Snapshot Folder:

```
- name: Check VM Snapshot Folder
  vamp:
    engine:   vbox
    vmname:   vm_name
    function: modifyvm
    param:    snapshotfolder
    value:    /snapshotdir
```

Check VM Running state and register it:

```
- name: Check VM running state and register it
  vamp:
    engine:   vbox
    vmname:   vm_name
    function: showvminfo
    param:    vmstate
  register:   vm_state
```

Check hostonly network has been set for NIC1:

```
- name: Check Bundle Host-only Network has been set
  vamp:
    engine:   vbox
    vmname:   vm_name
    function: modifyvm
    param:    nic1
    value:    hostonly
    options:  "--hostonlyadapter1 vboxnet0"
  when:       not "running" in vm_state.current
```

Check NAT network has been set for NIC2:

```
- name: Check NAT Network has been set 
  vamp:
    engine:   vbox
    vmname:   vm_anme
    function: modifyvm
    param:    nic2
    value:    nat
  when:       not "running" in vm_state.current
  tags:
```

Get NAT rules and register them:

```
- name: Check NAT Network Rules
  vamp:
    engine:   vbox
    vmname:   vm_name
    function: showvminfo
    param:    forwarding
  register:   nat_rules
```

Check NAT rules have been applied:

```
- name: Check NAT Rules
  vamp:
    engine:   vbox
    vmname:   vm_name
    function: modifyvm
    param:    natf2
    name:     "{{ item.rule }}"
    value:    "{{ item.nat_string }}"
  when:       not "running" in vm_state.current
  loop:
    - { rule: "rule1", nat_string: "rule1,tcp,,2222,,22" }
    - { rule: "rule2", nat_string: "rule2,tcp,,8080,,8080" }
```

Run without executing (useful for debugging):

```
- name: Unregister VM
  vamp:
    engine:   vbox
    function: unregister 
    vmname:   vm_name
    delete:   yes
    execute:  no
```

Detailed KVM Example
--------------------

This example is based on this example which creates a KVM VM with Nvidia GPU pass-through:

https://github.com/lateralblast/kvm-nvidia-passthrough


Set up some variables:

```
- hosts: all
  vars:
    primary_dns:              "8.8.8.8"
    secondary_dns:            "8.8.4.4
    ubuntu_cloud_image:       "/var/lib/libvirt/images/ubuntu-20.04-server-cloudimg-amd64.img"
    ubuntu_cloud_format:      "qcow2
    nv_bundle_file:           "/net/kvm/images/nvubuntu2004vm01.img"
    nv_bundle_network_config: "/net/kvm/images/nvubuntu2004vm01_network.cfg"
    nv_bundle_network:        "network=default,model=virtio"
    nv_bundle_nic:            "enp1s0"
    nv_bundle_ip:             "192.168.122.101"
    nv_bundle_gateway:        "192.168.122.1"
    nv_bundle_mask:           "24"
    nv_bundle_name:           "nvubuntu2004vm01"
    nv_bundle_vcpus:          "4"
    nv_bundle_cpu:            "host-passthrough"
    nv_bundle_os_type:        "linux"
    nv_bundle_os_variant:     "ubuntu20.04"
    nv_bundle_machine:        "q35"
    nv_bundle_features:       "kvm_hidden=on"
    nv_bundle_disk:           "/net/kvm/images/nvubuntu2004vm01.img,device=disk,bus=virtio /net/kvm/images/nvubuntu2004vm01_cloud.img,device=cdrom"
    nv_bundle_cloud_image:    "/net/kvm/images/nvubuntu2004vm01_cloud.img"
    nv_bundle_cloud_config:   "/net/kvm/images/nvubuntu2004vm01_cloud.cfg"
    nv_bunde_memory:          "32678"
    nv_bundle_boot:           "hd,menu=on"
    nv_bundle_graphics:       "none"
    nv_bundle_memory:         "65536"
```

Convert (copy) a cloud image into a KVM VM disk:

```
- name: Copy Ubuntu KVM Cloud Image
  kvm:
    function:   convert
    format:     "{{ ubuntu_cloud_format }}"
    inputfile:  "{{ ubuntu_cloud_image }}"
    outputfile: "{{ nv_bundle_file }}"
```

Resize disk image:

```
- name: Resize disk image
  kvm:
    function:   resize
    inputfile:  "{{ nv_bundle_file }}"
    size:       50G
```

Create a cloud config file:

```
- name: Check Nvidia KVM VM cloud config
  copy:
    content:  |
              #cloud-config
              hostname: {{ nv_bundle_name }}
              groups:
                - nvadmin: nvadmin
              users:
                - default
                - name: nvadmin
                  gecos: NvAdmin
                  primary_group: nvadmin
                  groups: users
                  shell: /bin/bash
                  passwd: {{ temp_password_hash }}
                  sudo: ALL=(ALL) NOPASSWD:ALL
                  lock_passwd: false
              packages:
                - qemu-guest-agent
                - net-tools
                - software-properties-common
                - nvidia-driver-390
                - freeglut3
                - freeglut3-dev
                - libxi-dev
                - libxmu-dev
                - gcc-7
                - g++-7
              growpart:
                mode: auto
                devices: ['/']
              power_state:
                mode: reboot
    dest:     "{{ nv_bundle_cloud_config }}" 
```

Create network config file:

```
- name: Check Nvidia KVM VM cloud network config
  copy:
    content:  |
              version 2
              ethernets:
                {{ nv_bundle_nic }}:
                  dhcp4: false
                  addresses: [ {{ nv_bundle_ip }}/{{ nv_bundle_mask }}]
                  gateway4: {{ nv_bundle_gateway }}
                  nameservers:
                    addresses: [ {{ primary_dns }},{{ secondary_dns }} ]
    dest:     "{{ nv_bundle_network_config }}" 
```

Get Nvidia IDs:

```
- name: Check Nvidia PCI IDs
  shell:  |
          set -o pipefail
          lspci |grep -i nvidia |grep -vi audio |head -1 |awk '{print $1}'
  args:
    executable: /bin/bash
  register: nvidia_pci_ids
```

Create KVM VM:

```
- name: Create Ubuntu Nvidia KVM VM
  kvm:
    function:     install
    name:         "{{ nv_bundle_name }}"
    vcpus:        "{{ nv_bundle_vcpus }}"
    disk:         "{{ nv_bundle_disk}}"
    cpu:          "{{ nv_bundle_cpu }}"
    os-type:      "{{ nv_bundle_os_type }}"
    os-variant:   "{{ nv_bundle_os_variant }}"
    host-device:  "{{ nvidia_pci_ids.stdout }}"
    machine:      "{{ nv_bundle_machine }}"
    features:     "{{ nv_bundle_features }}"
    network:      "{{ nv_bundle_network }}"
    graphics:     "{{ nv_bundle_graphics }}"
    memory:       "{{ nv_bundle_memory }}"
    import:       yes
```
