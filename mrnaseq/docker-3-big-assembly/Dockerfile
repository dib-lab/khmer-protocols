FROM kp-base

### tag block at 3-big-assembly.rst:4

RUN apt-get -y install wget
RUN pip install -U setuptools && pip install -U khmer==2.0
COPY 3-big-assembly.rst.sh /home
ENTRYPOINT ["/home/3-big-assembly.rst.sh"]
