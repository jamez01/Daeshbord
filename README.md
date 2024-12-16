# Traefik Home

A simple app to display a list of all the services running on a Traefik instance as an easy to navigate dashboard.

## Features
* Display all services running on a Traefik instance
* Attempts to find logo/icon for each service, or generates a placeholder.
* Clicking on a service will take you to the service

## Usage
Create a config.yml file, or use the example provided in the repository. The config file should look like this:
```yaml
traefik:
  - url: "http://traefik:8080"
    username: "admin" # Optional
    password: "password" # Optional

ignore: # All optional, ignore services by name
  - "traefik"
  - "traefik-home"
```
