Question = require('./form-controls').Question
ImagePage = require '../pages/ImagePage'

module.exports = class ImagesQuestion extends Question
  events:
    "click #add": "addClick"
    "click .thumbnail": "thumbnailClick"

  renderAnswer: (answerEl) ->
    # Render image using image manager
    if not @ctx.imageManager
      answerEl.html '''<div class="text-error">Images not available</div>'''
    else
      images = @model.get(@id)

      # Determine if can add images
      if @options.readonly
        canAdd = false
      else if @ctx.camera and @ctx.imageManager.addImage
        canAdd = true
      else
        canAdd = false

      # Render images
      answerEl.html templates['forms/ImagesQuestion'](images: images, canAdd: canAdd)

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
    @ctx.camera.takePicture success, (err) ->
      alert("Failed to take picture")

  thumbnailClick: (ev) ->
    @ctx.pager.openPage(ImagePage, { id: ev.currentTarget.id })