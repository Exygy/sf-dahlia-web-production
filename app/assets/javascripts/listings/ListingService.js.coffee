############################################################################################
####################################### SERVICE ############################################
############################################################################################


ListingService = ($http, $modal) ->
  Service = {}
  Service.listing = {}
  Service.listings = []

  Service.getListing = (_id) ->
    angular.copy({}, Service.listing)
    $http.get(asset_path("listings/"+_id+".json")).success((data, status, headers, config) ->
      angular.copy((if data and data.listing then data.listing else {}), Service.listing)
      console.log(Service.listing)
    ).error( (data, status, headers, config) ->
      console.log data
    )

  Service.getListings = () ->
    angular.copy({}, Service.listings)
    $http.get(asset_path("listings.json")).success((data, status, headers, config) ->
      angular.copy((if data and data.listings then data.listings else {}), Service.listings)
      console.log(Service.listings)
    ).error( (data, status, headers, config) ->
      console.log data
    )

  return Service


############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingFactoryModule = angular.module('ListingFactoryModule', [])
ListingService.$inject = ['$http', '$modal']
ListingFactoryModule.service "ListingService", ListingService
