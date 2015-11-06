#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

ReadOnlyView = require '../src/coffee/read_only_view'

############################################################################################################

describe 'read_only_view.coffee:', ->

    describe 'constructor', ->

        beforeEach ->
            @source = {alpha:'A', bravo:'B', charlie:'C'}

        it 'can create a view with a single field', ->
            view = new ReadOnlyView @source, 'alpha'
            view.alpha.should.equal 'A'

        it 'can create a view with an argument list', ->
            view = new ReadOnlyView @source, 'alpha', 'bravo', 'charlie'
            view.alpha.should.equal 'A'
            view.bravo.should.equal 'B'
            view.charlie.should.equal 'C'

        it 'can create a view with an array', ->
            view = new ReadOnlyView @source, ['alpha', 'bravo', 'charlie']
            view.alpha.should.equal 'A'
            view.bravo.should.equal 'B'
            view.charlie.should.equal 'C'

        it 'can combine a single value and an array', ->
            view = new ReadOnlyView @source, ['alpha', 'bravo'], 'charlie'
            view.alpha.should.equal 'A'
            view.bravo.should.equal 'B'
            view.charlie.should.equal 'C'

        it 'rejects an empty field list', ->
            func = -> new ReadOnlyView @source
            expect(func).to.throw Error, 'at least one'

    describe 'a basic field', ->

        beforeEach ->
            @source = {alpha:'A', bravo:'B', charlie:'C'}

        it 'returns the same value as the source', ->
            view = new ReadOnlyView @source, 'alpha'
            view.alpha.should.equal 'A'

        it 'returns the same value even after the source is changed', ->
            view = new ReadOnlyView @source, 'alpha'
            view.alpha.should.equal 'A'
            @source.alpha = 'a'
            view.alpha.should.equal 'A'

    describe 'an array field', ->

        describe 'with simple values', ->

            beforeEach ->
                @source = {alpha:'A', bravo:['1', '2', '3'], charlie:4}

            it 'returns the same values as the source', ->
                view = new ReadOnlyView @source, 'alpha', 'bravo', 'charlie'
                view.bravo.should.eql ['1', '2', '3']

            it 'returns the same value even after the source is changed', ->
                view = new ReadOnlyView @source, 'bravo'
                view.bravo.should.eql ['1', '2', '3']
                @source.bravo.push '4'
                view.bravo.should.eql ['1', '2', '3']
                @source.bravo = ['5', '6', '7']
                view.bravo.should.eql ['1', '2', '3']

        describe 'with object values', ->

            beforeEach ->
                @source =
                    alpha: 'A'
                    bravo: [
                        { toReadOnlyView: -> new ReadOnlyView {delta:'d'}, 'delta'}
                        { toReadOnlyView: -> new ReadOnlyView {echo:'e'}, 'echo'}
                        { toReadOnlyView: -> new ReadOnlyView {foxtrot:'f'}, 'foxtrot'}
                    ]
                    charlie: 4

            it 'creates read-only views for child objects', ->
                view = new ReadOnlyView @source, 'alpha', 'bravo', 'charlie'
                (e.constructor.name for e in view.bravo).should.eql [
                    'ReadOnlyView', 'ReadOnlyView', 'ReadOnlyView'
                ]

    describe 'an object field', ->

        describe 'with simple values', ->

            beforeEach ->
                @source =
                    alpha: 'A'
                    bravo:
                        toReadOnlyView: -> new ReadOnlyView {delta:'d'}, 'delta'
                    charlie: 4

            it 'creates read-only views for child objects', ->
                view = new ReadOnlyView @source, 'alpha', 'bravo', 'charlie'
                view.bravo.constructor.name.should.equal 'ReadOnlyView'
                view.bravo.delta.should.equal 'd'

        describe 'with a cycle', ->

            beforeEach ->
                @sourceA = {alpha:'a', toReadOnlyView:-> new ReadOnlyView this, 'alpha', 'charlie'}
                @sourceB = {bravo:'b', toReadOnlyView:-> new ReadOnlyView this, 'bravo', 'delta'}

                @sourceA.charlie = @sourceB
                @sourceB.delta = @sourceA

            it 'only expands as deeply as necessary', ->
                view = @sourceA.toReadOnlyView()
                view.charlie.bravo.should.equal 'b'
                (field for field, value of view._cache).sort().should.eql ['charlie']
                (field for field, value of view.charlie._cache).sort().should.eql ['bravo']

                view.charlie.delta.alpha.should.equal 'a'
                (field for field, value of view._cache).sort().should.eql ['charlie']
                (field for field, value of view.charlie._cache).sort().should.eql ['bravo', 'delta']
                (field for field, value of view.charlie.delta._cache).sort().should.eql ['alpha']
