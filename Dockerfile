# I: Runtime Stage: ============================================================
# This is the stage where we build the runtime base image, which is used as the
# common ancestor by the rest of the stages, and contains the minimal runtime
# dependencies required for the application to run:

# Step 1: Use the official Ruby 2.7.1 Slim Buster image as
# base:
FROM ruby:2.7.1-slim-buster AS runtime

# Step 2: We'll set the MALLOC_ARENA_MAX for optimization purposes & prevent memory bloat
# https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html
ENV MALLOC_ARENA_MAX="2"

# Step 3: We'll set the LANG encoding to be UTF-8 for special characters support
ENV LANG C.UTF-8

# Step 4: We'll install curl for later dependencies installations
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl

# Step 5: Add nodejs source
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Step 7: Install the common runtime dependencies:
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https software-properties-common \
    ca-certificates \
    libpq5 \
    openssl \
    nodejs \
    tzdata && \
    rm -rf /var/lib/apt/lists/*

# Step 8: Add Dockerize image
RUN export DOCKERIZE_VERSION=v0.6.1 && curl -L \
    https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar -C /usr/local/bin -xz

# II: Development Stage: =======================================================
# In this stage we'll build the image used for development, including compilers,
# and development libraries. This is also a first step for building a releasable
# Docker image:

# Step 9: Start off from the "runtime" stage:
FROM runtime AS development

# Step 10: Set the default command:
CMD [ "rails", "server", "-b", "0.0.0.0" ]

# Step 11: Install the development dependency packages with alpine package
# manager:
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    chromium \
    chromium-driver \
    git \
    graphviz \
    libpq-dev \
    net-tools \
    # Install sudo to step-up as root ON DEVELOPMENT STAGE ONLY!
    sudo \
 && rm -rf /var/lib/apt/lists/*

# Step 12: Build the su-exec executable - used to step-down from root on final
# image. This might actually be a runtime requirement, but since we need to
# build it, and maybe have it available at development time to test our scripts,
# it's built in this stage. We'll copy it into the final image in the release
# stage:
RUN curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c \
 && gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec \
 && chown root:root /usr/local/bin/su-exec \
 && chmod 0755 /usr/local/bin/su-exec \
 && rm /usr/local/bin/su-exec.c

# Step 13: Install the 'check-dependencies' node package:
RUN npm install -g check-dependencies

# Step 14: Receive the developer user's UID - typically 1000:
ARG DEVELOPER_UID=1000

# Step 15: Receive the developer user's GID - typically the same as the UID:
ARG DEVELOPER_GID=1000

# Step 16: Receive the developer user's username:
ARG DEVELOPER_USERNAME=you

# Step 17: Set the developer's UID as an environment variable:
ENV DEVELOPER_UID=${DEVELOPER_UID} \
    DEVELOPER_GID=${DEVELOPER_GID} \
    DEVELOPER_USERNAME=${DEVELOPER_USERNAME}

# Step 18: Create the developer group and user:
RUN addgroup --gid ${DEVELOPER_GID} ${DEVELOPER_USERNAME} \
 ; useradd -r -m -u ${DEVELOPER_UID} --gid ${DEVELOPER_GID} -d /code \
   -c "Developer User,,," ${DEVELOPER_USERNAME}

# Step 19: Add the developer user to the sudoers list:
RUN echo "${DEVELOPER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/${DEVELOPER_USERNAME}"

# Step 20: Create the `/usr/src` folder, and change set the developer user as
# it's owner:
RUN mkdir -p /usr/src && chown -R ${DEVELOPER_UID}:${DEVELOPER_GID} /usr/src

# Step 21: Change to the developer user:
USER ${DEVELOPER_USERNAME}

# Step 22: Set the current working dir to `/usr/src` - we'll actually override
# this on the docker-compose files:
WORKDIR /usr/src

# Step 23: Copy the project's Gemfile + lock:
COPY Gemfile* /usr/src/

# Step 24: Install the current project gems - they can be safely changed later
# during development via `bundle install` or `bundle update`:
RUN bundle install --jobs=4 --retry=3

# III: Testing stage: ==========================================================
# In this stage we'll add the current code from the project's source, so we can
# run tests with the code.

# Step 27: Start off from the development stage image:
FROM development AS testing

# Step 28: Copy the rest of the application code
COPY . /usr/src

# Step 29: Add the /usr/src/bin directory to $PATH:
ENV PATH=/usr/src/bin:$PATH DEBIAN_FRONTEND=noninteractive

# IV: Builder stage: ===========================================================
# In this stage we'll compile assets coming from the project's source, do some
# tests and cleanup. If the CI/CD that builds this image allows it, we should
# also run the app test suites here:

# Step 30: Start off from the development stage image:
FROM testing AS builder

# Step 31: Precompile assets:
RUN export DATABASE_URL=postgres://postgres@example.com:5432/fakedb \
    SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece \
    RAILS_ENV=production && \
    rails assets:precompile && \
    rails webpacker:compile && \
    rails secret > /dev/null

# Step 32: Remove installed gems that belong to the development & test groups -
# we'll copy the remaining system gems into the deployable image on the next
# stage:
RUN bundle config without development:test && bundle clean --force

# Step 33: Remove files not used on release image:
RUN rm -rf \
    .rspec \
    Guardfile \
    bin/rspec \
    bin/checkdb \
    bin/dumpdb \
    bin/restoredb \
    bin/setup \
    bin/spring \
    bin/update \
    bin/dev-entrypoint.sh \
    config/spring.rb \
    node_modules \
    spec \
    config/initializers/listen_patch.rb \
    tmp/*

# V: Release stage: ============================================================
# In this stage, we build the final, deployable Docker image, which will be
# smaller than the images generated on previous stages:

# Step 34: Start off from the runtime stage image:
FROM runtime AS release

# Step 35: Copy the remaining installed gems from the "builder" stage:
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Step 36: Copy the `su-exec` command, which may be needed if you require the
# production container to start as root and then step down to an unprivileged
# user:
COPY --from=builder /usr/local/bin/su-exec /usr/local/bin/su-exec

# Step 37: Copy the app code and compiled assets from the "builder" stage to the
# final destination at /srv/sepomex:
COPY --from=builder --chown=nobody:nogroup /usr/src /srv/sepomex

# Step 38: Set the container user to 'nobody':
USER nobody

# Step 39: Set the RAILS/RACK_ENV and PORT default values:
ENV PATH=/srv/sepomex/bin:$PATH RAILS_ENV=production RACK_ENV=production PORT=3000 DEBIAN_FRONTEND=dialog

# Step 40: Generate the temporary directories in case they don't already exist:
RUN mkdir -p /srv/sepomex/tmp \
 && cd /srv/sepomex/tmp \
 && mkdir -p cache pids sockets storage

# Step 41: Set the default command:
CMD [ "puma" ]

# Step 42 thru 46: Add label-schema.org labels to identify the build info:
ARG SOURCE_BRANCH="master"
ARG SOURCE_COMMIT="000000"
ARG BUILD_DATE="2017-09-26T16:13:26Z"
ARG IMAGE_NAME="sepomex:latest"

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Sepomex" \
      org.label-schema.description="Sepomex" \
      org.label-schema.vcs-url="https://github.com/IcaliaLabs/sepomex.git" \
      org.label-schema.vcs-ref=$SOURCE_COMMIT \
      org.label-schema.schema-version="1.0.0-rc1" \
      build-target="release" \
      build-branch=$SOURCE_BRANCH
