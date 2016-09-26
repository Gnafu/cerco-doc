.. _os_httpd_install:

===============================
Apache HTTP Server Installation
===============================


Install Apache::

    yum install httpd

And additional modules::

    yum install httpd mod_ssl mod_proxy_html 
    yum install mod_wsgi


Firewall configuration
----------------------

Allow requests on port 80 through the firewall::

    firewall-cmd --zone=public --add-port=80/tcp --permanent
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --reload

Apache start and stop
---------------------

To start and stop Apache, run::

    systemctl start httpd
    systemctl stop httpd

To automatically start Apache at boot, run::

    systemctl enable httpd

Log Rotation
''''''''''''

`httpd` log rotation should be already configured. Check it, and if it isn't, then configure it:
 
Edit the configuration file for logrotate to rotate Apache log files
``/etc/logrotate.d/httpd`` as follows::

    /var/log/httpd/*log {
        daily
        maxsize 100M
        rotate 14
        create 644 root root
        missingok
        notifempty
        sharedscripts
        compress
        delaycompress
        postrotate
            /bin/systemctl reload httpd.service > /dev/null 2>/dev/null || true
        endscript
    }

And add the following line to the crontab::

    crontab -e
    
    0 * * * * /usr/sbin/logrotate /etc/logrotate.d/httpd
    