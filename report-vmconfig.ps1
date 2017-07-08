$vms = get-view -viewtype VirtualMachine
$arrayofvms = @()
foreach ($vm in $vms){
	$harddiskcounter = 0
	$niccounter = 0
	$scsicounter = 0
	$tempobj = New-Object System.Object
	$tempobj | add-member -name "Name" -membertype NoteProperty -value $vm.Name
	$tempobj | add-member -name "hostname" -membertype NoteProperty -value $vm.guest.hostname
	$tempobj | add-member -name "moref" -membertype NoteProperty -value $vm.moref
	$tempobj | add-member -name "Uuid" -membertype NoteProperty -value $vm.config.Uuid
	$tempobj | add-member -name "InstanceUuid" -membertype NoteProperty -value $vm.config.InstanceUuid
	$tempobj | add-member -name "ChangeVersion" -membertype NoteProperty -value $vm.config.ChangeVersion
	$tempobj | add-member -name "Modified" -membertype NoteProperty -value $vm.config.Modified
	$tempobj | add-member -name "isTemplate" -membertype NoteProperty -value $vm.config.Template
	$tempobj | add-member -name "GuestID" -membertype NoteProperty -value $vm.config.GuestId
	$tempobj | add-member -name "DatastoreURL" -membertype NoteProperty -value $vm.config.datastoreurl
	$tempobj | add-member -name "MemoryHotAddEnabled" -membertype NoteProperty -value $vm.config.MemoryHotAddEnabled
	$tempobj | add-member -name "CPUHotAddEnabled" -membertype NoteProperty -value $vm.config.CPUHotAddEnabled
	$tempobj | add-member -name "CPUHotRemoveEnabled" -membertype NoteProperty -value $vm.config.CPUHotRemoveEnabled
	$tempobj | add-member -name "VMX" -membertype NoteProperty -value $vm.config.files
	$tempobj | add-member -name "toolsversion" -membertype NoteProperty -value $vm.config.tools.toolsversion
	$tempobj | add-member -name "vcpu" -membertype NoteProperty -value $vm.config.hardware.numcpu
	$tempobj | add-member -name "corepersocket" -membertype NoteProperty -value $vm.config.hardware.numcorespersocket
	$tempobj | add-member -name "memorymb" -membertype NoteProperty -value $vm.config.hardware.memorymb
	$tempdevices = $vm.Config.hardware.device
	$tempdisklayout = $vm.layout.disk
	$tempguestnet = $vm.guest.net
	foreach ($net in $tempguestnet){
		foreach ($device in $tempdevices){
			if($device.deviceinfo.label -like "Net*"){
				if ($device.key -eq $net.deviceconfigid){
					#read-host "startif"
					$niccounter ++
					#write-host "NIC counter" $niccounter
					#read-host "preadd"
					$tempobj | add-member -name "nicipaddress$niccounter" -membertype NoteProperty -value $net.ipaddress
					$tempobj | add-member -name "nic$niccounter" -membertype NoteProperty -value $device.deviceinfo.label
					$tempobj | add-member -name "nicmac$niccounter" -membertype NoteProperty -value $device.macaddress
					#write-host $device.label
					#read-host "dev"
					$tempobj | add-member -name "nicsportgroup$niccounter" -membertype NoteProperty -value $device.deviceinfo.summary
					#write-host $device.summary
					#read-host "last"
					#$tempobj | out-gridview
				}
			}
		}
	}
	foreach ($device in $tempdevices){
		if($device.deviceinfo.label -like "SCSI*"){
			$scsicounter ++
			#write-host "SCSI counter" $scsicounter
			$tempobj | add-member -name "scsisharing$scsicounter" -membertype noteproperty -value $device.SharedBus
			$tempobj | add-member -name "scsi$scsicounter"-membertype NoteProperty -value $device.deviceinfo.label
			$tempobj | add-member -name "scsisize$scsicounter" -membertype NoteProperty -value $device.deviceinfo.summary
		}
	}
	foreach ($diskid in $tempdisklayout){
		foreach ($device in $tempdevices){
			if($device.deviceinfo.label -like "Hard*"){
				#write-host "Hard disk counter" $harddiskcounter
				#write-host "Hard disk device key" $device.key
				#write-host "Hard disk disk id key" $diskid.key
				if($device.key -eq $diskid.key){
				$harddiskcounter ++
				#write-host ""
					$tempobj | add-member -name "harddisklocation$harddiskcounter" -membertype NoteProperty -value $diskid.diskfile
					$tempobj | add-member -name "harddisk$harddiskcounter" -membertype NoteProperty -value $device.deviceinfo.label
					$tempobj | add-member -name "harddisksize$harddiskcounter" -membertype NoteProperty -value $device.deviceinfo.summary
				}
			}
		}
	}	
	#$tempobj | add-member -name "devicesummary" -membertype NoteProperty -value $vm.Config.hardware.device.deviceinfo
	$arrayofvms += $tempobj
	}
$arrayofvms | out-gridview
