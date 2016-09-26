.. _install_oracle_java:

#####################
Installing Oracle JDK
#####################

Until recently, the Oracle JDK was a better performer than the OpenJDK, so it was the preferred choice. 
This is no longer true, anyway in the following paragraph you can find
instruction about how to install the Oracle JDK.

You can download the Oracle JDK RPM from this page:

  http://www.oracle.com/technetwork/java/javase/downloads/index.html

Oracle does not expose a URL to automatically dowload the JDK because an interactive licence acceptance is requested.  
You may start downloading the JDK RPM from a browser, and then either:

* stop the download from the browser and use on the server the dynamic download URL your browser has been assigned, or
* finish the download and transfer the JDK RPM to the server using ``scp``.   

Once you have the ``.rpm`` file, you can install it by::

  rpm -ivh jdk-7u51-linux-x64.rpm


Once installed, you still see that the default ``java`` and ``javac`` commands 
are still the ones from OpenJDK.
In order to switch JDK version you have to set the proper system `alternatives`.

You may want to refer to `this page <http://www.rackspace.com/knowledge_center/article/how-to-install-the-oracle-jdk-on-fedora-15-16>`_ .
Issue the command::

   alternatives --install /usr/bin/java java /usr/java/latest/bin/java 200000 \
   --slave /usr/lib/jvm/jre jre /usr/java/latest/jre \
   --slave /usr/lib/jvm-exports/jre jre_exports /usr/java/latest/jre/lib \
   --slave /usr/bin/keytool keytool /usr/java/latest/jre/bin/keytool \
   --slave /usr/bin/orbd orbd /usr/java/latest/jre/bin/orbd \
   --slave /usr/bin/pack200 pack200 /usr/java/latest/jre/bin/pack200 \
   --slave /usr/bin/rmid rmid /usr/java/latest/jre/bin/rmid \
   --slave /usr/bin/rmiregistry rmiregistry /usr/java/latest/jre/bin/rmiregistry \
   --slave /usr/bin/servertool servertool /usr/java/latest/jre/bin/servertool \
   --slave /usr/bin/tnameserv tnameserv /usr/java/latest/jre/bin/tnameserv \
   --slave /usr/bin/unpack200 unpack200 /usr/java/latest/jre/bin/unpack200 \
   --slave /usr/share/man/man1/java.1 java.1 /usr/java/latest/man/man1/java.1 \
   --slave /usr/share/man/man1/keytool.1 keytool.1 /usr/java/latest/man/man1/keytool.1 \
   --slave /usr/share/man/man1/orbd.1 orbd.1 /usr/java/latest/man/man1/orbd.1 \
   --slave /usr/share/man/man1/pack200.1 pack200.1 /usr/java/latest/man/man1/pack200.1 \
   --slave /usr/share/man/man1/rmid.1.gz rmid.1 /usr/java/latest/man/man1/rmid.1 \
   --slave /usr/share/man/man1/rmiregistry.1 rmiregistry.1 /usr/java/latest/man/man1/rmiregistry.1 \
   --slave /usr/share/man/man1/servertool.1 servertool.1 /usr/java/latest/man/man1/servertool.1 \
   --slave /usr/share/man/man1/tnameserv.1 tnameserv.1 /usr/java/latest/man/man1/tnameserv.1 \
   --slave /usr/share/man/man1/unpack200.1 unpack200.1 /usr/java/latest/man/man1/unpack200.1

Then run ::
  
   alternatives --config java
   
and select the number related to ``/usr/java/latest/bin/java``.

Now the default java version should be the Oracle one.
Verify the proper installation on the JDK::

  # java -version
  java version "1.7.0_51"
  Java(TM) SE Runtime Environment (build 1.7.0_51-b13)
  Java HotSpot(TM) 64-Bit Server VM (build 24.51-b03, mixed mode) 
  # javac -version
  javac 1.7.0_51
  
