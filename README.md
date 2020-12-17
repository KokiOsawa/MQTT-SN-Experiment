MQTT-SN Tools
=============

[![Build Status](https://travis-ci.org/njh/mqtt-sn-tools.svg?branch=master)](https://travis-ci.org/njh/mqtt-sn-tools)

Command line tools written in C for the MQTT-SN (MQTT for Sensor Networks) protocol.


Supported Features
------------------

- QoS 0, 1 and -1
- Keep alive pings
- Publishing retained messages
- Publishing empty messages
- Subscribing to named topic
- Clean / unclean sessions
- Manual and automatic client ID generation
- Displaying topic name with wildcard subscriptions
- Pre-defined topic IDs and short topic names
- Forwarder encapsulation according to MQTT-SN Protocol Specification v1.2.


Limitations
-----------

- Packets must be 255 or less bytes long
- No Last Will and Testament
- No QoS 2
- No automatic re-sending of lost packets
- No Automatic gateway discovery


Building
--------

Just run 'make' on a POSIX system.


Publishing
----------

    Usage: mqtt-sn-pub [opts] -t <topic> -m <message>

      -d             Increase debug level by one. -d can occur multiple times.
      -f <file>      A file to send as the message payload.
      -h <host>      MQTT-SN host to connect to. Defaults to '127.0.0.1'.
      -i <clientid>  ID to use for this client. Defaults to 'mqtt-sn-tools-' with process id.
      -k <keepalive> keep alive in seconds for this client. Defaults to 10.
      -e <sleep>     sleep duration in seconds when disconnecting. Defaults to 0.
      -m <message>   Message payload to send.
      -l             Read from STDIN, one message per line.
      -n             Send a null (zero length) message.
      -p <port>      Network port to connect to. Defaults to 1883.
      -q <qos>       Quality of Service value (0, 1 or -1). Defaults to 0.
      -r             Message should be retained.
      -s             Read one whole message from STDIN.
      -t <topic>     MQTT-SN topic name to publish to.
      -T <topicid>   Pre-defined MQTT-SN topic ID to publish to.
      --fe           Enables Forwarder Encapsulation. Mqtt-sn packets are encapsulated according to MQTT-SN Protocol Specification v1.2, chapter 5.5 Forwarder Encapsulation.
      --wlnid        If Forwarder Encapsulation is enabled, wireless node ID for this client. Defaults to process id.
      --cport <port> Source port for outgoing packets. Uses port in ephemeral range if not specified or set to 0.

    optinal fuction(Koki Osawa added)
      Entering the following message will help you when measuring the delay.
      "test5"             send 5 publish messages
      "test10"            send 10 publish messages
      "test100"           send 100 publish messages
      "test1000"          send 1000 publish messages
      "test10000"         send 10000 publish messages
      "test100000"        send 100000 publish messages

    If you want to use the padding function, use "pd <number>".
    The following are currently allowed:
      "test5pd100"             send 5 publish messages (Just 100 bytes message)
      "test10pd100"            send 10 publish messages (Just 100 bytes message)
      "test100pd100"           send 100 publish messages (Just 100 bytes message)
      "test1000pd100"          send 1000 publish messages (Just 100 bytes message)
      "test10000pd100"         send 10000 publish messages (Just 100 bytes message)
      "test100000pd100"        send 100000 publish messages (Just 100 bytes message)

      "test5pd200"             send 5 publish messages (Just 200 bytes message)
      "test10pd200"            send 10 publish messages (Just 200 bytes message)
      "test100pd200"           send 100 publish messages (Just 200 bytes message)
      "test1000pd200"          send 1000 publish messages (Just 200 bytes message)
      "test10000pd200"         send 10000 publish messages (Just 200 bytes message)
      "test100000pd200"        send 100000 publish messages (Just 200 bytes message)





Subscribing
-----------

    Usage: mqtt-sn-sub [opts] -t <topic>

      -1             exit after receiving a single message.
      -c             disable 'clean session' (store subscription and pending messages when client disconnects).
      -d             Increase debug level by one. -d can occur multiple times.
      -h <host>      MQTT-SN host to connect to. Defaults to '127.0.0.1'.
      -i <clientid>  ID to use for this client. Defaults to 'mqtt-sn-tools-' with process id.
      -k <keepalive> keep alive in seconds for this client. Defaults to 10.
      -e <sleep>     sleep duration in seconds when disconnecting. Defaults to 0.
      -p <port>      Network port to connect to. Defaults to 1883.
      -q <qos>       QoS level to subscribe with (0 or 1). Defaults to 0.
      -t <topic>     MQTT-SN topic name to subscribe to. It may repeat multiple times.
      -T <topicid>   Pre-defined MQTT-SN topic ID to subscribe to. It may repeat multiple times.
      --fe           Enables Forwarder Encapsulation. Mqtt-sn packets are encapsulated according to MQTT-SN Protocol Specification v1.2, chapter 5.5 Forwarder Encapsulation.
      --wlnid        If Forwarder Encapsulation is enabled, wireless node ID for this client. Defaults to process id.
      -v             Print messages verbosely, showing the topic name.
      -V             Print messages verbosely, showing current time and the topic name.
      --cport <port> Source port for outgoing packets. Uses port in ephemeral range if not specified or set to 0.


Dumping
-------

Displays MQTT-SN packets sent to specified port.
Most useful for listening out for QoS -1 messages being published by a client.

    Usage: mqtt-sn-dump [opts] -p <port>

      -a             Dump all packet types.
      -d             Increase debug level by one. -d can occur multiple times.
      -p <port>      Network port to listen on. Defaults to 1883.
      -v             Print messages verbosely, showing the topic name.


Serial Port Bridge
------------------

The Serial Port bridge can be used to relay packets from a remote device on the end of a
serial port and convert them into UDP packets, which are sent and received from a broker
or MQTT-SN gateway.

    Usage: mqtt-sn-serial-bridge [opts] <device>

      -b <baud>      Set the baud rate. Defaults to 9600.
      -d             Increase debug level by one. -d can occur multiple times.
      -dd            Enable extended debugging - display packets in hex.
      -h <host>      MQTT-SN host to connect to. Defaults to '127.0.0.1'.
      -p <port>      Network port to connect to. Defaults to 1883.
      --fe           Enables Forwarder Encapsulation. Mqtt-sn packets are encapsulated according to MQTT-SN Protocol Specification v1.2, chapter 5.5 Forwarder Encapsulation.
      --cport <port> Source port for outgoing packets. Uses port in ephemeral range if not specified or set to 0.

Subscribe data example (optional function)
------------------

If you use the optional functions, you can get the following results.
By using this program based on the following command example, you can analyze the delay time in Excel or other programs.

    Usage: ./mqtt-sn-sub <option> > "file name".txt

      Recieve Time : 2020/12/17(Thu) 16:40:10.762885 <-- Send Time : 2020/12/17(Thu) 16:40:10.761221 :test-00001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.765288 <-- Send Time : 2020/12/17(Thu) 16:40:10.763626 :test-00002xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.768450 <-- Send Time : 2020/12/17(Thu) 16:40:10.766735 :test-00003xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.771549 <-- Send Time : 2020/12/17(Thu) 16:40:10.769640 :test-00004xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.773919 <-- Send Time : 2020/12/17(Thu) 16:40:10.772376 :test-00005xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.775570 <-- Send Time : 2020/12/17(Thu) 16:40:10.775207 :test-00006xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.776703 <-- Send Time : 2020/12/17(Thu) 16:40:10.776295 :test-00007xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.779211 <-- Send Time : 2020/12/17(Thu) 16:40:10.777378 :test-00008xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.780716 <-- Send Time : 2020/12/17(Thu) 16:40:10.778667 :test-00009xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Recieve Time : 2020/12/17(Thu) 16:40:10.782071 <-- Send Time : 2020/12/17(Thu) 16:40:10.780131 :test-00010xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

License
-------

MQTT-SN Tools is licensed under the [MIT License].



[MIT License]: http://opensource.org/licenses/MIT
