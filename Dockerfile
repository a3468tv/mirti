FROM nginx:alpine
RUN apk add --no-cache ffmpeg dos2unix
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /app/start.sh
RUN dos2unix /app/start.sh && mkdir -p /app/logos /app/live && chmod +x /app/start.sh
EXPOSE 8080
ENTRYPOINT []
CMD ["/app/start.sh"]
