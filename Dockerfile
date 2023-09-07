FROM node:20.5.1
FROM ruby:3.2.2

ENV TZ Aisa/Tokyo
ENV RAILS_ENV production
ENV BUNDLE_WITHOUT development:test
ENV BUNDLE_DEPLOYMENT true
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

RUN mkdir /app
WORKDIR /app

# node関連をコピー
COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx \
  && ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -fs /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

RUN apt-get update -qq \
  && apt-get install -y postgresql-client

RUN rm -rf /var/lib/apt/lists/*

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

# アセットのプリコンパイル
RUN --mount=type=secret,id=master_key,target=config/master.key,required=true bin/rails assets:precompile \
  && yarn cache clean \
  && rm -rf /app/node_modules /app/tmp/cache

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8080

CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
