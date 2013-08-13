# = require jquery
# = require jquery_ujs
# = require gallery/images_loaded

$.fn.extend
  gallery: (options) ->
    # Default settings
    settings =
      foo: 'bar'

    # Merge default settings with options.
    settings = $.extend settings, options

    # _Insert magic here._
    return @each ()->

      $.extend this,
        lastLoadedPhotoIndex: 0
        currentPhoto: 0
        loading: false
        gallery: $(this).find('.gallery-album-photos')
        canvas: $(this).find('.gallery-album-photos-canvas')
        init: ->
          # load initial set
          @loadNextPhotos()

          # set up arrows 
          @gallery.append('<span class="gallery-arrow-left"></span>')
          @gallery.append('<span class="gallery-arrow-right"></span>')
          @gallery.on 'click', '.gallery-arrow-left',  $.proxy(@previous, this)
          @gallery.on 'click', '.gallery-arrow-right',  $.proxy(@next, this)

          # set up full screen
          @gallery.append('<span class="gallery-fullscreen"></span>')
          @gallery.on 'click', '.gallery-fullscreen',  $.proxy(@requestFullScreen, this)
          @gallery.on 'webkitfullscreenchange mozfullscreenchange fullscreenchange', =>
            @gallery.toggleClass 'fullscreen'
            if !@gallery.hasClass 'fullscreen'
              @gallery.height @pre_fullscreen_height
          # keys

          @canvas.keydown (e) =>
            switch e.which
              when 37 then @previous()
              when 39 then @next()
            e.preventDefault()
          # load more on scroll
          @canvas.scroll () =>
            if @canvas[0].offsetWidth * @canvas.scrollLeft() * 100 / @canvas[0].scrollWidth > 90
              @loadNextPhotos()



        loadNextPhotos: (count = 4) ->
          if @loading
            return
          @loading = true
          images = $(this).find('img[loaded=false]').slice(0, count)
          $(images).imagesLoaded =>
            setTimeout ( =>
              $(images).attr('loaded', true).addClass 'loaded'
              @loading = false
             ), 20
          
          fullscreenEnabled = @gallery.hasClass 'fullscreen'

          for image in images
            if fullscreenEnabled then image.src = $(image).data('big-src') else image.src = $(image).data('src')

        next: (evt) ->
          # get current photo position
          scrollLeft = @canvas.scrollLeft()

          if scrollLeft == 0
            @goToImage(1)
            return

          evt.stopPropagation() if evt.stopPropagation?
          
          index = 0
          for child, index in @canvas.children()
            if child.offsetLeft > scrollLeft
              @goToImage(index)
              break

          

        previous: (evt) ->
          scrollLeft = @canvas.scrollLeft()
          
          if scrollLeft == 0
            @goToImage(1)
            return

          index = 0
          for child, index in @canvas.children()
            if child.offsetLeft >= scrollLeft
              @goToImage(index-1)
              break

          evt.stopPropagation() if evt.stopPropagation?

        requestFullScreen: ->

          fullscreenEnabled = @gallery.hasClass 'fullscreen'

          if fullscreenEnabled
          
            if document.cancelFullScreen
              document.cancelFullScreen()
            else if document.mozCancelFullScreen
              document.mozCancelFullScreen()
            else if document.webkitCancelFullScreen
              document.webkitCancelFullScreen()

            @gallery.height @pre_fullscreen_height

          else

            # save height
            @pre_fullscreen_height = @gallery.height()

            if @gallery[0].requestFullScreen
              @gallery[0].requestFullScreen()
            else if @gallery[0].mozRequestFullScreen
              @gallery[0].mozRequestFullScreen()
            else if @gallery[0].webkitRequestFullScreen
              @gallery[0].webkitRequestFullScreen()

            @gallery.height "100%"

            # convert all the images to their big-src
            images = @canvas.find('img.loaded')
            for image in images
              if image.src != $(image).data('big-src')
                loading_image = new Image()
                $(loading_image).imagesLoaded =>
                  image.src = loading_image.src
                loading_image.src = $(image).data 'big-src'

          setTimeout ( => 
            @goToImage(@currentPhoto)), 400

        goToImage: (index) ->
          @currentPhoto = index
          @canvas.animate({scrollLeft: @canvas.children()[index].offsetLeft}, 400)

      this.init()
      return this
  decorate_gallery: (options) ->
    
    settings =
      foo: 'bar'

    # Merge default settings with options.
    settings = $.extend settings, options

    # _Insert magic here._
    return @each ()->

    # for personal use, record height
      
      height = $(this).height()

      # TODO: set prefix in a config
      $.get "/gallery/albums/#{$(this).data('gallery-id')}/photos", (resp) =>
        return if resp.length == 0
        replacement = $("<div class='gallery-album'><div class='gallery-album-photos small'><div class='gallery-album-photos-canvas'></div></div></div>")
        replacement.find('.gallery-album-photos').css 'height', height
        canvas = replacement.find ".gallery-album-photos-canvas"
        for image in resp
          canvas.append "<img src='' alt='' data-src='#{image.thumbnail}' data-big-src='#{image.source}' loaded=false>"
        $(this).replaceWith replacement
        # set new element as new context
        replacement.gallery()