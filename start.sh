#!/bin/sh
echo "=== 4LU + SOMINE + LOGO ==="
mkdir -p /app/live/cam1 /app/live/cam3 /app/live/cam4 /app/live/cam5 /app/logos
rm -rf /app/live/cam2 /app/live/cam6
rm -f /app/live/cam*/*.ts /app/live/cam*/*.m3u8

# LOGOLARI /app/logos içine at
# MIRTISPOR_1.png -> cam1, MIRTISPOR_2.png -> cam3 vs.

run_cam() {
  NAME=$1; CAM_URL=$2; FIRE_URL=$3; LOGO=$4; OUT=$5
  while true; do
    ffmpeg -hide_banner -loglevel error \
    -fflags +genpts+discardcorrupt -use_wallclock_as_timestamps 1 -thread_queue_size 1024 \
    -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 10 -i "$CAM_URL" \
    -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 10 -stream_loop -1 -i "$FIRE_URL" \
    -i "$LOGO" \
    -filter_complex "[0:v][2:v]overlay=W-w-20:20:eval=frame[logo];[logo]scale=1280:720:force_original_aspect_ratio=decrease[vid]" \
    -map "[vid]" -map 1:a:0 \
    -c:v libx264 -preset veryfast -b:v 1500k -maxrate 2000k -g 60 \
    -c:a aac -b:a 64k -ar 44100 -ac 2 \
    -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+program_date_time+independent_segments -hls_segment_filename "$OUT/%03d.ts" "$OUT/playlist.m3u8"
    sleep 3; rm -f $OUT/*.ts $OUT/*.m3u8
  done &
}

# 4 ADET ŞÖMİNE YAYINI - telifsiz loop
FIRE1="https://cdn.pixabay.com/video/2020/11/22/57346-483578643_large.mp4"
FIRE2="https://cdn.pixabay.com/video/2022/12/11/142732-780678359_large.mp4"
FIRE3="https://cdn.pixabay.com/video/2021/02/12/63578-508699458_large.mp4"
FIRE4="https://cdn.pixabay.com/video/2020/12/04/58272-487346511_large.mp4"

run_cam "CAM1" "https://kamerayayin.ibb.istanbul/turistikcam/ulusparki.stream/playlist.m3u8" "$FIRE1" "/app/logos/MIRTISPOR_1.png" "/app/live/cam1"
run_cam "CAM3" "https://kamerayayin.ibb.istanbul/turistikcam/sarachane.stream/playlist.m3u8" "$FIRE2" "/app/logos/MIRTISPOR_2.png" "/app/live/cam3"
run_cam "CAM4" "https://kamerayayin.ibb.istanbul/turistikcam/taksim.stream/playlist.m3u8" "$FIRE3" "/app/logos/MIRTISPOR_3.png" "/app/live/cam4"
run_cam "CAM5" "https://kamerayayin.ibb.istanbul/turistikcam/pierreloti.stream/playlist.m3u8" "$FIRE4" "/app/logos/MIRTISPOR_4.png" "/app/live/cam5"

sleep 10
cat > /app/live/index.html <<'HTML'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>MIRTISPOR - 4 Ekran + Şömine</title>
<script src="https://cdn.jsdelivr.net/npm/hls.js@1.5.7/dist/hls.min.js"></script>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#000;width:100vw;height:100vh;overflow:hidden;display:grid;grid-template-columns:1fr 1fr;grid-template-rows:1fr 1fr;gap:2px}
.box{position:relative;background:#111;overflow:hidden}
video{width:100%;height:100%;object-fit:cover}
.label{position:absolute;top:0;left:0;background:linear-gradient(90deg,#ff8c00,#2575fc);color:#fff;font:700 14px Arial;padding:5px 10px;z-index:10;border-radius:0 0 10px 0}
.url{position:absolute;bottom:0;left:0;right:0;background:rgba(0,0,0,0.7);color:#0f0;font:11px monospace;padding:4px;z-index:10}
</style></head><body>
<div class="box"><div class="label">MIRTISPOR 1 - Ulus Parkı + Şömine</div><div class="url">/cam1/playlist.m3u8</div><video id="v1" controls muted autoplay playsinline></video></div>
<div class="box"><div class="label">MIRTISPOR 2 - Saraçhane + Şömine</div><div class="url">/cam3/playlist.m3u8</div><video id="v3" controls muted autoplay playsinline></video></div>
<div class="box"><div class="label">MIRTISPOR 3 - Taksim + Şömine</div><div class="url">/cam4/playlist.m3u8</div><video id="v4" controls muted autoplay playsinline></video></div>
<div class="box"><div class="label">MIRTISPOR 4 - Pierre Loti + Şömine</div><div class="url">/cam5/playlist.m3u8</div><video id="v5" controls muted autoplay playsinline></video></div>
<script>
var L=[["v1","/cam1/playlist.m3u8"],["v3","/cam3/playlist.m3u8"],["v4","/cam4/playlist.m3u8"],["v5","/cam5/playlist.m3u8"]];
L.forEach(function(a){
  var v=document.getElementById(a[0]);
  if(Hls.isSupported()){
    var h=new Hls({maxBufferLength:30,liveSyncDuration:5});
    h.loadSource(a[1]); h.attachMedia(v);
  } else { v.src=a[1]; }
});
</script></body></html>
HTML
nginx -g 'daemon off;'
