#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../../underscore'
angular = require 'angular'

############################################################################################################

instrumentModule = angular.module 'instrument', [
    'mixins'
    'reflux'
    'schema'
]

require './instrument_list_store'

instrumentModule.factory 'InstrumentActions', (InstrumentListActions)->
    _.extend {}, InstrumentListActions
