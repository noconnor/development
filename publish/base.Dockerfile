FROM BASE_BOX

ADD ./bootstrap.sh /
RUN chmod +x /bootstrap.sh
RUN /bootstart.sh
RUN rm /bootstart.sh
