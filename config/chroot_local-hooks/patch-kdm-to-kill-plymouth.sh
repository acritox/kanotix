#!/bin/sh
if [ -f /etc/init.d/kdm ]; then
 patch --no-backup-if-mismatch -p0 <<'EOT'
--- /etc/init.d/kdm	2011-02-12 20:16:11.000000000 +0100
+++ /etc/init.d/kdm	2011-09-28 04:05:22.977140278 +0200
@@ -126,6 +126,10 @@
        [ "$(cat $DEFAULT_DISPLAY_MANAGER_FILE)" != "$DAEMON" ]; then
       log_action_msg "Not starting K Display Manager (kdm); it is not the default display manager."
     else
+      log_action_msg "Killing plymouth..."
+      if pidof plymouthd >/dev/null; then
+        /bin/plymouth --quit --wait
+      fi
       log_daemon_msg "Starting K Display Manager" "kdm"
       if start-stop-daemon --start --quiet $SSD_ARGS -- $ARG ; then
         log_end_msg 0
EOT
else
 exit 0
fi
