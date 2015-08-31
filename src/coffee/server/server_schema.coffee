#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

JsData = require 'js-data'

############################################################################################################

exports.store = store = new JsData.DS()

exports.Collection = store.defineResource require '../model/collections'
exports.Composer   = store.defineResource require '../model/composers'
exports.Instrument = store.defineResource require '../model/instruments'
exports.Type       = store.defineResource require '../model/types'
exports.Work       = store.defineResource require '../model/works'
