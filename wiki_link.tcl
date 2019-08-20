#========================================================================
# ** Wikipedia Quick Link
#========================================================================
# * Description:
#
#    * Allows IRC users to link to wikipedia quickly through the bot.
#    * The default format is:
#       !wiki article name
#
#------------------------------------------------------------------------
# * Features:
#
#    * Replaces spaces by underscores. Example:
#         Article Name
#      will become
#         Article_Name
#      in the link
#    * Changes first letter of the article to upper case. Example:
#         article	
#      will become
#         Article
#      in the link
#	EDIT: Now converts to proper Title Case, uppercasing the first letter of all words except 
#			is, and, of, the and a.
#
#    * Works over Discord<->IRC Bridge	
#
#    * Mentions which nickname requested the link to prevent confusion.
#
#========================================================================

# Calls the script when people say !wiki at the start of the line.
# Changes this to whatever you want to make the script call on other
#  keywords.
set discbot "DiscordBOT"

bind pub - "!wiki" spidey:wiki_link
bind pubm - "% % !wiki*" spidey:wiki_link2

proc spidey:wiki_link { nick host hand chan text } {

             foreach word $text {
                if {[string equal $word "of"] || [string equal $word "and"] || [string equal $word "the"] || [string equal $word "a"] || [string equal $word "is"]} {
                        set s $word
                        }  else {
                        set s [string toupper $word 0 0]
                }
                append out "$s "
        }
        set processed [string toupper $out 0 0]   
        set article [string map {" " _} [string trim $processed]]

	# If no article is entered...
	if { $article == "" } {
		# Make it the main page article
		set article "Main_Page"
	}
	# Print link
	putserv "PRIVMSG $chan :\00312\037http://www.blkdragon.com/wiki/index.php?title=$article\037\003 (Requested by \002$nick\002)"
}
proc spidey:wiki_link2 { nick host hand chan text } {
	global discbot
	if {[string equal $nick $discbot]} {
		set data [join [lrange [split $text] 2 end]]
		set discreq [string range [lindex $text 0] 1 end-1]
		# Turn spaces into underscores
        	# Make sure article name starts with upper case letter
		foreach word $data {
		if {[string equal $word "of"] || [string equal $word "and"] || [string equal $word "the"] || [string equal $word "a"] || [string equal $word "is"]} {
   			set s $word
   			}  else {
     			set s [string toupper $word 0 0]
   		}
		append out "$s "
	}
	set processed [string toupper $out 0 0]
	set article [string map {" " _} [string trim $processed]]
        	# If no article is entered...
        	if { $article == "" } {
                	# Make it the main page article
                	set article "Main_Page"
        	}
        	# Print link
        	putserv "PRIVMSG $chan :\00312\037http://www.blkdragon.com/wiki/index.php?title=$article\037\003 (Requested by \002$discreq\002)"
	}
}
# Log the script as successfully loaded.
putlog "Wikipedia Quick Link 1.1 by Hen Asraf, edited for Discord by Freakuancy: Loaded"
