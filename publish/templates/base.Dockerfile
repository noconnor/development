FROM BASE_BOX

ADD bootstrap.sh /tmp
RUN chmod +x /tmp/bootstrap.sh
RUN /tmp/bootstrap.sh
RUN rm /tmp/bootstrap.sh
