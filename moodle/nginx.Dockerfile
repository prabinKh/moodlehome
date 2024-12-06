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

# Remove default nginx pid file location
RUN rm -rf /var/run/nginx.pid

# Create custom pid directory
RUN mkdir -p /tmp/nginx && \
    chown -R nginx:nginx /tmp/nginx && \
    chmod -R 755 /tmp/nginx

# Update nginx configuration to use the new pid location
RUN echo "pid /tmp/nginx/nginx.pid;" > /etc/nginx/nginx.conf.new && \
    cat /etc/nginx/nginx.conf >> /etc/nginx/nginx.conf.new && \
    mv /etc/nginx/nginx.conf.new /etc/nginx/nginx.conf

USER nginx 
