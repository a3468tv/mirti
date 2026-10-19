#!/bin/sh
echo "=== PROSTO.TV + LOGO ==="
mkdir -p /app/live/cam1 /app/live/cam3 /app/live/cam4 /app/live/cam5
rm -f /app/live/cam*/*.ts /app/live/cam*/*.m3u8

run_cam() {
  SRC=$1; LOGO=$2; OUT=$3
  while true; do
    if [ -f "$LOGO" ]; then
      ffmpeg -hide_banner -loglevel error \
      -fflags +genpts+discardcorrupt -thread_queue_size 1024 \
      -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 15 -i "$SRC" \
      -i "$LOGO" \
      -filter_complex "[0:v][1:v]overlay=W-w-20:20:eval=frame,scale=1280:720:force_original_aspect_ratio=decrease,setsar=1" \
      -c:v libx264 -preset veryfast -b:v 1500k -g 60 -c:a aac -b:a 128k \
      -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+program_date_time -hls_segment_filename "$OUT/%03d.ts" "$OUT/playlist.m3u8"
    else
      ffmpeg -hide_banner -loglevel error \
      -fflags +genpts+discardcorrupt -thread_queue_size 1024 \
      -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 15 -i "$SRC" \
      -vf "scale=1280:720:force_original_aspect_ratio=decrease" \
      -c:v libx264 -preset veryfast -b:v 1500k -g 60 -c:a aac -b:a 128k \
      -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+program_date_time -hls_segment_filename "$OUT/%03d.ts" "$OUT/playlist.m3u8"
    fi
    echo "restart $OUT"; sleep 3; rm -f $OUT/*.ts $OUT/*.m3u8
  done &
}

# AYNI YAYINI 4 KANALDA - logosu farklı
SRC="http://iptv.prosto.tv:7000/ch331/tracks-v1a1/mono.m3u8"

run_cam "$SRC" "/app/logos/MIRTISPOR_1.png" "/app/live/cam1"
run_cam "$SRC" "/app/logos/MIRTISPOR_2.png" "/app/live/cam3"
run_cam "$SRC" "/app/logos/MIRTISPOR_3.png" "/app/live/cam4"
run_cam "$SRC" "/app/logos/MIRTISPOR_4.png" "/app/live/cam5"

sleep 10
cat > /app/live/index.html <<'HTML'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>MIRTI - PROSTO</title>
<script src="https://cdn.jsdelivr.net/npm/hls.js@1.5.7/dist/hls.min.js"></script>
<style>*{margin:0;padding:0;box-sizing:border-box}body{background:#000;width:100vw;height:100vh;display:grid;grid-template-columns:1fr 1fr;grid-template-rows:1fr 1fr;gap:2px}.box{position:relative;background:#111;overflow:hidden}video{width:100%;height:100%;object-fit:cover}.label{position:absolute;top:0;left:0;background:linear-gradient(90deg,#ff8c00,#2575fc);color:#fff;font:700 14px Arial;padding:5px 10px;z-index:10}</style></head><body>
<div class="box"><div class="label">MIRTISPOR 1</div><video id="v1" controls muted autoplay playsinline></video></div>
<div class="box"><div class="label">MIRTISPOR 2</div><video id="v3" controls muted autoplay playsinline></video></div>
<div class="box"><div class="label">MIRTISPOR 3</div><video id="v4" controls muted autoplay playsinline></video></div>
<div class="box"><div class="label">MIRTISPOR 4</div><video id="v5" controls muted autoplay playsinline></video></div>
<script>
var L=[["v1","/cam1/playlist.m3u8"],["v3","/cam3/playlist.m3u8"],["v4","/cam4/playlist.m3u8"],["v5","/cam5/playlist.m3u8"]];
L.forEach(function(a){var v=document.getElementById(a[0]);if(Hls.isSupported()){var h=new Hls();h.loadSource(a[1]);h.attachMedia(v);}else{v.src=a[1];}});
</script></body></html>
HTML
nginx -g 'daemon off;'
