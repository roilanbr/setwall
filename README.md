# setwall
Forzar la resolución del monitor ejecutando "xrandr"

<code>
#!/bin/sh
sleep 2
xrandr --output HDMI-A-0 --mode 1366x768 --scale-from 1641x923
xrandr --output HDMI-A-0 --mode 1366x768 --scale-from 1640x922
</code>
