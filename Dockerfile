FROM ruby:2.4.5

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN mkdir -p /opt/api
WORKDIR /opt/api

COPY Gemfile /opt/api/Gemfile
COPY Gemfile.lock /opt/api/Gemfile.lock

RUN bundle install

COPY . /opt/api
