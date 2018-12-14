#Remove-Variable * -ErrorAction SilentlyContinue
#Import-Module Communary.PASM #Fuzzy Logic Search module
cls
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#your LinkedIN username
$usr  = ""

# LinkedIn Password in a text file, change path.
$pwd  = Get-Content -Path "D:\Download\Youtubedl\pw.txt" | ConvertTo-SecureString -asPlainText -Force

#LinkedIn Password used in Youtube-dl
$pwdp = Get-Content -Path "D:\Download\Youtubedl\pw.txt"
$cred = New-Object System.Management.Automation.PSCredential($usr,$pwd)

# path to course, going to change thos so it reads the uri from a text file.
$uri  = "https://www.linkedin.com/learning/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

#Location of youtube-dl binaries
$ytdl = 'D:\Download\Youtubedl'

# Get all links on the course page
$connect = Invoke-WebRequest -Uri $uri -Credential $cred
$Links = $connect.Links.Href
$Links = $Links 
$Links = @($Links) -inotlike '*Login*' -inotlike '*course_preview*' -ilike 'https*'
$Links = $Links | ForEach-Object {
$_ -replace "\?autoplay=true&amp;trk=course_tocItem","" 
}

#Get the Page title and prepare it for fuzzymatching the URL
$connect.Content -match "<title>(?<title>.*)</title>" | out-null
$RawTitle = $matches['title']
$Clean = $RawTitle | ForEach-Object {
$_  -replace "# ", "-sharp-" -replace "  ","-" -replace ":", "" -replace " ", "-" -replace ",", ""}

#Fuzze Match url to page title.

$S1 = $links | Select-FuzzyString $Clean | Sort-Object Score,Result -Descending | Select Result

#Start Downloading
$dl = $S1 | ForEach-Object {
cd $ytdl;
Write-Host 'Getting: ' $_.Result
.\youtube-dl.exe -f best $_.Result  -u $usr -p $pwdp
}
