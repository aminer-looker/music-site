#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

if typeof(global) is 'undefined'
    window.global = window

# Load JSData libraries. The core library must be first.
require 'js-data'
require 'js-data-angular'

# Include all our modules so they can register with Angular
require './modules/client_schema'
require './modules/composer'
require './modules/work'

angular = require 'angular'

############################################################################################################

angular.module 'app', ['composer', 'work']
    .config ($locationProvider)->
        $locationProvider.html5Mode true

console.log "Classical Music DB Client is Ready"
