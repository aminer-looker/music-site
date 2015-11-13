A simple site to test the use of [JSData](www.js-data.io/), [Reflux](https://www.npmjs.com/package/reflux), [Angular](angularjs.org/), and [Node](nodejs.org) together as a full-stack solution.  See the [Architecture Overview](https://docs.google.com/document/d/16OVv80SlzB3WsNu-9zQIuhQiyQe7YSD9vBQVk7914OQ/edit#) for more details.

### Setup

This example requires the following software packages be installed.  Please install any you are missing.  All commands should be run from the root of your local repository.

| Package          | Command                                 |
|------------------|-----------------------------------------|
| Brew             | directions on [brew.sh](http://brew.sh) |
| MySQL            | `brew install mysql`                    |
| NodeJS           | `brew install nodejs`                   |
| CoffeeScript     | `npm install -g coffee-script`          |
| NodeMon          | `npm install -g nodemon`                |
| Grunt            | `npm install -g grunt-cli`              |
| NPM Dependencies | `npm install`                           |
| Load local DB    | `./scripts/create-database`             |

### Running Locally

| Task            | Command       |
|-----------------|---------------|
| run the server  | `grunt start` |
| watch the code  | `grunt watch` |
| run tests       | `grunt test`  |
