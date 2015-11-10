#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require 'underscore'

############################################################################################################

instrumentModule = angular.module 'instrument', ['reflux', 'schema']

require './instrument_list_store'

instrumentModule.factory 'InstrumentActions', (InstrumentListActions)->
    _.extend {}, InstrumentListActions
