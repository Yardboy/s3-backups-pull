FROM ruby:2.6.5-alpine

LABEL app-name="backups"

RUN apk update && apk add --no-cache curl vim wget bash

# Create and set the working directory
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# COPY app to container
COPY . $APP_HOME

# Add RAILS_ENV for env dependent tasks
ARG RAILS_ENV
ENV RAILS_ENV ${RAILS_ENV}
