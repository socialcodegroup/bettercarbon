// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function replace_chart_with_chart_2(address) {
	$.ajax({
	  url: "/calculator/chart_tag",
	  data: ({address : address, type : 'graph_code2'}),
	  cache: false,
	  success: function(html){
		console.log(html);
		$('#swfchart').html(html)
	  }
	});
}