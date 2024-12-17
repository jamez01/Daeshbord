# Use a smaller base image
FROM ruby:3.0-slim

# Set environment variables
ENV APP_HOME=/app
ENV CONFIG_FILE=/app/config.yml

# Install essential dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR $APP_HOME

# Install gems with bundler
COPY Gemfile* ./
RUN bundle install --without development test \
    && rm -rf ~/.bundle/cache

# Copy the application code
COPY . .

# Expose the port the app runs on
EXPOSE 9292

# Start the Sinatra app
CMD ["rackup", "-s", "puma", "-o", "0.0.0.0"]