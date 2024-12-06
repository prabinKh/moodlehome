FROM nginx:latest

# Create nginx cache directories with proper permissions
RUN mkdir -p /var/cache/nginx && \
    mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx && \
    chmod -R 755 /var/cache/nginx

# Create necessary directories and set permissions
RUN mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chmod -R 755 /var/log/nginx && \
    mkdir -p /var/run && \
    chown -R nginx:nginx /var/run

# Remove default nginx pid file location
RUN rm -rf /var/run/nginx.pid

# Create custom pid directory
RUN mkdir -p /tmp/nginx && \
    chown -R nginx:nginx /tmp/nginx && \
    chmod -R 755 /tmp/nginx

# Set proper permissions for nginx directories
RUN chown -R nginx:nginx /etc/nginx && \
    chmod -R 755 /etc/nginx

# Add default command
CMD ["nginx", "-g", "daemon off;"]
