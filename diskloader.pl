#!/usr/bin/perl

# This script can be used to "bare metal boostrap" a S100 system using the
# Cromemco 4FDC floppy controller, provided that formatted disks are available.
# The image file is written into a track buffer at 0x0200 one track at a time,
# and saved to disk using RDOS's built in disk commands.

use Device::SerialPort qw( :PARAM :STAT 0.07 );
use Time::HiRes qw(usleep);

if ($#ARGV < 1) {
  print "Cromemco 4FDC bare metal disk loader\n(c) 2014 Jonathan Chapman\n\nUSAGE: \n\t./diskloader.pl diskimage.img /dev/ttyS0\n";
  exit -1;
}

# Open the first arg as a binary image
open (FH, '<', $ARGV[0]) or die "Can't open image file " . $ARGV[0] . " for reading!";
binmode(FH);

$/ = \2304;  # 18, 128 byte sectors == 1 track
$count = 0;

# Initialize the serial port, 9600 8/N/1
$port = new Device::SerialPort($ARGV[1]);

if (undef == $port) {
  die "Can't open serial port at " . $ARGV[1] . "!";
}

$port->user_msg(ON); 
$port->baudrate(9600); 
$port->parity("none"); 
$port->databits(8); 
$port->stopbits(1); 
$port->handshake("none"); 
$port->write_settings;
$port->lookclear; 

# Get the monitor ready for bytes
$port->read(255);
$port->write("A;;;\r");
sleep(1);
$port->write("S 0\r");
sleep(1);

print "Writing track ";

while (<FH>) {
  print $count . "...";

  $port->write("SM 0200\r");
  usleep(50000);
  
  # Fill memory with 18 sectors' data
  $sector = unpack('H*', $_);
  @values = unpack("(A2)*", $sector);

  foreach (@values) {
    $port->write($_ . " ");
    $answer=$port->read(255);
    
    if ($answer == /\.$/) {
      usleep(20000);
    } else {
      die "didn't get a confirm";
    }
  }

  $count++;
  
  # Get out of SM and write the track to disk
  $port->write("\r");
  sleep(1);
  $port->write("WD 0200 0AFF 1\r");
  sleep(3);
  $port->write("S " . sprintf("%x",$count) . "\r");
  sleep(1);
}

print "\n\nSent " . $count . " tracks\n";
exit 0;
