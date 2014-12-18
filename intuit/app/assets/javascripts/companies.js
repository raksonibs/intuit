$(document).ready(function() {
  $('.connect-intuit').click(function() {
    console.log('clicked')
    $.get('/companies/authenticate', function(data, err) {
      console.log(data)
    })
  })
})
