$(document).ready(function() {
  $('.connect-intuit').click(function() {
    console.log('clicked')
    $.get('/companies/authenticate', function(data, err) {
      console.log(data)
    })
  })

  $(".date-change").click(function() {
           $this = $(this),
    selectedOpts = $this.parent().find('option:selected')[0],
    reportName   = $this.parent().find('.report-name').val();
    var match = true;

    if ( match ) {
      $.ajax({
        url: '/companies/report_ranged',
        method: 'POST',
        data: { new_range: selectedOpts.text,
                report: reportName },
        complete: function(data) {
          $("."+reportName+"-block").text(data.responseText)
        }
      })
    } else {
      $('.error-inform').text('Error!')
    }

  })

})
