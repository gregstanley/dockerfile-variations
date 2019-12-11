# Base Python image chosen using recommendations from https://pythonspeed.com/articles/base-image-python-docker-images/
# Alpine not recommended as it uses non-standard files and has issues with installing packages e.g. pandas.
# The 'slim' variation of Debian 'Buster' is still small and uses standard files - installing just works.
FROM python:3.7.5-slim-buster
LABEL maintainer='Greg Stanley' version='1.0' org.label-schema.build-date='2019-12-10 00:00:00'

# TODO: Enable the dates with a proper build process
#ARG BUILD_DATE
#LABEL org.label-schema.build-date=$BUILD_DATE

# We want a user for security and to isolate install files and virtual environment
RUN useradd -ms /bin/bash app-user

# Switch to the new user home directory
WORKDIR /home/app-user

RUN python3 -m venv venv \
    && venv/bin/pip install --upgrade pip \
    && venv/bin/pip install pandas \
    && venv/bin/pip install xlrd \
    && venv/bin/pip install bcrypt \
    && venv/bin/pip install flask \
    && venv/bin/pip install gunicorn

COPY Python/the-app/logging_setup.py the-app/logging_setup.py
COPY Python/the-app/logic the-app/logic
COPY Python/the-app/web the-app/web

# Inject the Docker specific __init__ file and logging configuration
COPY Python/the-app/__init__DOCKER.py the-app/__init__.py
COPY logging-DOCKER.json logging.json

COPY boot.sh ./
RUN chmod +x boot.sh

# Make custom user the owner of the documents
RUN chown -R app-user:app-user ./

# Add ENVIRONMENT variables for the REQUIRED data directories.
# Must be absolute paths (See https://stackoverflow.com/questions/2057045/pythons-os-makedirs-doesnt-understand-in-my-path)
ENV SOURCE_DIRECTORY='/home/app-user/data/source'

# Run the application as the app-user (i.e. not root)
USER app-user

EXPOSE 5000
ENTRYPOINT ["./boot.sh"]
