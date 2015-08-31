#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

if typeof(global) is 'undefined'
    window.global = window

require 'js-data'
require 'js-data-angular' # must follow js-data

require './client_schema'
require './modules/composer'

angular = require 'angular'

############################################################################################################

angular.module 'app', ['composer']

console.log "Classical Music DB Client is Ready"
