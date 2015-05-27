iwb-control
===========

A very limited set of functions to find & control the various devices on the JMSS network that implement the ESC/VP.net protocol, written in Rust. Currently, the port and ip range are hard-coded -- future versions will have these be customizable. The final version of this program should also have a GUI that calls the discover_hosts() function and automates the more basic ESC/VP.net commands. The application will only work when either connected to eduroam or an eduroam-based VPN, since Monash firewalls external connections.

Password-protected servers are supported, but have not yet been properly tested. For some reason, I am not getting all the devices in even-numbered rooms (e.g. 1b2, 1b4, 2b2 etc..)  responding, if anyone knows why / how to fix, I would greatly appreciate it.
