### 

Creates the context used for the app

Note: There should only every be one context object. It should be modified, rather than creating a whole new object
as components like the PageMenu may be depending on it. 

Contexts have fixed members that have to be present.

db: database (LocalDb, HybridDb or RemoteDb)
imageManager: Simple or Cached Image manager
camera: Camera that has a single function: getPicture(success, error). 
  success is called with url to be passed to imageManager.addImage(url, success, error)
  error: error function to be called with unexpected errors
  auth: see auth module
  login: { user: <username>, org: <org code>, client: <client id> }


stop(): must be called when context is no longer needed, or before setup of a new user

TODO fill in
TODO should any items be null of context?

###

LocalDb = require './db/LocalDb'
RemoteDb = require './db/RemoteDb'
HybridDb = require './db/HybridDb'
SimpleImageManager = require './images/SimpleImageManager'
authModule = require("./auth")
sourcecodes = require './sourcecodes'
syncModule = require './sync'

collectionNames = ['sources', 'forms', 'responses', 'source_types', 'tests', 'source_notes']

apiUrl = 'http://api.mwater.co/v3/'

# Base context
createBaseContext = ->
  # Fake camera # TODO use cordova where possible
  camera = {
    getPicture: (success, error) ->
      alert("On the Android app, this would take a picture")
  }

  error = (err) ->
    console.error err
    str = if err? and err.message then err.message else err
    alert("Internal error: " + err)
    # TODO report? When is this used?

  return { 
    error: error
    apiUrl: apiUrl
    camera: camera
    version: '//VERSION//'
    stop: ->
    # db: null
    # imageManager: null
    # auth: null 
    # login: null
    # sourceCodesManager: null
    # sync: null
  }

# Setup database
createDb = (login) ->
  if login
    # Namespace includes username to be safe
    localDb = new LocalDb({namespace: "db.v3.#{login.user}"}) 
  else
    # No local storage
    localDb = new LocalDb() 

  remoteDb = new RemoteDb(apiUrl, if login then login.client else undefined)

  db = new HybridDb(localDb, remoteDb)

  # Add collections
  for col in collectionNames
    localDb.addCollection(col)
    remoteDb.addCollection(col)
    db.addCollection(col)

  # Seed local db
  if window.seeds
    for col, docs of window.seeds
      for doc in docs
        localDb[col].seed(doc)

  return db

# Anonymous context for not logged in
exports.createAnonymousContext = ->
  db = createDb()

  # Allow nothing
  auth = new authModule.NoneAuth()

  imageManager = new SimpleImageManager(apiUrl)

  return _.extend createBaseContext(), {
    db: db
    imageManager: imageManager
    auth: auth 
    login: null
    sourceCodesManager: null
    sync: null
  }

exports.createDemoContext = ->
  db = createDb()

  # TODO enhance to allow caching in demo mode
  imageManager = new SimpleImageManager(apiUrl)

  # Allow everything
  auth = new authModule.AllAuth()

  # No client or org
  login = { user: "demo" }

  sourceCodesManager = new sourcecodes.DemoSourceCodesManager()
  sync = new syncModule.DemoSynchronizer()

  return _.extend createBaseContext(), {
    db: db 
    imageManager: imageManager
    auth: auth
    login: login
    sourceCodesManager: sourceCodesManager
    sync: sync
  }

# login must contain user, org, client, email members. "user" is username. "org" can be null
# login can be obtained by posting to api /clients
exports.createLoginContext = (login) ->
  db = createDb(login)

  # TODO switch to cached
  imageManager = new SimpleImageManager(apiUrl)
  auth = new authModule.UserAuth(login.user, login.org)
  sourceCodesManager = new sourcecodes.SourceCodesManager(apiUrl + "source_codes?client=#{login.client}")
  sync = new syncModule.Synchronizer(db, imageManager, sourceCodesManager)

  # Start synchronizing
  sync.start(30*1000)  # Every 30 seconds

  stop = ->
    sync.stop()

  return _.extend createBaseContext(), {
    db: db 
    imageManager: imageManager
    auth: auth
    login: login
    sourceCodesManager: sourceCodesManager
    sync: sync
    stop: stop
  }