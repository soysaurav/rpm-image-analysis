Add-Type -AssemblyName System.Drawing

$src = (Get-Item Phone).FullName
$dst = "$src`_Renamed"
mkdir $dst -ea 0 | Out-Null

Get-ChildItem $src -Filter *.jpg | ForEach-Object {
    $img = [System.Drawing.Image]::FromFile($_.FullName)

    if ($img.PropertyIdList -contains 0x9003) {
        $raw = $img.GetPropertyItem(0x9003).Value
        $text = ([Text.Encoding]::ASCII.GetString($raw)).Trim([char]0)
        $dt = [datetime]::ParseExact($text,'yyyy:MM:dd HH:mm:ss',$null)

        Copy-Item $_.FullName "$dst\$($dt.ToString('yyyyMMdd HHmmss')).jpg"
    }

    $img.Dispose()
}