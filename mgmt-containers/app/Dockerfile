FROM python:latest
LABEL Maintainer="k.reynolds@f5.com"

WORKDIR /usr/app/src
COPY *.py ./
RUN pip install -r requirements.txt

CMD [ "python", "./job.py"]