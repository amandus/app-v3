Question = require('./form-controls').Question
ImagePage = require '../pages/ImagePage'

module.exports = class ImagesQuestion extends Question
  events:
    "click #add": "addClick"
    "click .thumbnail-img": "thumbnailClick"

  renderAnswer: (answerEl) ->
    # Render image using image manager
    if not @ctx.imageManager
      answerEl.html '''<div class="text-error">Images not available</div>'''
    else
      images = @model.get(@id)

      # Determine if can add images
      notSupported = false
      if @options.readonly
        canAdd = false
      else if @ctx.camera and @ctx.imageManager.addImage
        canAdd = true
      else
        canAdd = false
        notSupported = not images or images.length == 0

      # Determine if we need to tell user that no image are available
      noImage = not canAdd and (not images or images.length == 0) and not notSupported

      # Render images
      answerEl.html templates['forms/ImagesQuestion'](images: images, canAdd: canAdd, noImage: noImage, notSupported: notSupported)

      # Set sources
      if images
        for image in images
          @setThumbnailUrl(image.id)
    
  setThumbnailUrl: (id) ->
    success = (url) =>
      @$("#" + id).attr("src", url)
    @ctx.imageManager.getImageThumbnailUrl id, success, @error

  addClick: ->
    # Call camera to get image
    success = (url) =>
      # Add image
      @ctx.imageManager.addImage(url, (id) =>
        # Add to model
        images = @model.get(@id) || []
        images.push { id: id }
        @model.set(@id, images)

      , @ctx.error)
    @ctx.camera.getPicture success, (err) ->
      alert("Failed to take picture")

  thumbnailClick: (ev) ->
    id = ev.currentTarget.id

    # Create onRemove callback
    onRemove = () => 
      images = @model.get(@id) || []
      images = _.reject images, (img) =>
        img.id == id
      @model.set(@id, images)      

    @ctx.pager.openPage(ImagePage, { id: id, onRemove: onRemove })