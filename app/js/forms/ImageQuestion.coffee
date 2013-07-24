Question = require('./form-controls').Question
ImagePage = require '../pages/ImagePage'

module.exports = class ImageQuestion extends Question
  events:
    "click #add": "addClick"
    "click .thumbnail-img": "thumbnailClick"

  renderAnswer: (answerEl) ->
    # Render image using image manager
    if not @ctx.imageManager
      answerEl.html '''<div class="text-error">Images not available</div>'''
    else
      image = @model.get(@id)

      # Determine if can add images
      notSupported = false
      if @options.readonly
        canAdd = false
      else if @ctx.camera and @ctx.imageManager.addImage
        canAdd = not image? # Don't allow adding more than one
      else
        canAdd = false
        notSupported = not image

      # Determine if we need to tell user that no image is available
      noImage = not canAdd and not image and not notSupported

      # Render images
      answerEl.html templates['forms/ImageQuestion'](image: image, canAdd: canAdd, noImage: noImage, notSupported: notSupported)

      # Set source
      if image
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
        @model.set(@id, { id: id })
      , @ctx.error)
    @ctx.camera.getPicture success, (err) ->
      alert("Failed to take picture")

  thumbnailClick: (ev) ->
    id = ev.currentTarget.id

    # Create onRemove callback
    onRemove = () => 
      @model.set(@id, null)

    @ctx.pager.openPage(ImagePage, { id: id, onRemove: onRemove })