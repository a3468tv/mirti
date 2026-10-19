FROM nginx:alpine
RUN apk add --no-cache ffmpeg
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /app/start.sh
COPY logos /app/logos
RUN chmod +x /app/start.sh
CMD ["/app/start.sh"]
