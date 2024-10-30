FROM ruby:3.3.0

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -\
  && apt-get update -qq && apt-get install -qq --no-install-recommends \
    nodejs curl libvips postgresql-client \
  && apt-get upgrade -qq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*\
  && npm install -g yarn@1

WORKDIR /rails
COPY .ruby-version /rails/.ruby-version
COPY Gemfile /rails/Gemfile
COPY Gemfile.lock /rails/Gemfile.lock

RUN bundle install
RUN yarn install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
