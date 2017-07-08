$vms = get-view -viewtype VirtualMachine
$vmfolders = get-folder -type VM
$resourcepools = get-resourcepool
$arrayofvms = @()
foreach ($vm in $vms){
	$harddiskcounter = 0
	$niccounter = 0
	$scsicounter = 0
	$tempobj = New-Object System.Object
	$tempobj | add-member -name "Name" -membertype NoteProperty -value $vm.Name
	$tempobj | add-member -name "SDK" -membertype NoteProperty -value $vm.client.serviceurl
	$tempobj | add-member -name "hostname" -membertype NoteProperty -value $vm.guest.hostname
	$tempobj | add-member -name "moref" -membertype NoteProperty -value $vm.moref
	$tempobj | add-member -name "Uuid" -membertype NoteProperty -value $vm.config.Uuid
	$tempobj | add-member -name "InstanceUuid" -membertype NoteProperty -value $vm.config.InstanceUuid
	$tempobj | add-member -name "ChangeVersion" -membertype NoteProperty -value $vm.config.ChangeVersion
	$tempobj | add-member -name "Modified" -membertype NoteProperty -value $vm.config.Modified
	$tempobj | add-member -name "isTemplate" -membertype NoteProperty -value $vm.config.Template
	$tempobj | add-member -name "GuestID" -membertype NoteProperty -value $vm.config.GuestId
	$tempobj | add-member -name "MemoryHotAddEnabled" -membertype NoteProperty -value $vm.config.MemoryHotAddEnabled
	$tempobj | add-member -name "CPUHotAddEnabled" -membertype NoteProperty -value $vm.config.CPUHotAddEnabled
	$tempobj | add-member -name "CPUHotRemoveEnabled" -membertype NoteProperty -value $vm.config.CPUHotRemoveEnabled
	$tempobj | add-member -name "VMXFilepath" -membertype NoteProperty -value $vm.summary.config.vmpathname
	$tempobj | add-member -name "toolsversion" -membertype NoteProperty -value $vm.config.tools.toolsversion
	$tempobj | add-member -name "vcpu" -membertype NoteProperty -value $vm.config.hardware.numcpu
	$tempobj | add-member -name "corepersocket" -membertype NoteProperty -value $vm.config.hardware.numcorespersocket
	$tempobj | add-member -name "memorymb" -membertype NoteProperty -value $vm.config.hardware.memorymb
	$tempobj | add-member -name "powerstate" -membertype NoteProperty -value $vm.summary.runtime.PowerState
	$tempobj | add-member -name "connectionstate" -membertype NoteProperty -value $vm.summary.runtime.connectionstate
	$tempobj | add-member -name "boottime" -membertype NoteProperty -value $vm.summary.runtime.boottime
	$tempobj | add-member -name "consolidationneeded" -membertype NoteProperty -value $vm.summary.runtime.consolidationneeded
	foreach ($folder in $vmfolders){
		if($vm.parent -eq $folder.id){
			$tempobj | add-member -name "vmfolder" -membertype NoteProperty -value $folder.name
		}
	}
	foreach ($resourcepool in $resourcepools){
		if($vm.resourcepool -eq $resourcepool.id){
			$tempobj | add-member -name "resourcepool" -membertype NoteProperty -value $resourcepool.name
			$tempobj | add-member -name "resourcepoolparent" -membertype NoteProperty -value $resourcepool.parent
		}
	}
	$tempdevices = $vm.Config.hardware.device
	$tempdisklayout = $vm.layout.disk
	$tempguestnet = $vm.guest.net
	foreach ($net in $tempguestnet){
		foreach ($device in $tempdevices){
			if($device.deviceinfo.label -like "Net*"){
				if ($device.key -eq $net.deviceconfigid){
					$niccounter ++
					if($net.ipaddress -ne $null){
					$tempobj | add-member -name "nicipaddress$niccounter" -membertype NoteProperty -value $([string]::join(",",$net.ipaddress))
					}else{	
						$tempobj | add-member -name "nicipaddress$niccounter" -membertype NoteProperty -value "null"
					}
					$tempobj | add-member -name "nic$niccounter" -membertype NoteProperty -value $device.deviceinfo.label
					$tempobj | add-member -name "nicmac$niccounter" -membertype NoteProperty -value $device.macaddress
					$tempobj | add-member -name "nicsportgroup$niccounter" -membertype NoteProperty -value $device.deviceinfo.summary
				}
			}
		}
	}
	foreach ($device in $tempdevices){
		if($device.deviceinfo.label -like "SCSI*"){
			$scsicounter ++
			$tempobj | add-member -name "scsisharing$scsicounter" -membertype noteproperty -value $device.SharedBus
			$tempobj | add-member -name "scsi$scsicounter"-membertype NoteProperty -value $device.deviceinfo.label
			$tempobj | add-member -name "scsisize$scsicounter" -membertype NoteProperty -value $device.deviceinfo.summary
		}
	}
	$disksum = 0
	foreach ($diskid in $tempdisklayout){
		foreach ($device in $tempdevices){
			if($device.deviceinfo.label -like "Hard*"){
				if($device.key -eq $diskid.key){
				$harddiskcounter ++
					$tempobj | add-member -name "harddisklocation$harddiskcounter" -membertype NoteProperty -value $([string]::join(",",$diskid.diskfile))
					$tempobj | add-member -name "harddisk$harddiskcounter" -membertype NoteProperty -value $device.deviceinfo.label
					$tempobj | add-member -name "harddisksize$harddiskcounter" -membertype NoteProperty -value $device.deviceinfo.summary
						$disksum = $disksum + [int]$($($device.deviceinfo.summary -replace '[^0-9]')/1024/1024)
				}
			}
		}
	}
	$tempobj | add-member -name "diskprovisionednosnapshotsGB" -membertype NoteProperty -value $disksum
	$arrayofvms += $tempobj
}
$arrayofvms | export-csv report.csv -notype
