##############################################################################
# ArangothWorld.tcl - Settings and Specifics for the Land of Arangoth, the   #
#                     setting for the #BlkDragon*Inn IRC FFRP Channel.       #
#   by Kylus <kylus@arangoth.org> <Kylus@Sorcery>                            #
#                                                                            #
# This script is probably not useful to too many other people as-is except   #
# to serve as an example for some neat functions to do certain calculations. #
# This script provides information about the setting we have developed in    #
# the BlkDragon Inn IRC Free Form Roleplaying game. I wrote this mainly be-  #
# cause I'm a big nerd, and decided to put some 'reality' into things that   #
# were otherwise nebulous.                                                   #
#                                                                            #
# Arangoth as a setting contains its own method of telling time, its own set #
# of months and days, its own calendar years, one sun (which is similar to   #
# ours for the sake of mathematical simplicity!) and two moons (one of which #
# is the same as ours orbit-wise, again for easy math). This script will let #
# a user ask the bot what the day, date, and time in Arangoth is at any      #
# given moment, along with known holidays in Arangoth. It will also display  #
# the sunrise, sunset, and rising/setting of each of the moons in the world. #
#                                                                            #
# I'm trying to code this to be as generic as possible so someone else can   #
# use it for their own setting, but forgive me if I don't make it as robust  #
# as some of my other scripts. O:) Feel free to send me patches, ideas for   #
# improvements, or general comments about the utter nerdiness of the script! #
#                                                                            #
##############################################################################
	# This script has been modified by Freakuancy for use over 
 			# the Discord<->IRC Bridge 
##############################################################################
################################ CONFIGURATION ###############################
#
# The name of the Discord<=>IRC Bridge
set discname "DiscordBOT"


# TZ - Set this to the default timezone offset from GMT you wish the time to
# be measured in. By default our setting operates on Central Standard Time
# (-6)
set TZ -6

# Latitude and Longitude. Set the location you wish to use for calculating 
# the times of the heavenly bodies. Keep in mind that Latitudes in the 
# Southern Hemisphere and Longitudes in the Western Hemisphere are NEGATIVE
set LAT 38.7969
set LON -85.4186

# Months - A simple list of month names. In our setting we have our own names
# for the twelve months
set MONTHS "{Morning Star} {Sun's Dawn} {First Seed} {Rain's Hand} \
            {Second Seed} {Sun's Height} Midyear {Last Seed} \
            Heartfire {Frost Fall} {Sun's Dusk} {Evening Star}"

# Days - A simple list of days. Our setting has its own names for the seven
# days of the week.
set DAYS "Sundas Morndas Tirdas Middas Tordas Fredas Loredas"

# Hours - A simple list of hours for the time of the day. In our setting we've
# renamed the hours based on 'bells'. The list should start with Midnight (00)
# and end with 11 PM (23)
set HOURS "{Late Night} {First Late} {Second Late} {Third Late} \
     {Fourth Late} {Fifth Late} Dawn {First Ascending} \
     {Second Ascending} {Third Ascending} {Fourth Ascending} {Fifth Ascending} \
     Noon {First Descending} {Second Descending} {Third Descending} \
     {Fourth Descending} {Fifth Descending} Dusk {First Night} \
     {Second Night} {Third Night} {Fourth Night} {Fifth Night}"

# Holidays - Set this to an array of days that are designated holidays. The 
# form should be HOLIDAY(date) = name where 'date' is four numbers: a two
# digit month (00-11) and two digit day (01-31). Name is the name of the
# holiday.
set HOLIDAY(0001) "New Year's Day"
set HOLIDAY(0116) "Heart Day"
set HOLIDAY(0217) "the First Planting"
set HOLIDAY(0223) "the Day of Renewal"
set HOLIDAY(0231) "Jester's Folly"
set HOLIDAY(0301) "Jester's Folly"
set HOLIDAY(0302) "Jester's Folly"
set HOLIDAY(0303) "Jester's Folly"
set HOLIDAY(0304) "Jester's Folly"
set HOLIDAY(0307) "the Second Planting"
set HOLIDAY(0517) "the Mid-Year Celebration"
set HOLIDAY(0610) "the Merchants' Festival"
set HOLIDAY(0620) "Sun's Rest"
set HOLIDAY(0712) "the Fast of Ethcabar"
set HOLIDAY(0713) "the Morning Feast"
set HOLIDAY(0801) "Bonfire Day"
set HOLIDAY(0817) "the Feast of Eggs"
set HOLIDAY(1004) "Brakerrat"
set HOLIDAY(1117) "Candlenight"       

# Year - set the base year in your setting. In our setting, dates are computed
# based on the year 470 (which = 2000 in reality). So it will be the year 475
# in 2005.
set YEAR 470

# Newday - At what hour does the date roll over? In our setting a new day 
# starts at dawn (0600) as opposed to midnight. 
set NEWDAY 6

# Ring - do you want the bot to perform an action on the hour (such as announce
# the time)? Set this to 1 if so, and set "RINGCHANS" below.
set RING 1

# Ringchans - Set this to the list of channels you want the 'chime' procedure
# to perform its action.
set RINGCHANS "#blkdragon*inn #blkdragon*inn2 #bdi*outside"

# Contact - Set up how the bot responds to private requests for the date/time
# or celestial body information. Should be PRIVMSG or NOTICE
set CONTACT PRIVMSG

# Action - Set this to the default action you want for text returned to the 
# user. 
#  +only - Gives the date and time
#  +sun  - Gives date, time and sunrise/sunset
#  +moon - Gives date, time, sunrise/sunset and moonrise/moonset
#  +all  - Gives all information from the other three options
set ACTION +only

############################ END OF CONFIGURATION ############################
############################## CODE STARTS HERE ##############################

# Meta stuff
set arver "2.0 BETA"

# Global Variables for the Sun/Moon calculations (ugh)
set PI [expr acos(-1)]
set DR [expr $PI / 180]
set K1 [expr 15 * $DR * 1.0027379]

# This procedure will compute the date based on the settings defined above
# and returns formatted strings with the appropriate information.
proc arangoth:date {} {
   global TZ YEAR MONTHS
   global DAYS HOURS NEWDAY

   # Get clock time in seconds, and check to make sure we don't need to roll
   # it back based on criteria defined above:
   #   - We start at GMT and adjust by $TZ hours 
   set seconds [expr [clock seconds] + [expr $TZ * 3600]]
   
   # Format this into a list to work with later.
   set now [clock format $seconds -format "%w %m %d %y %H %M %S" -gmt 1]

   # Check for holidays 
   set holiday [arangoth:holiday "$now"]

   # Strip off the leading zeroes, else we can't use the numbers in
   # lindex properly. 
   regsub -all {0([1-9])} $now {\1} now

   # Check when NEWDAY starts and adjust the day if necessary. 
   if {[lindex $now 4] >= 0 && [lindex $now 4] < $NEWDAY} {
      set now [lreplace $now 2 2 [expr [lindex $now 2] - 1]]
   }

   # Get the short date using the arangoth:short proc
   set short [arangoth:short "$now"]
   
   # Set up the strings to return. First we'll look at the minute of the hour
   # to set up the time string. If the minute is 00, the Bell is ringining now
   # Between 1-29 it is x minutes past the Bell. 30 it is half past the Bell.
   # 31-59 is 60-x minutes until the next bell. 
   set min [lindex $now 5]
   set bell "[lindex $HOURS [lindex $now 4]] Bell"
   if {$min == 00} {
      set time "The $bell can be heard ringing."
   } elseif {$min == 01} {
      set time "It is 1 minute past the $bell."
   } elseif {$min > 01 && $min < 30} {
      set time "It is $min minutes past the $bell."
   } elseif {$min == 30} {
      set time "It is half past the $bell."
   } elseif {$min > 30 && $min < 59} {
      set time "It is [expr 60 - $min] minutes until the [lindex $HOURS [expr [lindex $now 4] + 1]] Bell tolls."
   } elseif {$min == 59} {
      set time "It is 1 minute until the [lindex $HOURS [expr [lindex $now 4] + 1]] Bell tolls."
   }
   
   # Fix up minutes less than ten to be two digits and add a simple
   # (HH:MM) translation to the end of the time string
   if {[lindex $now 5] > 0 && [lindex $now 5] < 10} {
      set now [lreplace $now 5 5 0[lindex $now 5]]
   }
   set time "$time ([lindex $now 4]:[lindex $now 5] AST)"

   # Set up the date. This should be easier than the last string
   set date "Today is [lindex $DAYS [lindex $now 0]], [lindex $MONTHS [expr [lindex $now 1] - 1]] [lindex $now 2], in the Year [expr $YEAR + [lindex $now 3]]. ($short)"

   # We join the strings with a ~ character to let arangoth:msg parse 
   # them into separate lines in IRC /msg's
   return "$date~$holiday$time"
}

# This procedure returns a short date in the form used in our setting:
# 'day.month.year' with month being a Roman numeral.
proc arangoth:short {date} {
   global YEAR

   set date [split $date]
   set rns "I II III IV V VI VII VIII IX X XI XII"

   set day [lindex $date 2]
   set mon [lindex $rns [expr [lindex $date 1] - 1]]
   set yr  [expr $YEAR + [lindex $date 3]]

   return "$day.$mon.$yr"
}

# This procedure checks for a holiday, and returns a string if one 
# is found for the current day. If not, it returns ""
proc arangoth:holiday {data} {
   global HOLIDAY

   set mon [lindex $data 1]
   set day [lindex $data 2]
   set holiday ""

   if {[lsearch -exact [array names HOLIDAY] "$mon$day"] > -1} {
      set holiday "Today is $HOLIDAY($mon$day), a holiday in Arangoth.~"
   }

   return "$holiday"
}

# This procedure returns a string of text to the user via a PRIVMSG.
# If you want multiple lines, separate your strings by putting a ~ between
# them and the proc will split each one on that character.
proc arangoth:msg {chan data} {
   global CONTACT 
   set msg [split $data ~]
   
   foreach m $msg {
      after 500
      putserv "$CONTACT $chan :$m"
   }
}
# This procedure handles the data from the user via /msg. It can take a few
# options to give the user more information (such as sun/moon rise).
bind pub - !date arangoth:datecmd
bind pubm - "% % !date*" arangoth:datecmddiscord

proc arangoth:datecmd {nick uhost hand chan data} {
   global ACTION
  # Check to see if this is our bridge bot

   # See if $data contains anything and check it, otherwise default
   # to just the date
   if {$data == ""} {
      set opt $ACTION
   } else {
      # If the first argument starts with a +, it's an option. Parse it! :)
      if {[string index [lindex $data 0] 0] == "+"} {
         set opt [lindex $data 0]
      } else {  
         arangoth:datehelp $chan
         return
      }
   }
  
   putcmdlog "($nick!$uhost) !$hand! !date"

   switch $opt {
      "+only" { 
         set date [arangoth:date]
         arangoth:msg $chan $date
      }

      "+sun"  { 
         set date [arangoth:date]
         set sun  [arangoth:sun]
         arangoth:msg $chan $date
         arangoth:msg $chan $sun
      }

      "+moon" {
         set date [arangoth:date] 
         set moon [arangoth:moon]
         arangoth:msg $chan $date
         arangoth:msg $chan $moon
      }

      "+all" {
         set date [arangoth:date]
         set sun  [arangoth:sun]       
         set moon [arangoth:moon]
         arangoth:msg $chan $date
         arangoth:msg $chan $sun
         arangoth:msg $chan $moon
      }

      default {
         arangoth:datehelp $chan
      }
    }
 }
# If RING is set to '1', bind a 'clock chime' proc to go off on the hour.
if {$RING == 1} {
   bind TIME - "00 * * * *" arangoth:chime
}
proc arangoth:datecmddiscord {nick uhost hand chan data} {
   global discname


##############################################################################
# Added for Discord<->IRC Bridge. Not implementing unfinished sun/moon changes

putserv "PRIVMSG $chan $nick"
  # Check to see if this is our bridge bot
   if {[string equal $nick $discname]} {	
         # Get DATE string and send to channel 
         set date [arangoth:date]
         arangoth:msg $chan $date
 }
}

# If RING is set to '1', bind a 'clock chime' proc to go off on the hour.
if {$RING == 1} {
   bind TIME - "00 * * * *" arangoth:chime
}
proc arangoth:chime {min hour day month year} {
   global RINGCHANS HOURS TZ

   set seconds [expr [clock seconds] + [expr $TZ * 3600]]
   set hour [clock format $seconds -format "%H" -gmt 1]
   set time [clock format $seconds -format "%I:%M %p" -gmt 1]
   regsub -all {0([1-9])} $hour {\1} hour

   foreach chan [string tolower [channels]] {
      if {[lsearch $RINGCHANS $chan] > -1} {
         putserv "PRIVMSG $chan :\0036Outside, the Clock Tower tolls once to mark the hour of the [lindex $HOURS $hour] Bell ($time).\003"
      }
   }
}

proc arangoth:jd {} {


}

putlog "Arangoth World Settings v$arver, by Kylus, Loaded!"
