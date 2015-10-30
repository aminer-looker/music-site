#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

pageModule = angular.module 'page', []

pageModule.factory 'Page', ->
    class Page

        constructor: (pageNumber, totalPages, list)->
            @_pageNumber = pageNumber
            @_totalPages = totalPages
            @_list = list

        # Public Methods ###############################################################

        hasPrevPage: ->
            return @_pageNumber > 0

        hasNextPage: ->
            return @_pageNumber < @_totalPages

        # Property Methods #############################################################

        Object.defineProperties @prototype,
            list:
                get: -> return @_list[..]
            pageNumber:
                get: -> return @_pageNumber

            totalPages:
                get: -> return @_totalPages
