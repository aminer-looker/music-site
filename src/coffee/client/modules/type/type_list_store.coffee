#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require '../../../underscore'

############################################################################################################

angular.module('type').factory 'TypeListActions', (addListStoreMixinActions)->
    return addListStoreMixinActions {}

# Stores ###################################################################################################

angular.module('type').factory 'TypeListStore', (
    Type, TypeListActions, ListStoreMixin, reflux
)->
    reflux.createStore

        listenables: TypeListActions

        mixins: [ListStoreMixin]

        # ListStoreMixin Overrides #####################################################

        _loadAll: ->
            return Type.findAll()
