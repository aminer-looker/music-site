#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

JsData = require 'js-data'
util   = require 'util'
_      = require '../underscore'

############################################################################################################

exports.store = store = new JsData.DS()

exports.installExtensions = ->
    adapter = store.getAdapter 'sql'

    # Adds a "count" method to each Resource instance
    store.defaults.count = (applyFilter)->
        query = adapter.query.count('id as count').from(@table)
        if _.isFunction applyFilter then applyFilter query

        query.then (resultSet)->
            return resultSet[0].count

exports.Collection = store.defineResource require '../model/collection_model'
exports.Composer   = store.defineResource require '../model/composer_model'
exports.Instrument = store.defineResource require '../model/instrument_model'
exports.Type       = store.defineResource require '../model/type_model'
exports.Work       = store.defineResource require '../model/work_model'
