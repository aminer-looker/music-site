#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require '../src/coffee/underscore'

############################################################################################################

describe 'underscore.coffee:', ->

    describe 'gatherProperties', ->

        beforeEach ->
            @alpha   = delta:'D'
            @bravo   = echo:'E'
            @charlie = foxtrot:'F'

        it 'works with a single source object', ->
            dest = _.gatherProperties {}, @alpha
            dest.delta.should.equal 'D'

        it 'works with multiple source objects', ->
            dest = _.gatherProperties {}, @alpha, @bravo
            dest.delta.should.equal 'D'
            dest.echo.should.equal 'E'

        it 'works with an array of sources', ->
            dest = _.gatherProperties {}, [@alpha, @bravo]
            dest.delta.should.equal 'D'
            dest.echo.should.equal 'E'

        it 'works with a mix of object and array', ->
            dest = _.gatherProperties {}, [@alpha, @bravo], @charlie
            dest.delta.should.equal 'D'
            dest.echo.should.equal 'E'
            dest.foxtrot.should.equal 'F'
