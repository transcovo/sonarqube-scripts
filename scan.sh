#!/usr/bin/env bash

# Apache License Version 2.0, January 2004

PROJECT=$(cat package.json | grep name | sed 's/.*": "\(.*\)".*/\1/')
DESCRIPTION=$(cat package.json | grep description | sed 's/.*": "\(.*\)".*/\1/')
VERSION=$(cat package.json | grep version | sed 's/.*": "\(.*\)".*/\1/')
BRANCH=${CIRCLE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}

echo -e "$PROJECT@$VERSION($BRANCH): $DESCRIPTION."
if [[ "$BRANCH" != "master" ]]; then
  echo '> Not master: skipped'
  exit 0
fi

# Download sonar-scanner if not already available on the environment
# @todo macos support
if [[ -z "${SONAR_SCANNER_PATH}" ]]; then
  echo '> Installing sonar scanner...'

  UNZIP_PATH=$(which unzip)
  echo "> UNZIP_PATH=${UNZIP_PATH}"

  if [[ -z "${UNZIP_PATH}" ]]; then
    echo '> Installing unzip...'
    if [ "$EUID" -ne 0 ]; then
      echo '> Requesting root acces...'
      sudo apt update && sudo apt install -y unzip
    else
      echo '> Already having root acces...'
      apt update && apt install -y unzip
    fi
  fi

  echo '> Downloading sonar-scanner-cli...'
  wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip -O /tmp/sonar.zip
#
  rm -Rf /tmp/sonar
  unzip /tmp/sonar.zip -d /tmp/sonar

  mv /tmp/sonar/* /tmp/sonar/src

  SONAR_SCANNER_PATH='/tmp/sonar/src/bin/sonar-scanner'
  export SONAR_SCANNER_PATH
fi

# Sonar scanner execution
$SONAR_SCANNER_PATH \
  -Dsonar.login="$SONAR_TOKEN" \
  -Dproject.settings=./sonar-project.properties \
  -Dsonar.javascript.lcov.reportPaths="${SONAR_LCOV_PATH:-coverage/lcov.info}" \
  -Dsonar.projectDescription="$DESCRIPTION" \
  -Dsonar.links.scm="https://github.com/transcovo/$PROJECT" \
  -Dsonar.links.ci="https://circleci.com/gh/transcovo/$PROJECT" \
  -Dsonar.scm.provider=git \
  -Dsonar.projectVersion="$VERSION"
