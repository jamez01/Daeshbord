FROM ruby:3.0

# Set environment variables
ENV APP_HOME /app
ENV CONFIG_FILE /app/config.yml

# Create app directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install dependencies
COPY Gemfile* $APP_HOME/
RUN bundle install

# Copy the app code
COPY . $APP_HOME

# Expose the port the app runs on
EXPOSE 9292

# Start the Sinatra app
CMD ["rackup", "-spuma","-o0.0.0.0"]
