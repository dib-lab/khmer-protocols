FROM kp-base

### tag block at 2-diginorm.rst:19

RUN pip install -U setuptools && pip install -U khmer==2.0
COPY 2-diginorm.rst.sh /home
ENTRYPOINT ["/home/2-diginorm.rst.sh"]
