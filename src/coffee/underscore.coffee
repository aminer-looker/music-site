#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

module.exports = _ = require 'underscore'

_.mixin require 'underscore.inflections'

_.mixin
    gatherProperties: (dest, sources...)->
        sources = _.flatten [sources]
        for source in sources
            _.extend dest, source
        return dest
