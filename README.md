A simple site to test the use of [JSData](www.js-data.io/), [Reflux](https://www.npmjs.com/package/reflux), [Angular](angularjs.org/), and [Node](nodejs.org) together as a full-stack solution.  See the [Architecture Overview](https://docs.google.com/document/d/16OVv80SlzB3WsNu-9zQIuhQiyQe7YSD9vBQVk7914OQ/edit#) for more details.

### Setup

This example requires the following software packages be installed.  Please install any you are missing.  All commands should be run from the root of your local repository.

1. Brew: following the directions on [brew.sh](http://brew.sh)
2. MySQL: `brew install mysql`
3. NodeJS: `brew install nodejs`
4. CoffeeScript: `npm install -g coffee-script`
5. NodeMon: `npm install -g nodemon`
6. Grunt: `npm install -g grunt-cli`
7. NPM Dependencies: `npm install`
8. Load local DB: `./scripts/create-database`

### Running Locally

To run the server: `grunt start`
To start watching the code: `grunt watch`
To run tests: `grunt test`
