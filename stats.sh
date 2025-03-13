#!/bin/bash
#
# Created:      160225
#

## FUNCTIONS ##

platest()
{
  penv | sort -k2n | awk -vnow=$(date +%s) ' i
        BEGIN { first=""; last=""; }

        /lastwelcome/ {
           p=$1;
           sub(/_lastwelcome/, "", p);
           time_ago = now-$2
           time_left = time_ago
           days = time_ago / 86400
           hours = (time_ago % 86400) / 3600
           minutes = (time_ago % 3600) / 60
           seconds = (time_ago % 60)
           colour=""

           if (days > 0) { msg = sprintf("%d days", days); colour="[1m"; }
           if (hours > 0) msg = sprintf("%s, %d hours", msg, hours);
           if (minutes > 0) msg = sprintf("%s, %d mins", msg, minutes);
           if (seconds > 0) msg = sprintf("%s, %d secs", msg, seconds);

           if (days < 1) { last=p; if (first=="") first=p; }

           if (days < 1)
           {
              printf("%s%-15s %s ago.[0m\n", colour, p, msg);
           }
           else
           {
              printf("%-15s %s ago.\n", p, msg);
           }
       }

        END \
        {
          print "";
          if (last != "") last_s = sprintf("last used %s", last);
          if (first != "") first_s = sprintf("first used %s", first);

          printf("Last 24 hrs: %s // %s\n", first_s, last_s);
        }
  '
}


breakdown_seconds() {
    local total_seconds=$1
    local days=$(( total_seconds / 86400 ))
    local hours=$(( (total_seconds % 86400) / 3600 ))
    local minutes=$(( (total_seconds % 3600) / 60 ))
    local seconds=$(( total_seconds % 60 ))

    echo "$days days, $hours hours, $minutes minutes, $seconds seconds"
}

## EOF ##
