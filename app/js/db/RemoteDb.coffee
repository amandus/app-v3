module.exports = class RemoteDb
  # Url must have trailing /
  constructor: (url, client) ->
    @url = url
    @client = client
    @collections = {}

  addCollection: (name) ->
    collection = new Collection(name, @url + name, @client)
    @[name] = collection
    @collections[name] = collection

  removeCollection: (name) ->
    delete @[name]
    delete @collections[name]

# Remote collection on server
class Collection
  constructor: (name, url, client) ->
    @name = name
    @url = url
    @client = client

  find: (selector, options = {}) ->
    return fetch: (success, error) =>
      # Create url
      params = {}
      if options.sort
        params.sort = JSON.stringify(options.sort)
      if options.limit
        params.limit = options.limit
      if options.fields
        params.fields = JSON.stringify(options.fields)
      if @client
        params.client = @client
      params.selector = JSON.stringify(selector || {})

      req = $.getJSON(@url, params)
      req.done (data, textStatus, jqXHR) =>
        success(data)
      req.fail (jqXHR, textStatus, errorThrown) =>
        if error
          error(errorThrown)

  findOne: (selector, options = {}, success, error) ->
    if _.isFunction(options) 
      [options, success, error] = [{}, options, success]

    # Create url
    params = {}
    if options.sort
      params.sort = JSON.stringify(options.sort)
    params.limit = 1
    if @client
      params.client = @client
    params.selector = JSON.stringify(selector || {})

    req = $.getJSON(@url, params)
    req.done (data, textStatus, jqXHR) =>
      success(data[0] || null)
    req.fail (jqXHR, textStatus, errorThrown) =>
      if error
        error(errorThrown)

  upsert: (doc, success, error) ->
    if not @client
      throw new Error("Client required to upsert")

    if not doc._id
      doc._id = createUid()

    req = $.ajax(@url + "?client=" + @client, {
      data : JSON.stringify(doc),
      contentType : 'application/json',
      type : 'POST'})
    req.done (data, textStatus, jqXHR) =>
      success(data || null)
    req.fail (jqXHR, textStatus, errorThrown) =>
      if error
        error(errorThrown)

  remove: (id, success, error) ->
    if not @client
      throw new Error("Client required to remove")
      
    req = $.ajax(@url + "/" + id + "?client=" + @client, { type : 'DELETE'})
    req.done (data, textStatus, jqXHR) =>
      success()
    req.fail (jqXHR, textStatus, errorThrown) =>
      if jqXHR.status == 404
        success()
      else if error
        error(errorThrown)


createUid = -> 
  'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
    r = Math.random()*16|0
    v = if c == 'x' then r else (r&0x3|0x8)
    return v.toString(16)
   )