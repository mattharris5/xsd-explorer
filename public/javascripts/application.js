function prepSchema() {

  $("div.split-pane").splitter();

  $(".node .handle").click(function(event) {
      $(".node").removeClass("hover active current critical-path")
      $(this).parent().parent().addClass("current active")
                
      $(this).parents(".node").each(function(elem) {
          $(this).addClass('active critical-path')
          $(this).prevAll().addClass('active')
      });
    
    
      $("#info_panel .contents").empty()
      var attrContents = $(this).parent().siblings().children(".attributes").clone(true)
      attrContents.removeClass("hidden")
      $("#info_panel .contents").append(attrContents)
    
      if($("#showXML").prop('checked'))
          $("#info_panel .code").collapse('show')
          
      $('#info_panel [data-toggle="tooltip"]').tooltip()
  });

  $("#showXML").click(function(event) {
      $("#info_panel .code").collapse('toggle')
  })

  $("#searchForm").on('submit', function(event) {
      event.preventDefault()
      $(".schema").removeHighlight()
      $(".node-body").collapse('hide')
      $(".node-heading").highlight($("#search").val())
      $("mark.highlight").parents(".node-body").collapse('show')
      $("#search").select()
  })  
}

var statusUrl;
var directLoad = false;

function refreshStatus() {
  if (directLoad == true)
      return loadIntoContent( window.location.pathname, { mode: "direct" } )
      
  $.getJSON( statusUrl, function(data) {
    console.log(data)
    
    if (data.progress) {
      $( ".progress > .progress-bar" )
        .removeClass( "active progress-bar-striped" )
        .css( 'width', data.progress + '%' )
        .text( data.progress + '%')
    }
    
    // Done processing and we've got a cache location - go fetch it.
    if (data.location) {
      $( ".progress > .progress-bar" ).addClass( "active progress-bar-striped" )
      loadIntoContent(data.location)
      
    // Otherwise, retry again in 1 sec.
    } else {
      setTimeout(refreshStatus, 1000)
    }
  })
}

function loadIntoContent(resultLocation, data) {
    $( "#content" ).load( resultLocation, data, function() { prepSchema(); })
}