############################################################################################
###################################### CONTROLLER ##########################################
############################################################################################

ListingController = ($scope, $state, ListingService) ->


############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingModule = angular.module('ListingModule', []);
ListingController.$inject = ['$scope', '$state', 'ListingService']
ListingModule.controller 'ListingController', ListingController
