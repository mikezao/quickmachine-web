# Use the official, lightweight Nginx web server image
FROM nginx:alpine

# Copy your website files into the web server's public directory
COPY ./index.html /usr/share/nginx/html/index.html

# Tell Docker that the container will listen on port 80
EXPOSE 80