FROM ruby:3.2


RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client

# Set the working directory in the container
WORKDIR /myapp


COPY ./api/Gemfile* ./

# Install gems
RUN gem install bundler && bundle install

# Copy the rest of the app
COPY ./api ./

# CMD ["rails", "server", "-b", "0.0.0.0"]


# # Now also copy the test folder into /myapp/test
# COPY ./test /myapp/test

# Explicitly copy api/test to /myapp/test so Rails finds them
RUN mkdir -p /myapp/test
COPY ./api/test /myapp/test