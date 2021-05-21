from ubuntu

ADD ./entrypoint.sh /whatap/entrypoint.sh
ADD ./whatap /usr/whatap 
RUN chmod +x /whatap/entrypoint.sh
RUN chmod +x /usr/whatap/infra/whatap_infrad
ENV WHATAP_HOME /whatap_conf
ENTRYPOINT ["/whatap/entrypoint.sh"]