FROM registry.redhat.io/rhel8/httpd-24

USER 0
RUN dnf install -y mod_security_crs mod_security
ADD demo-data /var/www/html/

USER 1001
CMD run-httpd
