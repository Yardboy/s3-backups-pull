#################################
# stage: install system         #
#################################
FROM ruby:2.6.5-alpine as build
ENV APPNAME s3pullbackups

LABEL app-name=${APPNAME}

# Set the build args and env vars for this stage
ENV APPHOME /$APPNAME
ENV LANG C.UTF-8
ENV BUNDLE_PATH /$APPNAME/vendor/bundle

RUN apk add --update --no-cache curl vim wget bash bash-completion git\
    && rm -rf /var/cache/apk/*

# Set the working directory (auto-create)
WORKDIR $APPHOME

# Install ruby dependencies
COPY Gemfile* $APPHOME/
RUN echo 'gem: --no-document' > ~/.gemrc \
    && bundle install

# COPY app to container
COPY . $APPHOME

#################################
# stage: runtime environment    #
#################################
FROM build AS runtime
ENV APPNAME s3pullbackups

# Set the build args and env vars for this stage
ENV APPHOME /$APPNAME
ENV LANG C.UTF-8

ARG APPUID=1000
ARG APPGID=1000

# Set the working directory
WORKDIR $APPHOME

# Create application user
RUN addgroup --system --gid $APPGID $APPNAME \
    && adduser --system --uid $APPUID --ingroup $APPNAME $APPNAME \
    && echo 'IRB.conf[:USE_MULTILINE] = false' > /home/$APPNAME/.irbrc \
    && echo 'gem: --no-document' > ~/.gemrc

# COPY app to container
COPY --chown=$APPNAME:$APPNAME --from=build $APPHOME $APPHOME

# As appuser for rest of build
USER $APPNAME

# Add RAILS_ENV for env dependent tasks
#ARG RAILS_ENV
#ENV RAILS_ENV ${RAILS_ENV}

CMD [ "bundle", "exec", "./s3_pullbackups.rb" ]
