#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require 'underscore'

############################################################################################################

typeModule = angular.module 'type', ['reflux', 'schema']

require './type_list_store'

typeModule.factory 'TypeActions', (TypeListActions)->
    _.extend {}, TypeListActions
