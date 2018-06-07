#! /usr/bin/perl -w


###################################### DESCRIPTION ################################################
# This script Remove the dot.1x config from all the ports, then from the switch
# 



################################ PRAGMA Definitions ################################################
#use strict;            # all variables must either be lexically scoped (using "my"), declared beforehand using "our", or explicitly qualified to say which package the global variable is in (using "::").
#use warnings;          # NOTE: This warning detects symbols that have been used only once so $c, @c, %c, *c, &c, sub c{}, c(), and c (the filehandle or format) are considered the same; if a program uses $c only once but also uses any of the others it will not trigger this warning.
#use diagnostics;


################################## PERL Modules ####################################################
use Net::Telnet::Cisco ();
use Time::Local;

print "\n\n\n\n";


################################## INITIALISATION ##################################################
# My Sensitive Data....
#---------------------------------------------------------------------------------------------------
($username,$password) = &getUIDPWD;
$enablepass=$password;
#---------------------------------------------------------------------------------------------------

#******************************** Get the time for reference *****************************************
#-----------------------------------------------------------------------------------------------------
&get_date_time;
#-----------------------------------------------------------------------------------------------------

#******************************** OPENING FILE *******************************************************************************************
#---------------------------------------------------------------------------------------------------
open (LIST, "< etc/List_0.txt") or die "Couldn't open the file with the Node list 0.";
@nodeList = <LIST>;
close (LIST);
#---------------------------------------------------------------------------------------------------
open (RESULTS, "> results/$year-$mon-$day\_results_0.csv");
print RESULTS "Hostname,Model,Status,Port,Config change\n";













#******************************** MAIN PROGRAM *****************************************************
#******************************** MAIN PROGRAM *****************************************************
#******************************** MAIN PROGRAM *****************************************************
#******************************** MAIN PROGRAM *****************************************************

$total = $#nodeList + 1;
print "\nTOTAL Number of ports to process = $total\n";
while (@nodeList) {
        $total = $#nodeList + 1;
        $ping = 'ok';
        #-----------------------------------------------------------------------------------------------
        $temp = $nodeList[0];
        if ($temp =~ /^(.+),(.+)$/) {$hostname = $1;$port = $2} else {die};
        chomp($port = $port);
#       print "HN = $hostname\n";
#       print "PORT = $port\n";
        &PingNode ($hostname);                                                                                                                                                          # $ping = 'ok' or 'nok'
        #-----------------------------------------------------------------------------------------------
        if ($ping eq 'ok') {
#               &Telnet_NODE {$hostname,N,N);
                &login_node ("$hostname");                                                                                                                                              # Login to the node and open a session
                #---------------------------------------------------------------------------------------                Set terminal-length to zero to prevent a stop in the output
                @cmd_output = &ciscoCommand ('terminal exec prompt timestamp','OFF');  # OFF bewirkt das nicht im standartoutput ausgegeben wird
                @cmd_output = &ciscoCommand ('terminal length 0','OFF');
                #--------------------------------------------------------------------------------------- 
                @cmd_output = &ciscoCommand ("sh version | i Model number",'OFF');
                $cmd_output = $cmd_output[0];                                                                                                                                   # Find the model type
                if ($cmd_output =~ /Model number \s+ : (.+)$/) {$model = $1} else {$model = ''};
                #--------------------------------------------------------------------------------------- 
                @cmd_output = &ciscoCommand ("sh version | i System image file is",'OFF');
                $cmd_output = $cmd_output[0];                                                                                                                                   # Find the IOS used
                if ($cmd_output =~ /System image file is (.+)$/) {$software = $1} else {$software = ''};
                #--------------------------------------------------------------------------------------- 
                #--------------------------------------------------------------------------------------- 
                #
                #
                #
                #
                #--------------------------------------------------------------------------------------- 
                #--------------------------------------------------------------------------------------- 
                $nextHostname = $hostname;
                if ($model =~ /WS-C3560-/) {                                                                                                                                    #  --> C3560
                        print "$hostname is a switch type $model\n";
#                       print RESULTS "$hostname is a switch type $model\n";
                        @cmd_output = &ciscoCommand ("conf t",'OFF');
                        #---------------------------------------------------------------------------------------        # Clean-up all the INTERFACE 
                        while ($nextHostname eq $hostname) {
                                @cmd_output = &ciscoCommand ("interface $port",'OFF');
                                @cmd_output = &ciscoCommand ("description User in default VPN",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x port-control auto",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x reauthentication",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x timeout quiet-period",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x timeout server-timeout",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x timeout tx-period",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x timeout supp-timeout",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x max-req",'OFF');
                                #------------------------------------------------------
                                print         "\t$hostname port: $port has been reconfigured without the 802.1x\n";
#                               print RESULTS "$hostname ,port: $port has been reconfigured without the 802.1x\n";
                                print RESULTS "$hostname,$model,alive,$software,$port ,has been reconfigured without the 802.1x parameters\n";
                                #------------------------------------------------------
                                if ($temp = $nodeList[1]) {
                                        if ($temp =~ /^(.+),(.+)$/) {$nextHostname = $1;$port = $2} else {die};
                                        chomp($port = $port);
                                        if ($nextHostname eq $hostname) {shift @nodeList};
                                } else {$nextHostname = 'na'}
                                #------------------------------------------------------
                        }
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no radius-server deadtime",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server retry method reorder",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server retransmit",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server key",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server vsa send authentication",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no radius-server host 10.124.1.11 auth-port 1812 acct-port 1646",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server host 10.124.1.10 auth-port 1812 acct-port 1646",'OFF');
                        #--------------------------------------------------------------------------------------- 
#                       @cmd_output = &ciscoCommand ("no dot1x system-auth-control",'OFF');                                                     # There is a bug on the IOS, and this commands needs to left in place! 
                        @cmd_output = &ciscoCommand ("no aaa authorization network default group radius",'OFF');
                        @cmd_output = &ciscoCommand ("no aaa authentication dot1x default group radius",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("end",'OFF');
                        @cmd_output = &ciscoCommand ("wr",'OFF');
                        print "\t$hostname has been reconfigured without the GLOBAL 802.1x parameters\n";
#                       print RESULTS "$hostname ,has been reconfigured without the GLOBAL 802.1x parameters\n";
                        print RESULTS "$hostname,$model,alive,$software,GLOBAL ,has been reconfigured without the GLOBAL 802.1x parameters\n";
                } 
                elsif (($model =~ /WS-C3560X-/) or ($model =~ /WS-C3560V2-/)){
                        print "$hostname is a switch type $model\n";
#                       print RESULTS "$hostname is a switch type $model\n";
                        @cmd_output = &ciscoCommand ("conf t",'OFF');
                        #---------------------------------------------------------------------------------------        # Clean-up all the INTERFACE 
                        while ($nextHostname eq $hostname) {
                                @cmd_output = &ciscoCommand ("interface $port",'OFF');
                                @cmd_output = &ciscoCommand ("description User in default VPN",'OFF');
                                @cmd_output = &ciscoCommand ("no authentication port-control auto",'OFF');
                                @cmd_output = &ciscoCommand ("no authentication periodic",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x pae authenticator",'OFF');
                                #------------------------------------------------------
                                @cmd_output = &ciscoCommand ("no dot1x timeout quiet-period",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x timeout server-timeout",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x timeout tx-period",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x timeout supp-timeout",'OFF');
                                @cmd_output = &ciscoCommand ("no dot1x max-req",'OFF');
                                #------------------------------------------------------
                                print         "\t$hostname port: $port has been reconfigured without the 802.1x\n";
#                               print RESULTS "$hostname ,port: $port has been reconfigured without the 802.1x\n";
                                print RESULTS "$hostname,$model,alive,$software,$port ,has been reconfigured without the 802.1x parameters\n";
                                #------------------------------------------------------
                                if ($temp = $nodeList[1]) {
                                        if ($temp =~ /^(.+),(.+)$/) {$nextHostname = $1;$port = $2} else {die};
                                        chomp($port = $port);
                                        if ($nextHostname eq $hostname) {shift @nodeList};
                                } else {$nextHostname = 'na'}
                                #------------------------------------------------------
                        }
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no radius-server dead-criteria",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server retry method reorder",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server retransmit",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server key",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server vsa send authentication",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no radius-server host 10.124.1.11 auth-port 1812 acct-port 1646",'OFF');
                        @cmd_output = &ciscoCommand ("no radius-server host 10.124.1.10 auth-port 1812 acct-port 1646",'OFF');
                        #--------------------------------------------------------------------------------------- 
#                       @cmd_output = &ciscoCommand ("no dot1x system-auth-control",'OFF');                                                     # There is a bug on the IOS, and this commands needs to left in place!
                        @cmd_output = &ciscoCommand ("no dot1x critical eapol",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no aaa authorization network default group radius",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no aaa authentication dot1x default group radius",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no logging host 172.17.20.120 discriminator DOT1X",'OFF');
                        @cmd_output = &ciscoCommand ("no logging host 172.17.20.220 discriminator DOT1X",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no logging buffered discriminator DOT1X",'OFF');
                        @cmd_output = &ciscoCommand ("no logging console discriminator DOT1X",'OFF');
                        @cmd_output = &ciscoCommand ("no logging monitor discriminator DOT1X",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("no logging discriminator DOT1X",'OFF');
                        @cmd_output = &ciscoCommand ("no logging discriminator DOT1X facility drops DOT1X|AUTHMGR",'OFF');
                        #--------------------------------------------------------------------------------------- 
                        @cmd_output = &ciscoCommand ("end",'OFF');
                        @cmd_output = &ciscoCommand ("wr",'OFF');
                        print "\t$hostname has been reconfigured without the GLOBAL 802.1x parameters\n";
#                       print RESULTS "$hostname ,has been reconfigured without the GLOBAL 802.1x parameters\n";
                        print RESULTS "$hostname,$model,alive,$software,GLOBAL ,has been reconfigured without the GLOBAL 802.1x parameters\n";

                }
                else {
                }


                #--------------------------------------------------------------------------------------
        } else {
                print "Skipping $hostname because it does not answer to ping! Check your list.";
                print RESULTS "$hostname,NA,dead,NA,$port,none\n"
        }
        #-----------------------------------------------------------------------------------------------
        shift @nodeList;
}
close (RESULTS);
################################## End of Main Program #############################################


























################################## SUB-ROUTINES ###########################################
# =========================================================================================
# SUB-ROUTINE:  &PingNode (hostname)
# -----------------------------------------------------------------------------------------
# Description   : Ping the node host that is past as an argument
#                 
# Value received:  $hostname
# Returned value:  
# Important/Note:   
# ==========================================================================================
sub PingNode {                                                                                                                                                          #
        my $localHostname       = $_[0];                                                                                                                        #
        $ping_cmd = "\/bin\/ping -c1 -W 1 $localHostname";                                                                              # Prepare to execute the ping command in a shell
        $results1 = `$ping_cmd`;                                                                                                                                # Using back-quote to execute a program and send the output to a variable
#       print "$results1\n";
        if (!($results1=~'1 packets transmitted, 1 received')) {$ping = 'nok'}                                  # Ping was not successful 
}



################################## SUB-ROUTINES ###########################################
# =========================================================================================
# SUB-ROUTINE:  &ProcessConfig
# -----------------------------------------------------------------------------------------
# Description   : Take the content of global variable @config and convert it into a C3560CG
#                 config file.
#
# Value received:  
# Returned value:  .
# Important/Note:   
# ==========================================================================================
sub ProcessConfig {                                                                                                                                                     #
        printf "%15s Processing the original config file from the C2940 chassis.\n","";
#       print         "processing $hostname...\n";
        print C3560CG "processing $hostname...\n";
}


################################## SUB-ROUTINES ###########################################
# =========================================================================================
# SUB-ROUTINE:  &yn_question
# -----------------------------------------------------------------------------------------
# Description   : wait for a "Y" or "N" answer from the keyboard and return "true" or "false"
#
# Value received:       NIL
# Returned value:       &yn_question = "true" or "false"
# Important/Note: If CR return is press, then the default value return is "false".
# ==========================================================================================
sub yn_question {                                                                                                                                                       #
        my ($loop1) = "stay";                                                                                                                                   #
        while ($loop1 eq "stay"){                                                                                                                               #
                chomp($input1 = <STDIN>);                                                                                                                       #
                if (($input1 eq 'Y')||($input1 eq 'y')) {                                                                                       #
                        $yn_question = "true";                                                                                                                  #
                        $loop1 = "leave";                                                                                                                               #
                } elsif (($input1 eq 'N')||($input1 eq 'n')){                                                                           #
                        $yn_question = "false";                                                                                                                 #
                        $loop1 = "leave";                                                                                                                               #
                } elsif ($input1 eq ''){                                                                                                                        # If CR is press, then default to "false"
                        $yn_question = "false";                                                                                                                 #
                        $loop1 = "leave";                                                                                                                               #
                } else {                                                                                                                                                        #
                        print STDOUT "\a";                                                                                                                              # Ring the bell when input is wrong
                }                                                                                                                                                                       #
        }                                                                                                                                                                               #
        $yn_question                                                                                                                                                    # Last operation and result will be return
}                                                                                                                                                                                       #
#-------------------------------------------------------------------------------------------------------------------------------------------

# ==========================================================================================
# SUB-ROUTINE:  &get_date_time;
#
# Description:  This subroutine return the time and the date in a formated way
# Output     :  "YYYY-MM-DD_xx:yy:zz"
# ==========================================================================================
sub get_date_time {                                                                                     #
        my $formatedtime;                                                                                                                                               #
        #---------------------------------------------------------------------------------------#
#       ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime(time);                   # Full return value of localtime(time)
        ($sec, $min, $hour, $day, $mon, $year)=localtime(time);                                                                 # Only the value needed for this program
        $year = $year + 1900;                                                                                                                                   # $year start in 1900 and is two digits. So "9" = 1909 and "109" = 2009
        $mon    = $mon + 1;                                                                                                                                             # $mon in PC world are from 0 to 11
                                                                                                                                                                                        # $wday range from 0 (for Sunday) through 6 (for Saturday)
                                                                                                                                                                                        # $yday range from 0 (for Jan 1) through 364 or 365 (for Dec 31)
        $mon = substr "0"x2 . $mon, -2;                                                                                                                 # Pad with 0s to force 2 digit representation
        $day = substr "0"x2 . $day, -2;                                                                                                                 # Pad with 0s to force 2 digit representation
        $hour= substr "0"x2 . $hour,-2;                                                                                                                 # Pad with 0s to force 2 digit representation
        $min = substr "0"x2 . $min, -2;                                                                                                                 # Pad with 0s to force 2 digit representation
        $sec = substr "0"x2 . $sec, -2;                                                                                                                 # Pad with 0s to force 2 digit representation
        #---------------------------------------------------------------------------------------#
        $formatedtime = "$year"."-"."$mon"."-"."$day"."_"."$hour"."h"."$min"."m"."$sec";                #
}                                                                                                                                                                                       #
#-------------------------------------------------------------------------------------------


################################## SUB-ROUTINES ############################################
# ==========================================================================================
# SUB-ROUTINE:  &Telnet_NODE (hostname,Log:Y/N,ExtraBufferY/N,)
#                               &Telnet_NODE {'bn-cep-01',N,N)
# ------------------------------------------------------------------------------------------
# Version       : 2.0 
# Description   : 
# Value received:
# Important/Note: 
# ==========================================================================================
sub Telnet_NODE {                                                                                                                                                       #
        my $node2       = shift @_;                                                                                                                                     #
        my $log         = shift @_;                                                                                                                                     #
        my $mem         = shift @_;                                                                                                                                     #
        #---------------------------------------------------------------------------------------
        if ($log eq 'Y') {
                $logfile = "log/$year-$mon-$day\_$hour"."h"."$min"."m\_$hostname\_log_info.txt";        #
                $session  = Net::Telnet::Cisco->new( Host => $node2, Input_log => $logfile);            # Try to Open TCP Session with log
        }
        else {$session  = Net::Telnet::Cisco->new( Host => $node2)}                                                             # Try to Open TCP Session
        $session ->errmode('return');                                                                                                                   # Configure what to do if there is an "error". In this case "return"
        if (! $session ->open(Host => $node2 ) ) {print "Not able to open connection to $node2!!!\n";die;}                                                                                      # If not succesful, then die
        #---------------------------------------------------------------------------------------
        if ($mem eq 'Y') {
                my $MB = 1024 * 1024;
                $session->max_buffer_length(5 * $MB);                                                                                           # Need more buffer if we display big tables (sh ip route)
        }
        #---------------------------------------------------------------------------------------
        if ($session ->login($username, $password)) {} else {print "Username/Password does not work!!!\n";die;}                                                         # Login Sequence / Omits the Login if no username is asked
        #---------------------------------------------------------------------------------------
        $command = 'terminal length 0';
        my @cmd_output = $session ->cmd( "$command" );                                                                                  # Set terminal-length to zero to prevent a stop in the output
        #---------------------------------------------------------------------------------------
        if ($session ->enable($enablepass))             {} else {print "Cannot go into ENABLE mode!!!\n";die;}                                                          # Go to enable mode
        #---------------------------------------------------------------------------------------
}                                                                                                                                                                                       #
#-------------------------------------------------------------------------------------------

################################## SUB-ROUTINES ###########################################
# =========================================================================================
# SUB-ROUTINE:  &login_node (node,time-out);
#
# description:  Receive a node name and login to this node. Then go into ENABLE mode.
# input value:  node                                                                    = The name of the node to login to
#                                                               time-out                                                = time-out value to use. When not specify the default value of 2 seconds is used
# return value: $vty_session->errmsg    = 
# Note:
# =========================================================================================
sub login_node {                                                                                                #
        my $nodename;                                                                                                                                                           #
        my $time_out;                                                                                                                                                           #
        my $ok;                                                                                                                                                                                             #
        #----------------------------------------------------------------------------------------
        chomp ($nodename = $_[0]);                                                                                                                                      # in case newline had been added
        if ($_[1]) {$time_out = $_[1]} else {$time_out = 10}                                                                            # $arg1 = time-out to wait for.
        #----------------------------------------------------------------------------------------
        $vty_session = Net::Telnet::Cisco->new();                                                                                                       # Try to Open TCP Session
        $vty_session->errmode('return');
        if (! $vty_session->open( Host => $nodename ) ) {
                print     "Opening a telnet session FAILED in PERL\n";
                print     "ERROR MSG: " . $vty_session->errmsg . "\n";
                print     "======================================================================\n";   #
        next;                                                                                                                                                                                               # Get out of the foreach loop to the next node
        }
        #----------------------------------------------------------------------------------------
        if ( $vty_session->login( $username, $password) ) {                                                                                     # Login Sequence / Omits the Login if no username is asked
#               print           "$nodename Login OK\n";
        } else {
                print     "$nodename Login FAILED\n";
                print     "ERROR MSG: " . $vty_session->errmsg ."\n";
                print     "======================================================================\n";   #
                next;                                                                                                                                                                                       # Get out of the foreach loop to the next node
        }
                #----------------------------------------------------------------------------------------
        $nodename = $vty_session->last_prompt;                                                                                                          # Read Hostname from prompt
        chop($nodename);
        #----------------------------------------------------------------------------------------
        if ( $vty_session->enable($enablepass) ) {                                                                                                      # Go to enable modus
#               print     "$hostname Enable mode OK \n";
        } else {
                print     "$nodename Enable mode $_ FAILED\n";
                print     "ERROR MSG: " . $vty_session->errmsg ."\n";
                print     "======================================================================\n";   #
                next;                                                                                                                                                                   # Get out of the foreach loop to the next node
        }
}                                                                                                                                                                                               #
#-------------------------------------------------------------------------------------------------------------------------------------------

# =========================================================================================
# SUB-ROUTINE:  &ciscoCommand (Command,screenLog);
#
# description:  Receive a "cmd" and send this command to the CISCO console. Finish only when there are no errors
# input value:  Command                 = Command to issue to the node
#                                                               screenLog       = ON or OFF, ON means that the LOG are display on screen. OFF means that the LOG are not display on screen
# return value: @cmd_output     = Output of the command in an array
# Note:
# =========================================================================================
sub ciscoCommand {                                                                                                                                                                                          #
        my $cmd = $_[0];
        my $screenlog = $_[1];
#print "THIS IS THE VALUE OF $screenlog AND THE CMD $cmd\n";
        $n = 2;
        @cmd_output = '';                                                                                                                                                                                   # BUG: Sometime it does not get updated and retain the old value.
                                                                                                                                                                                                            # BUG: To avoid this, I empty the variable before.
        @cmd_output = $vty_session->cmd ("$cmd");

        #-------------------------------------------------------------------------------------
        if ($screenlog eq 'ON') {print     "The command was: $cmd \n";}
        #-------------------------------------------------------------------------------------
        while (($vty_session->errmsg) && !($vty_session->errmsg =~ /Invalid input detected at/))  {
                if ($screenlog eq 'ON') {print     "ERROR MSG AFTER LAST COMMAND:\n\t" .$vty_session->errmsg . "\n";}
                if ($screenlog eq 'ON') {print     "CMD_OUTPUT BEGIN\n\t" . "@cmd_output" . "\nCMD_OUTPUT END\n";}
                if ($screenlog eq 'ON') {print     "$hostname >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>SLEEPING $n seconds<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n";}
                #-------------------------------------------------------------------------------------
                sleep($n);
                #-------------------------------------------------------------------------------------
                @cmd_output = $vty_session->cmd ("$cmd");
                if ($screenlog eq 'ON') {print     "The command was: $cmd \n";}
                                                                                                                 print LOG "The command was: $cmd \n";
                #-------------------------------------------------------------------------------------
                if (!($vty_session->errmsg)) {
                        if ($screenlog eq 'ON') {print     "NO MORE ERROR continuing\n";}
                        if ($screenlog eq 'ON') {print     "CMD_OUTPUT BEGIN\n\t" . "@cmd_output" . "\nCMD_OUTPUT END\n";}
                }
                $n +=2;
        }
        return @cmd_output;
}                                                                                                                                                                                                           #
#-------------------------------------------------------------------------------------------------------------------------------------------


# ==========================================================================================
# SUB-ROUTINE:  &chomp2;
#                               &chomp2 {$string);
#
# description:  Check a variable and remove all white space.
# ==========================================================================================
sub chomp2 {                                                                                                                                                            #
        while ($_[0] =~ / /) {                                                                                                                                  # Find a "Return" in it.
                $_[0] = "$`$'";                                                                                                                                         # Remove it.
        }                                                                                                                                                                               #
        return $_[0];                                                                                                                                                   #
}                                                                                                                                                                                       #
#-------------------------------------------------------------------------------------------


# ===========================================================================================
# SUB-ROUTINE:  &getUIDPWD;
#               ($username,$password) = &getUIDPWD;
# input      :  None.
# output     :  UserID of the user that called this script, plus the password to connect to a switch.
# description: 
# ===========================================================================================
sub getUIDPWD {                                                                                                                                                         #
        #----------------------------------------------------------------------------------------
        my $uPwd;
        my $uNumber = getpwuid( $< );
        #----------------------------------------------------------------------------------------
        print STDOUT "\nHello $uNumber, please enter your password to connect to the cisco node(s): ";#
        system('stty','-echo');
        chomp($uPwd=<STDIN>);
        system('stty','echo');
        #----------------------------------------------------------------------------------------
# Test if the pwd is valid
        #----------------------------------------------------------------------------------------
        print STDOUT "\nThanks $uNumber!  Now we start the processing\n\n";                                             #
        print STDOUT "----------------------------------------------------------------------\n";#
        ($uNumber,$uPwd);                                                                               # The return value is a list of 2 scalars
#--------------------------------------------------------------------------------------------




}
__END__;


use Term::ReadKey;
#-----------------------------------------------------------------------------------------
my $key = 0;
my $password = "";
#-----------------------------------------------------------------------------------------
print "\nPlease enter your password: ";                                                                                                 # Start reading the keys
ReadMode(4);                                                                                                                                                    # Disable the control keys
while(ord($key = ReadKey(0)) != 10)                                                                                                             # This will continue until the Enter key is pressed (decimal value of 10)
{                                                                                                                                                                               # For all value of ord($key) see http://www.asciitable.com/
        if(ord($key) == 127 || ord($key) == 8) {                                                                                        # DEL/Backspace was pressed
                chop($password);                                                                                                                                # 1. Remove the last char from the password
                print "\b \b";                                                                                                                                  # 2 move the cursor back by one, print a blank character, move the cursor back by one
        } elsif(ord($key) < 32) {                                                                                                                       # Do nothing with these control characters
        } else {
                $password = $password.$key;
                print "*(".ord($key).")";
        }
}
die;
