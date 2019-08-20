###########################################################
# Weather Report TCL version 2.1                          #
# By Kylus <Kylus@EFNet>  <kylus@blkdragon.com>           #
# Written for bots on the #BlkDragon*Inn EFNet channels   #
# Last updated 04/02/00                                   #
# This is a complete rewrite of my old script. It is free #
# of course, just make sure to give me credit, please! :) #
#                                                         #
# This script will allow you to set a 'weather report' on #
# a bot that will be accessible to all users via a simple #
# channel command -- the default is !weather. This can be #
# easily changed to a message command or bound to other   #
# flags if it is abused. Enjoy, if anyone else has a use  #
# for it :)                                               #
########################################################### 
# History:                                                #
#    10/15/98 - v1.0 Intial Release                       #
#    10/30/98 - v1.1 Buxfix for lost weather with .rehash #
#    12/03/99 - v2.0 Complete rewrite to read from file   #
#    04/02/00 - v2.1 Added 'putcmdlog' to the function    #
#    02/28/02 - v2.3 Added a pub bind to tell people that #
#                    it's a /msg command. Changed all the #
#                    putservs to puthelps, and added a    #
#                    check for WebTV to send weather via  #
#                    /msg to them instead of a /notice.   #
###########################################################


# Set your access level: people with this flag will be able
# to use the 'set' command.
set proc_user o

# Weatherfile location. Set this to the directory you want 
# the file to be written in.
set conf_dir "~/eggdrop/scripts/weather"

####################### Do Not Change Anything Else! #########################

# Bindings
bind dcc $proc_user weather dcc:weather
bind msg $proc_user !weatherset msg:weather

bind pub -|- !weather weather_return
bind pubm -|- "% % !weather*" weather_return_disc


# Name of Discord <-> IRC Bridge
set discbot "Freakuancy"


# Set Script Version 
set ver "v2.4"

# Intialize Variable
if {[file exists $conf_dir/weather]} {
   if {[file readable $conf_dir/weather]} {
      set temp [open $conf_dir/weather r]
      set weather_info [string trim [gets $temp] "\{\}"]
      close $temp
   }
} else {
   set temp [open $conf_dir/weather w]
   set weather_info "Cloudy, with a chance of meatballs..."
   puts $temp "$weather_info"
   close $temp
}

# DCC Proc to set the weather report
proc dcc:weather {hand idx arg} {
   global weather_info conf_dir
   set cmd [lindex $arg 0]
   switch $cmd {
     "set" {
         set new_info [lrange $arg 1 end]
         set temp [open $conf_dir/weather w]
         puts $temp "$new_info"   
         close $temp
         set weather_info "$new_info"
         putdcc $idx "Weather now set to: $new_info"
         putcmdlog "#$hand# weather set ..."
      }
      default {
         putdcc $idx "Weather is currently: $weather_info"
         putdcc $idx "USAGE: .weather set <new weather>"
         putcmdlog "#$hand# weather"
      }
   }
}

# Message Proc to set the weather via message
proc msg:weather {nick uhost handle args} {
   global weather_info conf_dir 
   set new_info [lrange $args 0 end]
   set args [lindex $args 0]
   if {($args == "")} {
      puthelp "NOTICE $nick :USAGE: !weatherset <new weather>"
      putcmdlog "($nick!$uhost) !$handle! !weatherset"
   } else {
      set temp [open $conf_dir/weather w]
      puts $temp "$new_info"
      close $temp
      set temp [open $conf_dir/weather r]
      set weather_info [string trim [gets $temp] "\{\}"]
      close $temp
      puthelp "NOTICE $nick :Weather now set to: $weather_info"
      putcmdlog "($nick!$uhost) !$handle! !weatherset $weather_info"
   }
}

# Proc to get the current weather via a notice from the bot
proc weather_return {nick uhost hand chan data} {
   global weather_info 
      puthelp "PRIVMSG $chan :From the Arangoth Weather Center: $weather_info"
   putcmdlog "($nick!$uhost) !$hand! !weather"
   return 0
}
proc weather_return_disc {nick uhost hand chan data} {
   global weather_info 
   global discbot
 if {[string equal $nick $discbot]} {
     puthelp "PRIVMSG $chan :From the Arangoth Weather Center: $weather_info"
     return 0
   }
}

# Stupid Proc to tell people it's a /msg command <g>
proc weather_warn {nick uhost handle channel} {
    global botnick
    puthelp "PRIVMSG $nick :Try '/msg $botnick !weather' ;)"
}

putlog "Weather Report $ver by Kylus & Freakuancy loaded!"
   
