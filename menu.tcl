
set discbot "DiscordBOT"

# Set your access level: people with this flag will be able
# to use the 'set' command.
set proc_user o

# Menufile location. Set this to the directory you want 
# the file to be written in.
set conf_dir "~/eggdrop/scripts"\

# Bindings
bind dcc $proc_user menu dcc:menu
bind msg $proc_user !menuset msg:menu

bind pub -|- !menu menu_return
bind pubm - "% % !menu*" menu_return_disc

# Set Script Version 
set ver "v1.0"

# Intialize Variable
if {[file exists $conf_dir/menu]} {
   if {[file readable $conf_dir/menu]} {
      set tempmenu [open $conf_dir/menu r]
      set menu_info [string trim [gets $tempmenu ] "\{\}"]
      close $tempmenu 
   }
} else {
   set tempmenu [open $conf_dir/menu w]
   set menu_info "Delicious Ruthmarnan delicacies..."
   puts $tempmenu "$menu_info"
   close $tempmenu 
}

# DCC Proc to set the weather report
proc dcc:menu {hand idx arg} {
   global menu_info conf_dir
   set cmd [lindex $arg 0]
   switch $cmd {
     "set" {
         set new_menu [lrange $arg 1 end]
         set tempmenu  [open $conf_dir/menu w]
         puts $tempmenu  "$new_menu"   
         close $tempmenu 
         set menu_info "$new_menu"
         putdcc $idx "Menu  now set to: $new_menu"
         putcmdlog "#$hand# Menu set ..."
      }
      default {
         putdcc $idx "Weather is currently: $menu_info"
         putdcc $idx "USAGE: .menu set <new weather>"
         putcmdlog "#$hand# weather"
      }
   }
}

# Message Proc to set the weather via message
proc msg:menu {nick uhost handle args} {
   global menu_info conf_dir 
   set new_menu [lrange $args 0 end]
   set args [lindex $args 0]
   if {($args == "")} {
      puthelp "NOTICE $nick :USAGE: !menuset <new weather>"
      putcmdlog "($nick!$uhost) !$handle! !menuset"
   } else {
      set tempmenu [open $conf_dir/menu w]
      puts $tempmenu "$new_menu"
      close $tempmenu
      set tempmenu [open $conf_dir/menu r]
      set menu_info [string trim [gets $tempmenu] "\{\}"]
      close $tempmenu
      puthelp "NOTICE $nick :Weather now set to: $menu_info"
      putcmdlog "($nick!$uhost) !$handle! !weatherset $menu_info"
   }
}

# Proc to get the current weather via a notice from the bot
proc menu_return {nick uhost hand chan data} {
   global menu_info 
      puthelp "PRIVMSG $chan :From the Black Dragon Inn kitchens: $menu_info"
   return 0
}

# Same as above but triggered from pubm. Checks nick against
# discord bridge name.

proc menu_return_disc {nick uhost hand chan data} {
   global menu_info 
   global discbot
 if {[string equal $nick $discbot]} {
     puthelp "PRIVMSG $chan :From the Black Dragon Inn kitchens: $menu_info"
     return 0
   }
}


putlog "BDI Menu $ver by Kylus & Freakuancy loaded!"
