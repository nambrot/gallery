# = require jquery
# = require jquery_ujs
# = require gallery/images_loaded
# = require gallery/spinner

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
          $(document).on 'webkitfullscreenchange mozfullscreenchange fullscreenchange', =>
            @gallery.toggleClass 'fullscreen'
            if !@gallery.hasClass 'fullscreen'
              @gallery.height @pre_fullscreen_height
              @canvas.find('img').width 300
              @canvas.find('img').width 'auto'

          # load more on scroll
          @canvas.scroll () =>
            scrollLeft = @canvas.scrollLeft()
            if scrollLeft == 0
              @currentPhoto = 0
            else
              for child, index in @canvas.children()
                if child.offsetLeft > scrollLeft
                  @currentPhoto = index-1
                  break
            if (@canvas[0].offsetWidth + scrollLeft) * 100 / @canvas[0].scrollWidth > 60
              @loadNextPhotos(2)

        loadNextPhotos: (count = 4) ->
          if @loading or @gallery.find('img[loaded=false]').length == 0
            return
          @loading = true

          # show spinner
          @spinner_container = $('<div class="gallery-spinner"></div>')
          @spinner_container.width (if @gallery.find('img[loaded=true]').length == 0 then '100%' else '5%')
          @gallery.append @spinner_container
          
          opts = 
            lines: 10
            length: 5
            width: 3
            radius: 6
            corners: 1
            rotate: 0
            direction: 1
            color: '#000'
            speed: 1
            trail: 60
            shadow: false
            hwaccel: false
            class: 'spinner'
            zIndex: 2e9

          @spinner = new Spinner(opts).spin(@spinner_container[0]);

          images = @gallery.find('img[loaded=false]').slice(0, count)
          $(images).imagesLoaded =>
            setTimeout ( =>
              $(images).attr('loaded', true).addClass 'loaded'
              @loading = false
              @spinner.stop()
              @spinner_container.remove()
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
            else @cancelFallbackFullscreen()

            @gallery.height @pre_fullscreen_height

            # weird bug requires us to set width to auto or something
            @canvas.find('img').width 300
            @canvas.find('img').width 'auto'
            
            $('body').off "keydown.gallery_fullscreen"
          else

            # save height
            @pre_fullscreen_height = @gallery.height()

            if @gallery[0].requestFullScreen
              @gallery[0].requestFullScreen()
            else if @gallery[0].mozRequestFullScreen
              @gallery[0].mozRequestFullScreen()
            else if @gallery[0].webkitRequestFullScreen
              @gallery[0].webkitRequestFullScreen()
            else @requestFallbackFullscreen()


            @gallery.height "100%"
            $('body').on "keydown.gallery_fullscreen", (e) =>
              switch e.which
                when 37 then @previous(e)
                when 39 then @next(e)
              e.preventDefault()

            # convert all the images to their big-src
            images = @canvas.find('img.loaded')
            for image in images
              if image.src != $(image).data('big-src')
                do (image) ->
                  loading_image = new Image()
                  $(loading_image).load =>
                    image.src = loading_image.src
                  loading_image.src = $(image).data 'big-src'

          setTimeout ( => 
            @goToImage(@currentPhoto)), 400

        requestFallbackFullscreen: ->
          @parent = @gallery.parent()
          fullscreen = $ '<div id="gallery-fallback-fullscreen"></div>'
          $('body').append fullscreen
          @gallery.detach()
          fullscreen.append @gallery
          @canvas = @gallery.find('.gallery-album-photos-canvas')
          @gallery.addClass 'fullscreen'

        cancelFallbackFullscreen: ->
          @gallery.detach()
          $('#gallery-fallback-fullscreen').remove()
          @parent.append @gallery
          @canvas.find('.gallery-album-photos-canvas')
          @gallery.removeClass 'fullscreen'
        goToImage: (index) ->
          @currentPhoto = index
          @canvas.animate({scrollLeft: @canvas.children()[index].offsetLeft}, 300)

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
      $.getJSON "/gallery/albums/#{$(this).data('gallery-id')}/photos", (resp) =>
        return if resp.length == 0
        replacement = $("<div class='gallery-album'><div class='gallery-album-photos small'><div class='gallery-album-photos-canvas'></div></div></div>")
        replacement.find('.gallery-album-photos').css 'height', height
        canvas = replacement.find ".gallery-album-photos-canvas"
        for image in resp
          canvas.append "<img src='' alt='' data-src='#{image.thumbnail}' data-big-src='#{image.source}' loaded=false>"
        $(this).replaceWith replacement
        # set new element as new context
        replacement.gallery()