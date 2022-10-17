OpenWebNet API scripts
======================

The protocol OpenWebNet is used for home automation
in products like `Legrand BTicino MyHome gateway F454
<https://catalogue.bticino.com/BTI-F454-EN>`_.

Some documentation may be found at `Legrand OpenWebNet
<https://developer.legrand.com/documentation/open-web-net-for-myhome/>`_.


Shutter script
--------------

The file ``own-move.sh`` allows to open, close, or stop a shutter.

The connection is using TCP/IP,
so the IP address and the TCP port of the gateway must be adjusted
at the beginning of the script file.

If the shutters are not configured in the category ``2``,
known as automation (WHO 2),
it should be changed as well at the beginning of the script file.

There is a default delay for the movement action.
After this delay, the shutter is stopped.
If the script is interrupted before the end, the shutter is stopped.

The script can be called multiple times in parallel to move the same shutter
in another direction.
The shutter will be stopped only after the last move.
All moves in progress are registered temporarily in the directory ``dir``.
This directory is created in ``/tmp`` by default.
