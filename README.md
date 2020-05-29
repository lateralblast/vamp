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
