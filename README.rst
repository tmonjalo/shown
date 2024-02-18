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


Shutter integration in Home Assistant
-------------------------------------

The script ``own-move.sh`` can be used to control shutters from Home Assistant.

Home Assistant forbids scripts to write outside of its configuration directory.
For this reason the variable ``dir`` of the script ``own-move.sh``
must be adjusted.

In order to ease its integration, the script ``own-hass-config.sh``
will generate the configuration to copy/paste in ``configuration.yaml``.

The list of shutters ID and name must be provided in the variable ``shutters``
at the beginning of the script file ``own-hass-config.sh``.
The format is "ID friendly name", one shutter per line.


Remote control of shutters via Home Assistant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After requesting a secret token in Home Assistant profile page
(``http://home-assistant:8123/profile``),
the REST API can be used to control the shutters remotely.

A basic command using ``curl`` would look like this::

   jo entity_id=cover.kitchen |
   curl -sH "Authorization: Bearer 53CR37_70K3N" --json @- \
   http://home-assistant:8123/api/services/cover/action

where ``action`` can be one of:

- open_cover
- close_cover
- stop_cover

The full list of actions can be queried with::

   curl -sH "Authorization: Bearer 53CR37_70K3N" \
   http://home-assistant:8123/api/services |
   jq -r '.[] | select(.domain=="cover").services | keys | .[]' | sort

The name of cover entities can be queried with::

   curl -sH "Authorization: Bearer 53CR37_70K3N" \
   http://home-assistant:8123/api/states |
   jq -r '.[].entity_id' | grep '^cover' | sort
