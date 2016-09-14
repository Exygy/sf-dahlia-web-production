angular.module('dahlia.directives')
.directive 'lotteryResultsRow', ->
  scope: true
  replace: true
  templateUrl: 'listings/directives/lottery-results-row.html'

  link: (scope, elem, attrs) ->
    scope.prefName = attrs.prefName
    scope.abbrPrefName = attrs.abbrPrefName
    scope.itemType = attrs.itemType

    scope.isRank = ->
      scope.itemType == 'rank'

    scope.isBucket = ->
      scope.itemType == 'bucket'

    scope.show = ->
      return true if scope.isBucket()
      return true if scope.isRank() && scope.rankForPreference()
      false

    scope.unitsAvailable = () ->
      scope.lotteryBuckets[scope.abbrPrefName + 'UnitsAvailable']

    scope.rankForPreference = () ->
      applicationResults = scope.listing.Lottery_Ranking.applicationResults[0]
      if applicationResults
        applicationResults[scope.abbrPrefName + 'Rank']
      else
        undefined

    scope.appTotal = () ->
      scope.lotteryBuckets[scope.abbrPrefName + 'AppTotal']
