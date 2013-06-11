assert = chai.assert

GeoJSON = require '../app/js/GeoJSON'

module.exports = ->
  context 'With sample rows', ->
    beforeEach (done) ->
      @db.test.upsert { _id:1, a:"Alice" }, =>
        @db.test.upsert { _id:2, a:"Charlie" }, =>
          @db.test.upsert { _id:3, a:"Bob" }, =>
            done()

    it 'finds all rows', (done) ->
      @db.test.find({}).fetch (results) =>
        assert.equal 3, results.length
        done()

    it 'finds all rows with options', (done) ->
      @db.test.find({}, {}).fetch (results) =>
        assert.equal 3, results.length
        done()

    it 'filters rows by id', (done) ->
      @db.test.find({ _id: 1 }).fetch (results) =>
        assert.equal 1, results.length
        assert.equal 'Alice', results[0].a
        done()

    it 'finds one row', (done) ->
      @db.test.findOne { _id: 2 }, (result) =>
        assert.equal 'Charlie', result.a
        done()

    it 'removes item', (done) ->
      @db.test.remove 2, =>
        @db.test.find({}).fetch (results) =>
          assert.equal 2, results.length
          assert 1 in (result._id for result in results)
          assert 2 not in (result._id for result in results)
          done()

    it 'removes non-existent item', (done) ->
      @db.test.remove 999, =>
        @db.test.find({}).fetch (results) =>
          assert.equal 3, results.length
          done()

    it 'sorts ascending', (done) ->
      @db.test.find({}, {sort: ['a']}).fetch (results) =>
        assert.deepEqual _.pluck(results, '_id'), [1,3,2]
        done()

    it 'sorts descending', (done) ->
      @db.test.find({}, {sort: [['a','desc']]}).fetch (results) =>
        assert.deepEqual _.pluck(results, '_id'), [2,3,1]
        done()

    it 'limits', (done) ->
      @db.test.find({}, {sort: ['a'], limit:2}).fetch (results) =>
        assert.deepEqual _.pluck(results, '_id'), [1,3]
        done()

  it 'adds _id to rows', (done) ->
    @db.test.upsert { a: 1 }, (item) =>
      assert.property item, '_id'
      assert.lengthOf item._id, 32
      done()

  it 'updates by id', (done) ->
    @db.test.upsert { _id:1, a:1 }, (item) =>
      @db.test.upsert { _id:1, a:2 }, (item) =>
        assert.equal item.a, 2
  
        @db.test.find({}).fetch (results) =>
          assert.equal 1, results.length
          done()


  geopoint = (lng, lat) ->
    return {
        type: 'Point'
        coordinates: [lng, lat]
    }

  context 'With geolocated rows', ->
    beforeEach (done) ->
      @db.test.upsert { _id:1, loc:geopoint(90, 45) }, =>
        @db.test.upsert { _id:2, loc:geopoint(90, 46) }, =>
          @db.test.upsert { _id:3, loc:geopoint(91, 45) }, =>
            @db.test.upsert { _id:4, loc:geopoint(91, 46) }, =>
              done()

    it 'finds points near', (done) ->
      selector = loc: 
        $near: 
          $geometry: geopoint(90, 45)

      @db.test.find(selector).fetch (results) =>
        assert.deepEqual _.pluck(results, '_id'), [1,3,2,4]
        done()

    it 'finds points near maxDistance', (done) ->
      selector = loc: 
        $near: 
          $geometry: geopoint(90, 45)
          $maxDistance: 111000

      @db.test.find(selector).fetch (results) =>
        assert.deepEqual _.pluck(results, '_id'), [1,3]
        done()      

    it 'finds points near maxDistance just above', (done) ->
      selector = loc: 
        $near: 
          $geometry: geopoint(90, 45)
          $maxDistance: 112000

      @db.test.find(selector).fetch (results) =>
        assert.deepEqual _.pluck(results, '_id'), [1,3,2]
        done()

    it 'finds points within simple box', (done) ->
      selector = loc: 
        $geoIntersects: 
          $geometry: 
            type: 'Polygon'
            coordinates: [[
              [89.5, 45.5], [89.5, 46.5], [90.5, 46.5], [90.5, 45.5]
            ]]
      @db.test.find(selector).fetch (results) =>
        assert.deepEqual _.pluck(results, '_id'), [2]
        done()



