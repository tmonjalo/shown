#! /bin/sh -e

# Generate Home Assistant configuration to integrate in configuration.yaml

actions="\
0 stop
1 open
2 close"

# TO BE ADJUSTED
shutters="\
 0 all
10 kitchen
11 room 1
12 room 2"

cat <<- END
logger:
  default: info
  #logs:
  #  homeassistant.components.shell_command: debug

shell_command:
  shutter: /full/path/own-move.sh "{{id}}" "{{direction}}"

script:
  shutter:
    mode: parallel
    sequence:
      service: shell_command.shutter
      data:
        id: "{{id}}"
        direction: "{{direction}}"

cover:
  - platform: template
    covers:
END
echo "$shutters" | while read id name ; do
slug=$(echo $name | sed 's, ,_,g' | tr '[:upper:]' '[:lower:]')
cat <<- END

      $slug:
        friendly_name: "$name"
        unique_id: "$name"
        device_class: shutter
        position_template: 50
END
echo "$actions" | while read direction action ; do
cat <<- END
        ${action}_cover:
          service: script.turn_on
          data:
            entity_id: script.shutter
            variables:
              id: $id
              direction: $direction
END
done
done
