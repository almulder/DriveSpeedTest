# DriveSpeedTest
Script for testing the speed of Raspberry Pi SD Card and or USB

So I am really new to this and unsure how to add this to auto install from a command line or add to a repository for people to download through.

Anyways grab the file 
drivetest.sh and put it in your ./home/pi/RetroPie/retropiemenu
drivetest.png and put it in your ./home/pi/RetroPie/retropiemenu/icons

then add the following to your ./opt/retropie/configs/all/emulationstation/gamelists/retropie/gamelist.xml
```
<game>
    <path>./drivetest.sh</path>
    <name>Drive Speed Test</name>
    <desc>This script test the read speeds of your SD Card and or USB drive
It will run 4 types of test when testing.
  Cached Reads, Buffered Disk Reads
  Direct Cached read, Direct disk reads</desc>
    <image>./icons/drivetest.png</image>
</game>
```
