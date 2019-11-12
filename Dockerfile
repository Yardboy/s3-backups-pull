FROM ruby:2.6.5

LABEL app-name="backups"

RUN apt-get update -qq && apt-get install -y \
  curl \
  vim

# Create and set the working directory
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# COPY app to container
COPY . $APP_HOME

# Add RAILS_ENV for env dependent tasks
ARG RAILS_ENV
ENV RAILS_ENV ${RAILS_ENV}
