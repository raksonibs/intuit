$(document).ready(function() {
  $('.connect-intuit').click(function() {
    console.log('clicked')
    $.get('/companies/authenticate', function(data, err) {
      console.log(data)
    })
  })
  // startDate: endDate
  // This Week actually monday to end of week
  // maps accordingly to the supported values for reports so for example the
  //  This Fiscal Year-to-date translates into Beginning of Fiscal Year: Today
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
          // $(".start-date-display")
          // debugger
          $("."+reportName+"-block").text(data.responseText)
        }
      })
    } else {
      $('.error-inform').text('Error!')
    }

  })

})
