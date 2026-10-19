FROM nginx:alpine
RUN apk add --no-cache ffmpeg
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /app/start.sh
RUN mkdir -p /app/logos /app/live && chmod +x /app/start.sh
EXPOSE 8080
CMD ["/app/start.sh"]
