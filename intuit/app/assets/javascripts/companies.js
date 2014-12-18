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
  possibleDatePairs = [{'Yesterday': 'Yesterday'},{'Today': 'Today'}, 
                      {'Beginning of Week': 'End of Week'}, 
                       {'Beginning of Week': 'Today'}, 
                       {'Beginning of Last Week': 'End of Last Week'}, 
                       {'Beginning of Last Week': 'Today'}, 
                       {'Today': 'End of Next Week'}, {'Today': 'End of Next 4 Weeks'}, 
                       {'Beginning of Month': 'End of Month'}, {'Beginning of Month': 'Today'}, 
                       {'Beginning of Last Month': 'End of Last Month'}, {'Beginning of Last Month': 'Today'}, 
                       {'Today': 'End of Next Month'},  
                       {'Beginning of Fiscal Quarter': 'End of Fiscal Quarter'}, {'Beginning of Fiscal Quarter': 'Today'}, 
                       {'Beginning of Last Fiscal Quarter': 'End of Last Fiscal Quarter'}, {'Beginning of Last Fiscal Quarter': 'Today'}, 
                       {'Today': 'End of Next Fiscal Quarter'},
                       {'Beginning of Fiscal Year': 'End of Fiscal Year'}, {'Beginning of Fiscal Year': 'Today'}, 
                       {'Beginning of Last Fiscal Year': 'End of Last Fiscal Year'}, {'Beginning of Last Fiscal Year': 'Today'}, 
                       {'Today': 'End of Next Fiscal Year'} ]
})
