from python:3.9.16-slim-bullseye

ENV WHATAP_HOME=/whatap
WORKDIR /whatap
#RUN pip install whatap-python
RUN pip3 install -i https://testpypi.python.org/pypi -U whatap-python==0.1.dev516
RUN whatap-setting-config \
--host #.#.#.# \
--license #######-######-####### \
--app_name "DEMO" \
--app_process_name "uvicorn"

RUN echo "profile_basetime=0" >> whatap.conf
RUN echo "stat_domain_enabled=true" >> whatap.conf
RUN echo "trace_user_enabled=true" >> whatap.conf
RUN echo "stat_mtrace_enabled=true" >> whatap.conf
RUN echo "stat_login_enabled=true" >> whatap.conf
RUN echo "stat_referer_enabled=true" >> whatap.conf
RUN echo "query_string_enabled=true" >> whatap.conf
RUN echo "stat_enabled=true" >> whatap.conf
RUN echo "query_string_urls=/" >> whatap.conf
RUN echo "profile_sql_param_enabled=true" >> whatap.conf
RUN echo "query_string_enable=true" >> whatap.conf
RUN echo "profile_http_parameter_enabled=true" >> whatap.conf
RUN echo "trace_user_using_ip=false" >> whatap.conf
RUN echo "profile_http_header_enabled=true" >> whatap.conf

WORKDIR /myapp
ADD ./main.py .
ADD ./requirements.txt .
RUN pip install -r requirements.txt

CMD ["whatap-start-agent", "uvicorn", "main:app", "--host=0.0.0.0", "--port=8000"]
