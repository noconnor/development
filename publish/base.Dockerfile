FROM BASE_BOX

ADD bootstrap.sh /tmp
RUN chmod +x /tmp/bootstrap.sh
RUN /tmp/bootstart.sh
RUN rm /tmp/bootstart.sh
