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
require './modules/module_index'

# Include Angular and its extensions
angular = require 'angular'
require 'angular-animate'

# List all modules required by the root template of a page
MODULES = [
    'composer'
    'ngAnimate'
    'reflux'
    'schema'
    'work'
]

############################################################################################################

angular.module 'app', MODULES
    .config ($locationProvider)->
        $locationProvider.html5Mode true

console.log "Classical Music DB Client is Ready"
