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

function refreshStatus() {
  $.getJSON( statusUrl, function(data) {
    if (data.progress) {
      $( ".progress > .progress-bar" )
        .removeClass( "active progress-bar-striped" )
        .css( 'width', data.progress + '%' )
        .text( data.progress + '%')
      
      if (data.progress > 99) {
        window.location = window.location.pathname
      }
    }
    setTimeout(refreshStatus, 1000)
  })
}