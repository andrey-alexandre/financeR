FROM rocker/rstudio:3.6.3

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite-dev \
  libmariadbd-dev \
  libmariadbclient-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  libtiff-dev \
  libjpeg-dev \
  &&  install2.r --error \
--deps TRUE \
tidyverse \
lubridate \
readxl \
highcharter \
tidyquant \
timetk \
tibbletime \
quantmod \
PerformanceAnalytics \
scales

