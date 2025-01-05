# Linux NexusMods Download Switcher

LNDS is a way to quickly switch between Mod Organizer 2 instances on Linux. Primarily created for handling multiple Wabbajack lists, this can be used for any MO2 installation.

This guide assumes you have followed either [Omni's Wabbajack Guides](https://github.com/Omni-guides/Wabbajack-Modlist-Linux) or installed MO2 with [Mod Organizer 2 Linux Installer](https://github.com/rockerbacon/modorganizer2-linux-installer) or Steam Tinker Launch. Any other MO2 installations should work assuming you use Steam or Proton.

## Installing:

Requires [jq](https://jqlang.github.io/jq/download/)

Download the repository and extract anywhere. Set both .sh files as executables (sudo chmod 755 [file].sh or right-click>properties>permissions>Allow executing).  
Run Wabbajack-NXM-Switcher.sh in terminal and follow the instructions to install. Note that all four files must be in the same folder when installing.  
You can ignore most Mime errors, only ones mentioning Wabbajack matter.  

Once installation is complete you can move and run this script anywhere or use your application launcher to search Wabbajack NXM Switcher.

## Uninstalling:

Run Wabbajack-NXM-Switcher.sh or the .desktop shortcut and select Uninstall. It will prompt you if you want to remove all saved files; files are moved to the trash. It will also restore any previous method you had for handling downloads (only supports Steam Tinker Launch and Linux MO2 Installer).

## Usage:

Start by Adding your Wabbajack/MO2 instances. Once they're setup you can Switch between them.

### Add
**Name** can be anything.   
**Game** must be whats in the Nexus url. E.g: nexusmods.com/**skyrimspecialedition**/mods/1"  
**AppID** can be found by launching protontricks --gui and finding the number next to the name of the instance you're trying to launch. This could be the base game or a non-Steam game depending on which installation method you used.  
**Path** is the location of your MO2 folder, where you can find ModOrganizer.exe and other files. **It must not have a trailing slash /**.

### Switch
Displays all MO2 instances, which are active, and which game they're active for. Enter the number of the instance you want to switch to.  

### Remove
Similar to Switch it displays all instances and lets you choose a number to remove. Afterward you must Switch to a new instance, it does not automatically select a new instance for the same game.

## Requested Features:
These are features that I would like to see added but lack the time or skill to do myself. Help implementing them would be appreciated.

**Improved JSON Input Handling -** Currently certain bad inputs can result in your entire Switcher.json being deleted.  
**Automatic JSON Backups -** In addition to the above changes, it would be great to have automatic backups after some amount of actions.  
**Automatic Instance Switching -** It would be fantastic if the user doesn't need to switch at all, and launching MO2 automatically changes the active instance.  
**Proper Installer -** An actual single file installer that doesn't require the user to keep four files in the same place would be neat.

## Troubleshooting:
Your browser should automatically detect the new method for handling nxm downloads, however you can check this by going to:   
**Firefox:** Settings > Scroll down to Applications > Look for nxm. It should show Use Wabbajack NXM Handler (Default)  
**Chromium:** I'm not sure. Probably under Settings > Privacy and security > Pop-ups and redirects.  

Check ~/.local/share/wabbajack/Handler.log for errors.
Check ~/.local/share/wabbajack/Switcher.json for incorrect names/paths in your instances.
