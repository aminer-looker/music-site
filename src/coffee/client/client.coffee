#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

if typeof(global) is 'undefined'
    window.global = window

require 'js-data'
require 'js-data-angular'
require './client_schema'

angular = require 'angular'

angular.module 'app', ['js-data', 'schema']

console.log "Classical Music DB Client is Ready"
