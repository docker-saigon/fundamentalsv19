<#

Download + Unpack latest coreos Hyper-V & config_base images (Git for windows, using git-bash):

    #! /bin/bash

    curl -Lo /c/VM/coreos_fresh_20151028.vhd.bz2 http://alpha.release.core-os.net/amd64-usr/current/coreos_production_hyperv_image.vhd.bz2
    bzip2 -c -d -k /c/VM/coreos_fresh_20151028.vhd.bz2 > /c/VM/coreos_fresh.vhd

    curl -Lo /d/prj/vm-images/config_base.vhdx.bz2 -z config_base.vhdx.bz2 https://github.com/paulshir/coreos-hyperv/raw/master/files/config2_base.vhdx.bz2
    bzip2 -c -d -k /d/prj/vm-images/config_base.vhdx.bz2 > /d/prj/vm-images/config_base_fresh.vhdx

    cp /d/prj/vm-images/config_base_fresh.vhdx /c/VM/config_base_master.vhdx
    cp /d/prj/vm-images/config_base_fresh.vhdx /c/VM/config_base_node0.vhdx

#>
$switchName = "VMNat" #Hyper-V network to connect the virtual machines to (I'm using VMWare player vmnat.dll)

Remove-VM -Name swarm_master 2> $null
Remove-VM -Name swarm_node0 2> $null

#start machines from fresh image:
Remove-Item C:\VM\coreos_master.vhd 2> $null
Remove-Item C:\VM\coreos_node0.vhd 2> $null

Copy-Item C:\VM\coreos_fresh.vhd C:\VM\coreos_master.vhd
Copy-Item C:\VM\coreos_fresh.vhd C:\VM\coreos_node0.vhd

#MASTER VM
$vhd = Mount-VHD -Path C:\VM\config_base_master.vhdx -ErrorAction:Stop -Passthru | Get-Disk | Get-Partition | Get-VolumeStart-Sleep -s 1if(!(Test-Path "$($vhd.DriveLetter):\openstack\latest")){
    mkdir "$($vhd.DriveLetter):\openstack\latest" | Out-Null} elseif(Test-Path "$($vhd.DriveLetter):\openstack\latest\user_data") 
{
    Remove-Item "$($vhd.DriveLetter):\openstack\latest\user_data" | Out-Null
} 

Copy-Item D:\prj\fundamentals\demo\setup\cloud-init-master.yml "$($vhd.DriveLetter):\openstack\latest\user_data"Dismount-VHD C:\VM\config_base_master.vhdx | Out-Null

New-VM -Name swarm_master -MemoryStartupBytes 1GB -VHDPath C:\VM\coreos_master.vhd -BootDevice VHD -SwitchName $switchName -Verbose
Set-VM -Name swarm_master -StaticMemory
Add-VMHardDiskDrive -VMName swarm_master -ControllerType IDE -ControllerNumber 1 -ControllerLocation 0 -Path C:\VM\config_base_master.vhdx#NODE0 VM$vhd = Mount-VHD -Path C:\VM\config_base_node0.vhdx -ErrorAction:Stop -Passthru | Get-Disk | Get-Partition | Get-VolumeStart-Sleep -s 1if(!(Test-Path "$($vhd.DriveLetter):\openstack\latest")){
    mkdir "$($vhd.DriveLetter):\openstack\latest" | Out-Null} elseif(Test-Path "$($vhd.DriveLetter):\openstack\latest\user_data") 
{
    Remove-Item "$($vhd.DriveLetter):\openstack\latest\user_data" | Out-Null
} 

Copy-Item D:\prj\fundamentals\demo\setup\cloud-init-node0.yml "$($vhd.DriveLetter):\openstack\latest\user_data"Dismount-VHD C:\VM\config_base_node0.vhdx | Out-Null

New-VM -Name swarm_node0 -MemoryStartupBytes 1GB -VHDPath C:\VM\coreos_node0.vhd -BootDevice VHD -SwitchName $switchName -Verbose
Set-VM -Name swarm_node0 -StaticMemory
Add-VMHardDiskDrive -VMName swarm_node0 -ControllerType IDE -ControllerNumber 1 -ControllerLocation 0 -Path C:\VM\config_base_node0.vhdx
