angular.module('dahlia.directives')
.directive 'liveWorkPreference', ->
  scope: true
  templateUrl: 'short-form/directives/live-work-preference.html'

  link: (scope, elem, attrs) ->
    scope.title = attrs.title
    scope.description = attrs.description
    scope.labelledby = attrs.labelledby
    scope.pref_data_event = attrs.dataevent

    scope.reset_livework_data = ->
      prefs = ['workInSf', 'liveInSf']
      prefs.forEach (preference) ->
        scope.preferences[preference] = null
        scope.preferences[preference + '_household_member'] = null
        scope.preferences[preference + '_proof_option'] = null
        scope.deletePreferenceFile(preference)

    scope.live_or_work_selected = ->
      scope.preferences.liveInSf || scope.preferences.workInSf
