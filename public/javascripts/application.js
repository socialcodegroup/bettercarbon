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
function htmlentities(txt) {
  var i,tmp,ret='';
  for(i=0; i < txt.length; i++) {
    tmp = txt.charCodeAt(i);
    if( (tmp > 47 && tmp < 58) || (tmp > 62 && tmp < 127) ) {
      ret += txt.charAt(i);
    } else{
      ret += "&#" + tmp + ";";
    }
  }
  return ret;
}