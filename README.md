# ResFi: A Secure Framework for Distributed Radio Resource Management of Residential WiFi Networks 

<img src="resfi-cooperation.jpg" width="700">

## 0. What is ResFi?
ResFi is a framework enabling the creation of distributed Radio Resource Management (RRM) functionality in residential or home IEEE 802.11 WLAN (Wi-Fi) deployments. The radio interface of participating APs is used for efficient discovery of adjacent APs and as a side-channel to exchange connection configuration parameters. Those parameters namely the public IP of each AP’s RRM unit and security credentials are then used to build up secured communication tunnels between adjacent APs via the Internet. 
### 0.1 How does ResFi work?
The ResFi connection procedure, depicted in the following figure, can be presented in a nutshell as follows: During the boot-up phase of any AP a broadcast probe request frame including a ResFi vendor specific information element (IEV) contain ing so called ”contact data” is triggered sequentially on each of the supported channels. Any AP within the coverage of this scan request is expected to answer with the respective ”contact data” of the responder, cf. following figure tag (1). This is possible by inserting a broadcast SSID within the probe request which triggers a response from all networks which have been able to receive this request. The contact data, embedded in a IEV of both the active scan probe and response consists of the globally-routeable IP address and port number of the AP’s RRMU (on the fixed internet) as well as of a transient one-hop group encryption key and a public cryptography key individual to this RRMU. After having completed the scan and having received the answers, the RRMU of the newly booted AP can establish a secure, point-to-point control channel to the RRMUs of all the ”discovered” APs over the wired backbone Internet, following figure, tag (2). In addition, the discovered APs will do the same in the reverse direction. 

<img src="resfi_connect.png" width="700">

Placing the control channel into the wired connectivity has several advantages. Notably there is no additional load on the wireless interfaces, and there is obviously a lower error rate. On the other hand longer message exchange delays have to be taken into account. This does not seem to be really a big issue, as the radio resource management does not take place in very short time scales. Thus coordination within one-hop neighborhood would be available at this point.
It is, however, well known that RRM (e.g. channel selection) can achieve better efficiency if performed over a cluster of
APs larger than one hop neighborhood. Therefore ResFi requires that each RRMU is able to act as a forwarder enabling to extend secure connectivity towards up to N hops (N can be set individually for every message sent via ResFi’s northbound framework API). ResFi does not define the precise policy to create an RRM cluster within the scope of the connectivity borders mentioned above; neither does it feature a specific RRM approach. Both of these decisions are delegated to an RRM application which is not a part of the platform itself. The security of the control channel is not constrained to the establishment with the use of proper cryptographic keys; in addition the keys are occasionally exchanged. Further, as the exchanged symmetric group en-
cryption keys are known to the full group, ResFi applications can, to enable confidentiality between two APs, request unicast encryption with a distinct peer. The ResFi framework will then on demand create and exchange unicast encryption keys by utilizing the asymetric keys exchanged during the discovery phase. Moreover, different RRM applications like channel assignment and interference management were implemented on top of ResFi. ResFi is available as open-source and provides a well-defined
northbound and southbound API which is shown in the following figure. 

<img src="resfi_api.jpg" width="500">

While the southbound API enables vendors and researchers easily to connect their current AP solution with the ResFi framework, the extensible northbound API is used by ResFi application developers to implement their own RRM solution. The ResFi runtime
supports the concurrent execution of multiple applications.

For more details please refer to our Paper:
<http://www.tkn.tu-berlin.de/fileadmin/fg112/Papers/2016/zehl16resfi.pdf>

## 1. Installation

### 1.1. On real hardware

We tested ResFi on the following platforms:
* Linux (Ubuntu) on x86 hardware (Intel) with IEEE 802.11 wireless devices (Atheros (ATH9K)), here the southbound API is connected as shown in the following figure.

<img src="resfi-linux.jpg" width="500">

Just execute:
```
$ sudo apt-get update ; sudo apt-get install git ; git clone https://github.com/resfi/resfi.git ; cd resfi ; chmod +x install_deps.sh ; ./install_deps.sh
```

Build hostapd and iw:

```
$ cd hostapd-20131120/hostapd/; make; cd ../../
```
```
$ cd iw-4.3; make; cd ..
```

Or as a one-liner:
```
$ sudo apt-get update ; sudo apt-get install git ; git clone https://github.com/resfi/resfi.git ; cd resfi ; chmod +x install_deps.sh ; ./install_deps.sh; cd hostapd-20131120/hostapd/; make; cd ../../; cd iw-4.3; make; cd ..
```

### 1.2. Emulation in Mininet

Emulation is tested Ubuntu 12.10 with Mininet 2.2.0
To install Mininet follow the information on http://mininet.org/download/ or simply do: sudo apt-get install mininet
No more prerequisites are required. Mininet must be run under root privileges.

## 2. Start-up

### 2.1. On real hardware

When using real hardware, please ensure that the connector module within the framework configuration file (framework/config.py) is set to CONNECTOR = "linux"
Further, adjust the name of the wired interface used for Internet connection (default eth0) in the config file using your favourite editor e.g. vim framework/config.py.


Afterwards execute:
```
$ ./start_resfi.sh phyX
```
while phyX has to be replaced by the corresponding physical interface of the wireless adapter. 
The hostapd configuration file which is used can be found in the subfolder hostapd-20131120/hostapd/hostapd-ch40.conf and can be adjusted to the needed purpose.

### 2.2. Emulation in Mininet

When using Mininet emulation, please ensure that the connector module within the framework configuration file (framework/config.py) is set to CONNECTOR = "mininet"
Afterwards execute:
```
$ cd framework/mininet; sudo python mn_driver.py
```
The additional --help command will provide more configuration possibilities.
e.g.

    usage: sudo python mn_driver.py [-h] [-r RUNTIME] [-s SEED] [-t TOPO] [-n NODES] [-c CLI]
    Commandline options:
      -h, --help                      show help message and exit
      -r RUNTIME, --runtime RUNTIME   Emulation runtime
      -s SEED, --seed SEED            Seed
      -t TOPO, --topo TOPO            Choose topology: star, tree
      -n NODES, --nodes NODES         Maximum number of nodes. 
      -c CLI, --cli CLI               (1) Open Mininet CLI for manual simulation, 
                                      afterwards type xterm apX for node access.
                                      (0) executes resfi_loader.py on every node 
                                      after the mininet topology has been loaded (default).



## 3. How to write an own ResFi application

* all ResFi apps are placed under apps/ folder
* at start-up all apps are automatically loaded and started
* all ResFi apps have to derive from class AbstractResFiApp and implement the functions run() and the callback functions for new neighbor found, neighbor left and for receiving messages from neighboring ResFi APs.

The following illustrates an example of a ResFi app:
```
import time
from common.resfi_api import AbstractResFiApp

class ResFiApp(AbstractResFiApp):

    def __init__(self, log, agent):
        AbstractResFiApp.__init__(self, log, "de.berlin.tu.tkn.hello-world", agent)

    """
    Function will be started by ResFi runtime
    """
    def run(self):
        self.log.debug("%s: plugin::hello-world started ... " % self.agent.getNodeID())

        # control loop
        while not self.isTerminated():

            # send message to ResFi neighbors using ResFi northbound API
            my_msg = {}
            my_msg['payload'] = {'msg1' : 'hello', 'msg2' : 'world!'}
            self.sendToNeighbors(my_msg, 1)

            time.sleep(1)

        self.log.debug("%s: plugin::hello-world stopped ... " % self.agent.getNodeID())

    """
    receive callback function
    """
    def rx_cb(self, json_data):
        self.log.info("%s :: recv() msg from %s at %d: %s" % (self.ns, json_data['originator'], 
            json_data['tx_time_mus'], json_data))

    """
    new Link Notification Callback
    """
    def newLink_cb(self, nodeID):
        self.log.info("%s ::newLink_cb() new AP neighbor detected notification (newLink: %s)" 
            % (self.ns, nodeID))

    """
    Link Lost Notification Callback
    """
    def linkFailure_cb(self, nodeID):
        self.log.info("%s :: linkFailure_cb() neighbor AP disconnected (lostLink: %s)" 
            % (self.ns, nodeID))

```

## 9. Contact
* Sven Zehl, TU-Berlin, zehl@tkn
* Anatolij Zubow, TU-Berlin, zubow@tkn
* Michael Döring, TU-Berlin, doering@tkn
* tkn = tkn.tu-berlin.de
* 

## 10. How to reference ResFi
Please use the following bibtex :

```
@inproceedings{Zehl16resfi,
Title = {{ResFi: A Secure Framework for Self Organized Radio Resource Management in Residential WiFi Networks}},
Author = {Zehl, Sven and Zubow, Anatolij and Wolisz, Adam and Döring, Michael},
Booktitle = {{17th IEEE International Symposium on a World of Wireless, Mobile and Multimedia Networks (IEEE WoWMoM 2016}},
Year = {2016},
Location = {Coimbra, Portugal},
Month = {June},
Note = {accepted for publication},
Url = {http://www.tkn.tu-berlin.de/fileadmin/fg112/Papers/2016/zehl16resfi.pdf}
}
```
