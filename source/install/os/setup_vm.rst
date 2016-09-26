.. _vm_setup:

################
VM configuration
################


VM setup
--------

When creating a VM, you may not want to give VMWare all the information about the system. 
The reason behind this is because VMWare is smart enough to automatically handle some SO installation stages; this stages
will be skipped on the UI, and this will make the deployment procedure different than one performed on a real machine.
   

Setting up VMWare
-----------------

Sample settings for creating a new VM:

- VM configuration: Custom
- HW compatibility: workstation 8 
- Install OS from: I will install the the operationg system later
- Guest OS: Linux Centos 64-bit
- VM name: *setup the name*
- Processors: 1 processor, 2 cores
- Memory: 6144MB
- Network connection: bridged

Then configure the disk as you need.
1
This is a sample configuration:

- I/O Controller type: LSI Logic
- Disk: create a new virtual disk
- Virtual disk type: SCSI
- Mode: Independent, persistent
- Max disk size: 30G, store virtual disk as a single file.

Then configure the DVD reader setting the ISO image of the OSinstaller, and start the VM. 


