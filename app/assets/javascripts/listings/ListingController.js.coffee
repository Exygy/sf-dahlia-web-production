############################################################################################
###################################### CONTROLLER ##########################################
############################################################################################

ListingController = ($scope, $state, $sce, $sanitize, $filter, Carousel, SharedService, ListingService, IncomeCalculatorService) ->
  $scope.shared = SharedService
  $scope.listings = ListingService.listings
  $scope.openListings = ListingService.openListings
  $scope.openMatchListings = ListingService.openMatchListings
  $scope.openNotMatchListings = ListingService.openNotMatchListings
  $scope.closedListings = ListingService.closedListings
  $scope.lotteryResultsListings = ListingService.lotteryResultsListings
  $scope.listing = ListingService.listing
  $scope.favorites = ListingService.favorites
  $scope.activeOptionsClass = null
  $scope.maxIncomeLevels = ListingService.maxIncomeLevels
  $scope.lotteryPreferences = ListingService.lotteryPreferences
  $scope.eligibilityFilters = ListingService.eligibility_filters
  # for expanding the "read more/less" on What To Expect
  $scope.whatToExpectOpen = false
  # for searching lottery number
  $scope.lotterySearchNumber = ''

  $scope.toggleFavoriteListing = (listing_id) ->
    ListingService.toggleFavoriteListing(listing_id)

  $scope.showApplicationOptions = false
  $scope.toggleApplicationOptions = () ->
    $scope.activeOptionsClass = if $scope.activeOptionsClass == 'active' then '' else 'active'
    $scope.showApplicationOptions = !$scope.showApplicationOptions

  $scope.toggleTable = (table) ->
    $scope["active#{table}Class"] = if $scope["active#{table}Class"] then '' else 'active'

  $scope.isActiveTable = (table) ->
    $scope["active#{table}Class"] == 'active'

  $scope.unitAreaRange = (unit_summary) ->
    if unit_summary.minSquareFt != unit_summary.maxSquareFt
      "#{unit_summary.minSquareFt} - #{unit_summary.maxSquareFt}"
    else
      unit_summary.minSquareFt

  $scope.unitsByType = (unit_type) ->
    $filter('groupBy')($scope.listing.Units, 'Unit_Type')[unit_type]

  $scope.unitBMRMinMonthlyRange = (units) ->
    # TODO: actually find min/max
    # if units.length == 1
    units[0].BMR_Rental_Minimum_Monthly_Income_Needed

  $scope.unitBMRRentMonthlyRange = (units) ->
    # TODO: actually find min/max
    # if units.length == 1
    units[0].BMR_Rent_Monthly

  $scope.isFavorited = (listing_id) ->
    ListingService.isFavorited(listing_id)

  $scope.formattedAddress = (listing) ->
    # If Street address is undefined, then return false for display and google map lookup
    if listing.Building_Street_Address == undefined
      return
    # If other fields are undefined, proceed, with special string formatting
    if listing.Building_Street_Address != undefined
      Building_Street_Address = listing.Building_Street_Address + ', '
    else
      Building_Street_Address = ''
    if listing.Building_City != undefined
      Building_City = listing.Building_City
    else
      Building_City = ''
    if listing.Building_State != undefined
      Building_State = listing.Building_State + ', '
    else
      Building_State = ''
    if listing.Building_Zip_Code != undefined
      Building_Zip_Code = listing.Building_Zip_Code
    else
      Building_Zip_Code = ''
    "#{Building_Street_Address}#{Building_City} " +
    "#{Building_State}#{Building_Zip_Code}"

  # TODO: refactor with the above function!
  $scope.formattedApplicationAddress = (listing) ->
    # If Street address is undefined, then return false for display and google map lookup
    if listing.Application_Street_Address == undefined
      return
    # If other fields are undefined, proceed, with special string formatting
    if listing.Application_Street_Address != undefined
      Application_Street_Address = listing.Application_Street_Address + ', '
    else
      Application_Street_Address = ''
    if listing.Application_City != undefined
      Application_City = listing.Application_City
    else
      Application_City = ''
    if listing.Application_State != undefined
      Application_State = listing.Application_State + ', '
    else
      Application_State = ''
    if listing.Application_Postal_Code != undefined
      Application_Postal_Code = listing.Application_Postal_Code
    else
      Application_Postal_Code = ''
    "#{Application_Street_Address}#{Application_City} " +
    "#{Application_State}#{Application_Postal_Code}"


  $scope.googleMapSrc = (listing) ->
    # exygy google places API key -- should be unlimited use for this API
    api_key = 'AIzaSyCW_oXspwGsSlthw-MrPxjNvdH56El1pjM'
    url = "https://www.google.com/maps/embed/v1/place?key=#{api_key}&q=#{$scope.formattedAddress(listing)}"
    $sce.trustAsResourceUrl(url)

  $scope.hasEligibilityFilters = ->
    ListingService.hasEligibilityFilters()

  $scope.clearEligibilityFilters = ->
    ListingService.resetEligibilityFilters()
    IncomeCalculatorService.resetIncomeSources()

  $scope.listingApplicationClosed = (listing) ->
    ! ListingService.listingIsOpen(listing.Application_Due_Date)

  $scope.lotteryDatePassed = (listing) ->
    today = new Date
    lotteryDate = new Date(listing.Lottery_Date)
    lotteryDate <= today

  $scope.openLotteryResultsModal = () ->
    ListingService.openLotteryResultsModal()

  $scope.lotteryDateVenueAvailable = (listing) ->
    (listing.Lottery_Date != undefined &&
      listing.Lottery_Venue != undefined && listing.Lottery_Street_Address != undefined)

  $scope.imageURL = (listing) ->
    # TODO: remove "or" case when we know we have real images
    # just a fallback for now
    listing.Building_URL || 'https://placehold.it/474x316'

  $scope.showMatches = ->
    $state.current.name == 'dahlia.listings' && $scope.hasEligibilityFilters()

  $scope.isOpenListing = (listing) ->
    $scope.openListings.indexOf(listing) > -1
  $scope.isOpenMatchListing = (listing) ->
    $scope.openMatchListings.indexOf(listing) > -1
  $scope.isOpenNotMatchListing = (listing) ->
    $scope.openNotMatchListings.indexOf(listing) > -1
  $scope.isClosedListing = (listing) ->
    $scope.closedListings.indexOf(listing) > -1
  $scope.isLotteryResultsListing = (listing) ->
    $scope.lotteryResultsListings.indexOf(listing) > -1

  # --- Carousel ---
  $scope.carouselHeight = 300
  $scope.Carousel = Carousel
  $scope.adjustCarouselHeight = (elem) ->
    $scope.$apply ->
      $scope.carouselHeight = elem[0].offsetHeight

  $scope.listingImages = (listing) ->
    # TODO: update when we are getting multiple images from Salesforce
    # right now it's just an array of one
    [$scope.imageURL(listing)]

  # lottery search
  $scope.clearLotterySearchNumber = ->
    $scope.lotterySearchNumber = ''

  $scope.lotteryMembers = ->
    return $scope.listing.Lottery_Members unless $scope.lotterySearchNumber
    _.filter $scope.listing.Lottery_Members, (ticket) ->
      ticket.Lottery_Number.toString().indexOf($scope.lotterySearchNumber) == 0

  $scope.showNeighborhoodPreferences = ->
    ListingService.showNeighborhoodPreferences($scope.listing)

  $scope.showLotteryPreferences = ->
    $scope.listingIs480Potrero() ||
    $scope.listingIsAlchemy() ||
    $scope.listingIsClarence() ||
    $scope.listingIs168Hyde() ||
    $scope.listingIsOlume()

  $scope.listingIs480Potrero = ->
    ListingService.listingIs480Potrero($scope.listing)

  $scope.listingIsAlchemy = ->
    ListingService.listingIsAlchemy($scope.listing)

  $scope.listingIsClarence = ->
    ListingService.listingIsClarence($scope.listing)

  $scope.listingIs168Hyde = ->
    ListingService.listingIs168Hyde($scope.listing)

  $scope.listingIsOlume = ->
    ListingService.listingIsOlume($scope.listing)

  $scope.positionOfPreference = (pref) ->
    prefs = []
    prefs.push('COP') if $scope.listing.COPUnits
    prefs.push('DTHP') if $scope.listing.DTHPUnits
    prefs.push('NRHP') if $scope.listing.NRHPUnits
    if pref != 'liveWork'
      pos = prefs.indexOf(pref) + 1
    else
      pos = prefs.length + 1
    $scope.getOrdinal(pos)

  $scope.getOrdinal = (n) ->
    s = ['th', 'st', 'nd', 'rd']
    v = n % 100
    n + (s[(v - 20) % 10] or s[v] or s[0])

  if ($scope.listingIsAlchemy())
    $scope.listing.COPUnits = 50
    $scope.listing.DTHPUnits = 10
    $scope.listing.NRHPUnits = 20
    $scope.listing.supervisorialDistrict = 8
    $scope.listing.Lottery_Results = true
    $scope.listing.LotteryResultsPDFUrl = '''
      http://sfmohcd.org/sites/default/files/Documents/MOH/Lottery%20Results/Posting%20200%20Buchanan%20-%20Alchemy%208-31-2016.pdf
    '''

  if ($scope.listingIs480Potrero())
    $scope.listing.COPUnits = 1
    $scope.listing.DTHPUnits = 2
    $scope.listing.NRHPUnits = 4
    $scope.listing.supervisorialDistrict = 10

  if ($scope.listingIsClarence())
    $scope.listing.COPUnits = 1
    $scope.listing.DTHPUnits = 1
    $scope.listing.NRHPUnits = 0

  if ($scope.listingIs168Hyde())
    $scope.listing.COPUnits = 1
    $scope.listing.DTHPUnits = 0
    $scope.listing.NRHPUnits = 0

  if ($scope.listingIsOlume())
    $scope.listing.COPUnits = 18
    $scope.listing.DTHPUnits = 3
    $scope.listing.NRHPUnits = 7
    $scope.listing.supervisorialDistrict = 6

############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingController.$inject = [
  '$scope',
  '$state',
  '$sce',
  '$sanitize',
  '$filter',
  'Carousel',
  'SharedService',
  'ListingService',
  'IncomeCalculatorService'
]

angular
  .module('dahlia.controllers')
  .controller('ListingController', ListingController)
