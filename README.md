# philadelphiaband.com archive scrape

Source snapshot: https://web.archive.org/web/20190902190348/http://philadelphiaband.com/

Run:

```powershell
.\scrape-wayback.ps1
```

Notes:
- The homepage and static assets are saved locally.
- The main page stylesheet references bg.jpg and content-bg.gif, but Wayback did not expose archived captures for those exact paths during this scrape.
- The image gallery was a Flash gallery. Wayback has the HTML, JavaScript, and XML configuration, but its CDX index did not expose the original gallery.swf or gallery image files during this scrape.
- YouTube and PureVolume references remain external historical links.
- Video reference/channel: https://youtube.com/@philadelphiaband?si=bLuJcoprElDefecb
- Rebuilt homepage: index.html now contains a responsive Christian punk rock band website using the recovered archive assets.

