#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require '../../../underscore'

############################################################################################################

angular.module('instrument').factory 'InstrumentListActions', (addListStoreMixinActions)->
    return addListStoreMixinActions {}

# Stores ###################################################################################################

angular.module('instrument').factory 'InstrumentListStore', (
    Instrument, InstrumentListActions, ListStoreMixin, reflux
)->
    reflux.createStore

        listenables: InstrumentListActions

        mixins: [ListStoreMixin]

        # ListStoreMixin Overrides #####################################################

        _loadAll: ->
            return Instrument.findAll()
