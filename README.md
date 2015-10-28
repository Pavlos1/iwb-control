iwb-control
===========

A very limited set of functions to find & control the various projection devices on the JMSS network that implement the ESC/VP.net protocol, written in Rust. Currently, the port and ip range are hard-coded -- future versions will have these customizable. The application will only work when either connected to eduroam or an eduroam-based VPN, since Monash firewalls external connections.

Password-protected servers are supported, but have not yet been properly tested. For some reason, I am not getting all the devices in even-numbered rooms (e.g. 1b2, 1b4, 2b2 etc..)  responding, if anyone knows why / how to fix, I would greatly appreciate it.

Windows is a pain to set up, I haven't been able to do it without installing the QT development toolkits.

Requirements
------------
Ubuntu 15.04 +: qml-module-qtquick-controls
Ubuntu <= 14.10: qt5qml-quickcontrols

And the QT libraries for compilation & dynamic linking
