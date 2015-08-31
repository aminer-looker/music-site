#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

JsData = require 'js-data'

############################################################################################################

exports.store = store = new JsData.DS()

exports.Collection = store.defineResource require '../model/collection'
exports.Composer   = store.defineResource require '../model/composer'
exports.Instrument = store.defineResource require '../model/instrument'
exports.Type       = store.defineResource require '../model/type'
exports.Work       = store.defineResource require '../model/work'
