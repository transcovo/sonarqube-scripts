# sonarqube-scripts

Set of scripts for Sonarqube integration in our stack

## scan.sh

This script is used to run a code analysis using sonar-scanner. 

### Prerequisites

* It expects to be run in a project directory containing a `sonar-project.properties` file.
* An environment variable named `SONAR_TOKEN` is expected to be set, containing a valid sonarQube token for the project.
* It expects a `package.json` file with name, version, and description
