[reflection.assembly]::loadwithpartialname("System.Windows.Forms")
[reflection.assembly]::loadwithpartialname("System.Drawing")
$notify = new-object system.windows.forms.notifyicon
$notify.icon = [System.Drawing.SystemIcons]::Warning
$notify.visible = $true
$notify.showballoontip(5,"Warning: Battery running low!","You will be logged out in 5 minutes",[system.windows.forms.tooltipicon]::None)
