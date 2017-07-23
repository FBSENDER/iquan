FROM shikuai_bundle_docker

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
RUN cp -R /usr/src/bundle_dir/bundle /usr/src/app/vendor
WORKDIR /usr/src/app

COPY . /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

ENV RAILS_ENV production 
CMD bundle exec puma -C config/puma.rb
