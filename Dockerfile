# syntax=docker/dockerfile:1

FROM ruby:3.4.1-slim

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    libvips \
    sqlite3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install bundler
RUN gem install bundler

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy rest of the app
COPY . .

# Precompile assets (optional but useful for performance)
RUN bundle exec rake assets:precompile

# Ensure proper permissions
RUN chmod +x bin/*

# Expose port
EXPOSE 3000

# Start Rails
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
