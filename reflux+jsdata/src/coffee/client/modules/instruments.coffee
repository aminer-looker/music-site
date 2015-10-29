#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_                    = require 'underscore'
angular              = require 'angular'
templates            = require '../templates'
{DetailController}   = require '../base_controllers'
{PageableController} = require '../base_controllers'

############################################################################################################

instrument = angular.module 'instrument', ['schema']

# Factories ############################################################################

instrument.factory 'instrumentActions', (reflux)->
    reflux.createActions [
        'load'
        'loadAll'
        'update'
    ]

work.factory 'instrumentStore', (reflux, Instrument, instrumentActions, InstrumentEditor)->
    reflux.createStore
        init: ->
            @Resource = Instrument
            @Editor = InstrumentEditor

        listenables: instrumentActions

        getAll: ->
            instruments = Instrument.getAll()
            return null unless instruments.length > 0
            return (new InstrumentEditor(model) for model in instruments)

        onLoadAll: ->
            Instrument.findAll().then ->
                @trigger 'all'

work.factory 'InstrumentEditor', ($q, Instrument, instrumentActions)->

    class InstrumentEditor

        constructor: (model)->
            @_model = model

        # Public Methods ###########################################

        cancel: ->
            # do nothing

        save: ->
            instrumentActions.update @data

        # Property Methods #########################################

        Object.defineProperties @prototype,
            id:
                get: -> @_model.id
            name:
                get: -> @data.name ?= @_model?.name
                set: (text)-> @data.name = text
