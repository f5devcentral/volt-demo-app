FROM nginxinc/nginx-unprivileged:latest

#RUN rm /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/conf.d/default.conf
COPY default.conf.template /etc/nginx/templates/default.conf.template

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]