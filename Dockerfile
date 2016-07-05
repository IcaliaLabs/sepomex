FROM ruby:2.2.3
MAINTAINER Abraham Kuri <kurenn@icalialabs.com>

ENV PATH=/usr/src/app/bin:$PATH RACK_ENV=production

ADD . /usr/src/app
ADD ./Gemfile* /usr/src/app/
WORKDIR /usr/src/app

RUN bundle install --deployment --without development test

CMD ["rackup", "-p", "3000", "--host", "0.0.0.0"]
