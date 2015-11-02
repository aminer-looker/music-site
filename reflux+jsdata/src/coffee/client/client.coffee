#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

if typeof(global) is 'undefined'
    window.global = window

global.inspect = require('util').inspect

# Load JSData libraries. The core library must be first.
require 'js-data'
require 'js-data-angular'

# Include the Reflux module
require './modules/reflux'

# Include all our modules so they can register with Angular
require './modules/client_schema'
require './modules/composer'
require './modules/dialog'
require './modules/editor'
require './modules/instrument'
require './modules/page'
require './modules/type'
require './modules/work'

# Include Angular and its extensions
angular = require 'angular'
require 'angular-animate'

MODULES = [
    'composer'
    'dialog'
    'editor'
    'instrument'
    'ngAnimate'
    'page'
    'reflux'
    'schema'
    'type'
    'work'
]

############################################################################################################

angular.module 'app', MODULES
    .config ($locationProvider)->
        $locationProvider.html5Mode true

console.log "Classical Music DB Client is Ready"
