param(
    [string]$OutDir = "."
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$items = @(
    @{ Timestamp = "20190902190348"; Original = "http://philadelphiaband.com/"; Local = "index.html" },
    @{ Timestamp = "20110208140923"; Original = "http://philadelphiaband.com/favicon.ico"; Local = "favicon.ico" },
    @{ Timestamp = "20110208140937"; Original = "http://philadelphiaband.com/css/basic.css"; Local = "css/basic.css" },
    @{ Timestamp = "20110208141009"; Original = "http://philadelphiaband.com/css/screen.css?date=11-06-07"; Local = "css/screen.css" },
    @{ Timestamp = "20110208141023"; Original = "http://philadelphiaband.com/css/main.css"; Local = "css/main.css" },
    @{ Timestamp = "20110208140944"; Original = "http://philadelphiaband.com/_images/door_thumb.jpg"; Local = "_images/door_thumb.jpg" },
    @{ Timestamp = "20110208140950"; Original = "http://philadelphiaband.com/_images/guys_thumb.jpg"; Local = "_images/guys_thumb.jpg" },
    @{ Timestamp = "20110208141001"; Original = "http://philadelphiaband.com/_images/pano_thumb.jpg"; Local = "_images/pano_thumb.jpg" },
    @{ Timestamp = "20131029165735"; Original = "http://philadelphiaband.com/downloads/door_1024x768.jpg"; Local = "downloads/door_1024x768.jpg" },
    @{ Timestamp = "20131029171552"; Original = "http://philadelphiaband.com/downloads/door_800x600.jpg"; Local = "downloads/door_800x600.jpg" },
    @{ Timestamp = "20131029171627"; Original = "http://philadelphiaband.com/downloads/guys_1024x768.jpg"; Local = "downloads/guys_1024x768.jpg" },
    @{ Timestamp = "20131029150750"; Original = "http://philadelphiaband.com/downloads/guys_800x600.jpg"; Local = "downloads/guys_800x600.jpg" },
    @{ Timestamp = "20131029144946"; Original = "http://philadelphiaband.com/downloads/pano_1024x768.jpg"; Local = "downloads/pano_1024x768.jpg" },
    @{ Timestamp = "20131029163801"; Original = "http://philadelphiaband.com/downloads/pano_800x600.jpg"; Local = "downloads/pano_800x600.jpg" },
    @{ Timestamp = "20110208140931"; Original = "http://philadelphiaband.com/downloads/punx.gif"; Local = "downloads/punx.gif" },
    @{ Timestamp = "20110208140956"; Original = "http://philadelphiaband.com/downloads/punx1.gif"; Local = "downloads/punx1.gif" },
    @{ Timestamp = "20110208140928"; Original = "http://philadelphiaband.com/downloads/punx2.gif"; Local = "downloads/punx2.gif" },
    @{ Timestamp = "20110208140917"; Original = "http://philadelphiaband.com/ep_cover.jpg"; Local = "ep_cover.jpg" },
    @{ Timestamp = "20110208141015"; Original = "http://philadelphiaband.com/selftitled_cover.jpg"; Local = "selftitled_cover.jpg" },
    @{ Timestamp = "20190215133337"; Original = "http://philadelphiaband.com/logo.jpg"; Local = "logo.jpg" },
    @{ Timestamp = "20080106234432"; Original = "http://philadelphiaband.com/gallery/"; Local = "gallery/index.html" },
    @{ Timestamp = "20131230065400"; Original = "http://philadelphiaband.com/gallery/flashobject.js"; Local = "gallery/flashobject.js" },
    @{ Timestamp = "20080411084609"; Original = "http://philadelphiaband.com/gallery/galleryconfig.xml"; Local = "gallery/galleryconfig.xml" },
    @{ Timestamp = "20080411084615"; Original = "http://philadelphiaband.com/gallery/photos.xml"; Local = "gallery/photos.xml" }
)

function Get-ArchiveUrl($timestamp, $original) {
    "https://web.archive.org/web/${timestamp}id_/$original"
}

foreach ($item in $items) {
    $target = Join-Path $OutDir $item.Local
    $targetDir = Split-Path -Parent $target
    if ($targetDir) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    $archiveUrl = Get-ArchiveUrl $item.Timestamp $item.Original
    Write-Host "Downloading $($item.Local)"
    Invoke-WebRequest -Uri $archiveUrl -UseBasicParsing -OutFile $target
}

$indexPath = Join-Path $OutDir "index.html"
$index = Get-Content -Path $indexPath -Raw
$index = $index.Replace('href="/favicon.ico"', 'href="favicon.ico"')
$index = $index.Replace('href="css/screen.css?date=11-06-07"', 'href="css/screen.css"')
$index = $index.Replace('href="/gallery/"', 'href="gallery/index.html"')
Set-Content -Path $indexPath -Value $index -Encoding Default

$galleryPath = Join-Path $OutDir "gallery/index.html"
$gallery = Get-Content -Path $galleryPath -Raw
$gallery = $gallery.Replace('FlashObject("gallery.swf"', 'FlashObject("https://web.archive.org/web/20080106234432/http://philadelphiaband.com/gallery/gallery.swf"')
Set-Content -Path $galleryPath -Value $gallery -Encoding UTF8

@"
# philadelphiaband.com archive scrape

Source snapshot: https://web.archive.org/web/20190902190348/http://philadelphiaband.com/

Run:

````powershell
.\scrape-wayback.ps1
````

Notes:
- The homepage and static assets are saved locally.
- The main page stylesheet references `bg.jpg` and `content-bg.gif`, but Wayback did not expose archived captures for those exact paths during this scrape.
- The image gallery was a Flash gallery. Wayback has the HTML, JavaScript, and XML configuration, but its CDX index did not expose the original `gallery.swf` or gallery image files during this scrape.
- YouTube and PureVolume references remain external historical links.
- Video reference/channel: https://youtube.com/@philadelphiaband?si=bLuJcoprElDefecb
"@ | Set-Content -Path (Join-Path $OutDir "README.md") -Encoding UTF8


