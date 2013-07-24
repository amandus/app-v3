assert = chai.assert

CachedImageManager = require '../app/js/images/CachedImageManager'

fail = ->
  assert.fail()

createImage = (fs, name, success) ->
  fs.root.getFile name, {create: true}, (fileEntry) =>
    # Create a FileWriter object for our FileEntry 
    fileEntry.createWriter (fileWriter) =>
      fileWriter.onwriteend = (e) =>
        console.log('Write completed.')

      fileWriter.onerror = (e) =>
        console.log('Write failed: ' + e.toString())
    
      # Create a new Blob and write it to log.txt.
      blob = new Blob(['Lorem Ipsum'], {type: 'text/plain'})
      fileWriter.write(blob)
      success(fileEntry.toURL())
    , fail
  , fail


describe "CachedImageManager", ->
  before (done) ->
    # Obtain temp storage
    requestFileSystem  = window.requestFileSystem || window.webkitRequestFileSystem
    mode = if window.LocalFileSystem then LocalFileSystem.TEMPORARY else window.TEMPORARY
    requestFileSystem mode, 0, (fs) =>
      @fs = fs
      @mgr = new CachedImageManager(fs, "Android/data/co.mwater.clientapp/images")
      done()
    , fail

  it "adds an image, returning an id", (done) ->
    assert.isNotNull @fs
    createImage @fs, "test.jpg", (url) =>
      @mgr.addImage url, (id) =>
        assert.equal id.length, 32
        done()
      , fail
      
  context "added image", ->
    it "recalls image"
    it "uploads image"
    it "retries on failure"
    it "does not upload twice"
    