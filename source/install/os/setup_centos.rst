.. _centos_setup:

###############################
Installing the Operating System
###############################

CentOS Setup
============

We are re going to install a minimal CentOS 7 distribution. 
You can get a copy of the .iso the image used for the installation 
`here <http://mi.mirror.garr.it/mirrors/CentOS/7/isos/x86_64/CentOS-7-x86_64-Minimal-1511.iso>`_.

If the previous link is not working, you may want to `check for the latest release <http://mi.mirror.garr.it/mirrors/CentOS/7/isos/x86_64/>`_ .  

Boot up the installation DVD and start the `CentOS 7` Installation wizard.

You may want to customize at least these items:

    - `Keyboard`: choose the keyboard layout
    - `Networking`: configure your network interface according to your infrastructure;
      you can either set it to `DHCP` to automatically get all the settings from
      a local DHCP server or configure it by hand.    
    - `Select Date & Time`: set appropriate Date and Time settings.
      Enable NTP synchronization to periodically get date and time settings from CentOS servers    
    - `Installation Destination`: select the hard disk where CentOS will
      be installed. 
      
      You may select "Automatically configure partitioning" or configure the partitions by yourself. 
      You may use the following partitioning scheme if you wish:
      
      +-----------------+----------------+-----------+-------------+
      | Partition Label | Partition Type | Size      | Mount Point |
      +=================+================+===========+=============+
      | boot            | ext3           |   700 MB  | /boot       |
      +-----------------+----------------+-----------+-------------+
      | root            | ext4           |    35 GB  | /           |
      +-----------------+----------------+-----------+-------------+
      | swap            | swap           |     4 GB  |             |
      +-----------------+----------------+-----------+-------------+
    - Click on `Begin Installation`
    - Now set the password for the ``root`` user. Also click on `User Creation` to
      create the ``toor`` user (an unprivileged user).
    -  Wait for the installation process to finish, then reboot your machine


Network configuration
=====================

The network configuration should already be set, since it was set during CentOS 
setup stage. 

You may want to review the configuration files

   ``/etc/sysconfig/network-scripts/ifcfg-DEVICE``

You may also want to review the file ``/etc/resolv.conf`` 
to check the nameservers.

Check that the connection is up by pinging an external server::

   ping 8.8.8.8

Check that the DNS are properly configuring by pinging a host by its name::

   ping google.com

.. attention:: 
   Please note that in CentOS only ssh incoming connections are allowed; 
   all other incoming connections are disabled by default.
          
   In the paragraph related to the httpd service you can find details about
   how to enable incoming traffic. 

Note that after configuring the network, you may continue installing the system setup using a ssh connection.


User access configuration
=========================

Login as ``root`` user and give the ``toor`` user administrative privileges
by adding him to the ``wheel`` group: ::

   usermod -aG wheel toor

SSH access
----------

Allow SSH connections through the firewall
''''''''''''''''''''''''''''''''''''''''''

On CentOS 7 the firewall is enabled by default. To allow SSH clients to connect
to the machine allow incoming connections on port 22::

    firewall-cmd --zone=public --add-port=22/tcp --permanent
    firewall-cmd --zone=public --add-service=ssh --permanent
    firewall-cmd --reload

Disable SSH login for the `root` user
'''''''''''''''''''''''''''''''''''''
.. warning::
    Before you disable root login make sure you are able to login via SSH with
    ``toor`` user account and you have the privileges to run ``sudo su`` to
    switch to the ``root`` user account.

Edit file ``/etc/ssh/sshd_config`` to disable ``root`` login via SSH::

    PermitRootLogin no

Public key authentication
'''''''''''''''''''''''''

`Public key authentication`_ is generally considered a safer way to authenticate
users for SSH access. Let's set it up and disable password based authentication

.. _a link: https://en.wikipedia.org/wiki/Public-key_cryptography

First generate a public/private key pair using `ssh-keygen`::

    ssh-keygen

Follow the procedure, you will end up with your newly generated key under ``~/.ssh``
Now copy your **public** (by default it is called id_rsa.pub) key over the CentOS
machine in ``/home/toor/.ssh/authorized_keys``. There are several ways to do
it, we are going to use the `ssh-copy-id` tool::

        ssh-copy-id -i ~/.ssh/id_rsa.pub toor@<server-ip-address>

You should now be able to login via SSH as ``toor`` without been asked for
the password::

    ssh toor@<server-ip-address>

You can now disable password based login over SSH

.. warning::
    Before disabling password authentication make sure you' ve installed your
    public key on the server and you are able to login without password

Edit ``/etc/ssh/sshd_config`` as follows::

    ...
    RSAAuthentication yes
    ...
    PubkeyAuthentication yes
    ...
    PasswordAuthentication no
    ...
    UsePAM no
    ...


Installing ntp
==============

Install the program for ntp server synchronization::

   yum install ntp

Optionally, edit ``/etc/ntp.conf`` and add your own ntp servers before the first ``server`` directive.
For instance, in Italy you may want to use the institutional time server::

   server tempo.ien.it     # Galileo Ferraris

Replace ``tempo.ien.it`` with your nearest ntp server.

Sync with the server by issuing::

   systemctl start ntpd 
 
Set the time synchronization as an autostarting daemon::
 
   systemctl enable ntpd


Installing base packages
========================

Install::

  yum install man
  yum install vim
  yum install openssh-clients    # also needed for incoming scp connections
  yum install mc                 # mc (along with zip) can be used to navigate inside .war files
  yum install zip unzip
  yum install wget curl
  yum install git
  
    