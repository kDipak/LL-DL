if (Get-Module -ListAvailable -Name Communary.PASM) {
    Write-Host "Module exists"
     } 
else {
     Install-Module Communary.PASM
     }
Import-Module Communary.PASM
cls
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$usr  = Get-Content -Path "D:\Download\Youtubedl\un.txt"
$pwd  = Get-Content -Path "D:\Download\Youtubedl\pw.txt" | ConvertTo-SecureString -asPlainText -Force
$pwdp = Get-Content -Path "D:\Download\Youtubedl\pw.txt"
$cred = New-Object System.Management.Automation.PSCredential($usr,$pwd)
$url  = Get-content -Path "D:\Download\Youtubedl\dlthis.txt"
$ytdl = "D:\Download\Youtubedl"
$start = $url | ForEach-Object {
    write-host "processing url" $_
    $n = 0 
    $connect = Invoke-WebRequest -Uri $_ -Credential $cred
    $L1 = $connect.Links.Href
    $L2 = @($L1) -ilike "*?autoplay=true&amp;trk=course_tocItem"
    $L3 = $L2 | ForEach-Object { $_ -replace "\?autoplay=true&amp;trk=course_tocItem","" }
    $RawTitle =$connect.ParsedHtml | Select nameprop |  ForEach-Object { $_ -replace "\.","-" -replace "\(" ,"" -replace "\)" ,"" -replace "#:" ,"-sharp" -replace "#"  , "-sharp" -replace "  " ,"-" -replace ":"  , "" -replace " "  , "-" -replace ","  , "" -replace "@{nameProp=", "" -replace "}", ""}
    $folder = $connect.ParsedHtml | Select nameprop | ForEach-Object { $_  -replace "  ","" -replace ":", "" -replace "@{nameProp=", "" -replace "}", ""}
    $dl = $L3 |  Select-FuzzyString $RawTitle | Select Result | 
    ForEach-Object {
    cd $ytdl; $i = 1 + $n 
    $i | foreach {
                 $ii = "{0:00}" -f $_
                 }
    $path = $ytdl+'\'+$folder
    If(!(test-path $path))
    {
    New-Item -ItemType Directory -Force -Path $path
    }
    cd $path
    $vbeg = $_.Result.LastIndexOf('/')+1
    $filepart = $_.Result.Substring($vbeg)
    $filename = "$($ii) $($filepart).mp4"
    $filedir = (Get-Item -Path ".\").FullName
    $filepath = Join-Path $filedir $filename
If(!(test-path $filepath))
     {
      Write-Host 'Downloading = ' $_ "to file" $filename -ForegroundColor Green
      ..\youtube-dl.exe -f best $_.Result  -o $filename --print-traffic --cookies ..\cookie.txt | Out-Host
     } 
else {
     Write-Host 'File:' $filename 'already exists' -ForegroundColor Yellow 
   }
  $n = $i ++
 }
}
