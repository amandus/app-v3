# TODO Untested
# TODO id, not uid

# TODO addImage = (url, success, error) ->

exports.createUid = -> 
  'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
    r = Math.random()*16|0
    v = if c == 'x' then r else (r&0x3|0x8)
    return v.toString(16)
   )

# cachePath: e.g. "Android/data/co.mwater.clientapp/images" 
module.exports = class CachedImageManager
  constructor: (fs, cachePath) ->
    @fs = fs
    @cachePath = cachePath

  addImage: (url, success, error) ->
    fs.root.getFile uri, null, ((fileEntry) ->
      
  #     # Copy file to pending folder
  #     getDirectory that.cachePath + "/pending/original", ((dirEntry) ->
  #       console.log "Moving file to: " + dirEntry.fullPath + "/" + photoUid + ".jpg"
  #       fileEntry.moveTo dirEntry, photoUid + ".jpg", success, error
  #     ), error
  #   ), error


  # createDirs = (baseDirEntry, path, success, error) ->
  #   segs = path.split("/")
  #   if segs.length is 1
  #     baseDirEntry.getDirectory segs[0],
  #       create: true
  #     , success, error
  #   else
  #     baseDirEntry.getDirectory segs[0],
  #       create: true
  #     , ((dir) ->
  #       createDirs dir, segs.slice(1).join("/"), success, error
  #     ), error
  
  # # Gets a directory, creating if necessary. Call success with dirEntry
  # getDirectory = (dir, success, error) ->
  #   createDirs fileSystem.root, dir, success, error
  # downloadImage = (imageUid, url, dirEntry, success, error) ->
  #   fileTransfer.download encodeURI(url), dirEntry.fullPath + "/" + imageUid + ".jpg", ((entry) ->
  #     success entry.toURL()
  #   ), (err) ->
      
  #     # Delete file on disk if present
  #     dirEntry.getFile imageUid + ".jpg", {}, ((imageFile) ->
  #       imageFile.remove (->
  #       ), ->

  #     ), ->

      
  #     # Call error function
  #     error err

  # findImageFile = (dir, imageUid, found, notfound, error) ->
  #   console.log "checking in: " + dir
    
  #   # Get directory
  #   getDirectory dir, ((dirEntry) ->
      
  #     # Get file if present
  #     dirEntry.getFile imageUid + ".jpg", {}, ((imageFile) ->
        
  #       # File present, display file
  #       found imageFile.toURL()
  #     ), (err) ->
  #       if err.code is FileError.NOT_FOUND_ERR
  #         notfound()
  #       else
  #         error err

  #   ), error
  # loadOrDownloadImage = (dirs, remoteUrl, downloadDir, imageUid, success, error) ->
    
  #   # If no directories left to try, call download
  #   if dirs.length is 0
  #     getDirectory downloadDir, ((dirEntry) ->
  #       downloadImage imageUid, remoteUrl, dirEntry, success, error
  #     ), error
  #     return
    
  #   # Try each directory in dirs, using recursion
  #   findImageFile _.first(dirs), imageUid, ((url) -> # Found
  #     success url
  #   ), ((url) -> # Not found
  #     loadOrDownloadImage _.rest(dirs), remoteUrl, downloadDir, imageUid, success, error
  #   ), error

  # @syncServer = syncServer
  # @cachePath = cachePath
  # that = this
  # fileTransfer = new FileTransfer()
  # fileSystem = null
  
  # # Gets an image thumbnail, calling success with url 
  # # TODO make generic
  # @getImageThumbnailUrl = (imageUid, success, error) ->
  #   console.log "displayImageThumbnail:" + imageUid
  #   loadOrDownloadImage [@cachePath + "/cached/thumbnail", @cachePath + "/cached/original", @cachePath + "/pending/original"], syncServer.getImageThumbnailUrl(imageUid), @cachePath + "/cached/thumbnail", imageUid, success, error

  
  # # Gets an image, calling success with url 
  # @getImageUrl = (imageUid, success, error) ->
  #   console.log "getImageUrl:" + imageUid
  #   loadOrDownloadImage [@cachePath + "/cached/original", @cachePath + "/pending/original"], syncServer.getImageUrl(imageUid), @cachePath + "/cached/original", imageUid, success, error

  
  # # Gets an image, calling success with local path 
  # @getImagePath = (imageUid, success, error) ->
  #   console.log "getImagePath:" + imageUid
  #   @getImageUrl imageUid, ((url) ->
  #     window.resolveLocalFileSystemURI url, ((fileEntry) ->
        
  #       # Strip file:// if present (Cordova bug)
  #       path = fileEntry.fullPath
  #       path = path.substring(7)  if path.lastIndexOf("file://", 0) is 0
  #       console.log "resolved to: " + path
  #       success path
  #     ), error
  #   ), error

  
  # # Adds an image locally. Success is called with new FileEntry 
  # @addImage = (uri, photoUid, success, error) ->
    
  #   # TODO is this a url passed in or a file?
  #   fileSystem.root.getFile uri, null, ((fileEntry) ->
      
  #     # Copy file to pending folder
  #     getDirectory that.cachePath + "/pending/original", ((dirEntry) ->
  #       console.log "Moving file to: " + dirEntry.fullPath + "/" + photoUid + ".jpg"
  #       fileEntry.moveTo dirEntry, photoUid + ".jpg", success, error
  #     ), error
  #   ), error

  
  # # Upload one image to server. Progress is called with (number of images, % complete). Success is called
  # # with number of images remaining.
  # @upload = (progress, success, error) ->
    
  #   # Copy file to pending folder
  #   getDirectory that.cachePath + "/pending/original", ((dirEntry) ->
      
  #     # Get a list of all the entries in the directory
  #     dirEntry.createReader().readEntries ((files) ->
  #       if files.length is 0
  #         success 0
  #         return
        
  #       # Call progress
  #       progress files.length, 0
        
  #       # Upload file
  #       ft = new FileTransfer()
  #       ft.upload files[0].fullPath, encodeURI(syncServer.getImageUrl(files[0].name.split(".")[0])), (->
          
  #         # Success uploading, delete file
  #         files[0].remove (->
            
  #           # File removed, call success
  #           success files.length - 1
  #         ), error
  #       ), ((fileTransferError) ->
  #         if fileTransferError.http_status is 409
            
  #           # Image already exists, delete file
  #           # Success uploading, delete file
  #           files[0].remove (->
              
  #             # File removed, call success
  #             success files.length - 1
  #           ), error
  #         else
  #           error fileTransferError
  #       ),
  #         fileKey: "image"
  #         params:
  #           clientuid: syncServer.getClientUid()

  #     ), error
  #   ), error

  # @init = (success, error) ->
  #   window.requestFileSystem LocalFileSystem.PERSISTENT, 0, ((fs) ->
  #     fileSystem = fs
  #     success()
  #   ), error
