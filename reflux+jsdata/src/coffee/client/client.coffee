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
require './modules/composer/composer_module'
require './modules/dialog/dialog_module'
require './modules/error/error_module'
require './modules/instrument/instrument_module'
require './modules/page'
require './modules/type/type_module'
require './modules/work/work_module'

# Include Angular and its extensions
angular = require 'angular'
require 'angular-animate'

MODULES = [
    'composer'
    'dialog'
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
