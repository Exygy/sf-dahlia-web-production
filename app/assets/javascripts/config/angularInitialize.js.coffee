@dahlia.run [
  '$rootScope', '$state', '$window', '$translate', '$document', '$timeout',
  'Idle', 'bsLoadingOverlayService',
  'AnalyticsService', 'ShortFormApplicationService', 'AccountService', 'ShortFormNavigationService',
  ($rootScope, $state, $window, $translate, $document, $timeout, Idle, bsLoadingOverlayService,
  AnalyticsService, ShortFormApplicationService, AccountService, ShortFormNavigationService) ->

    # check if user is logged in on page load
    AccountService.validateUser()

    bsLoadingOverlayService.setGlobalConfig({
      delay: 0
      activeClass: 'loading'
      templateUrl: 'shared/templates/spinner.html'
    })

    $rootScope.$on 'IdleStart', ->
      if AccountService.loggedIn()
        $window.alert($translate.instant('T.SESSION_INACTIVITY_LOGGED_IN'))
      else if $state.is('dahlia.short-form-application.confirmation')
        $window.alert($translate.instant('T.SESSION_INACTIVITY_CONFIRMATION'))
      else
        $window.alert($translate.instant('T.SESSION_INACTIVITY'))

    $rootScope.$on 'IdleTimeout', ->
      if AccountService.loggedIn()
        AccountService.signOut()
        $state.go('dahlia.sign-in', {skipConfirm: true})
      else if ShortFormApplicationService.isShortFormPage($state.current)
        $state.go('dahlia.listing', {skipConfirm: true, id: ShortFormApplicationService.listing.Id})

    $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
      # always start the loading overlay
      bsLoadingOverlayService.start()

      if ShortFormApplicationService.hittingBackFromConfirmation(fromState, toState)
        # the redirect will trigger $stateChangeStart again and will popup the confirmation alert
        e.preventDefault()
        $state.go('dahlia.listing', {id: ShortFormApplicationService.listing.listingID})

      else if (ShortFormApplicationService.isLeavingShortForm(toState, fromState))
        # Boolean for Logged in Users on the confirmation page of short form to remove the leave confirmation.
        loggedInConfirmation = (AccountService.loggedIn() && fromState.name == 'dahlia.short-form-application.confirmation')
        # Anonymous user coming from shortform and are on the confirmation page: change the leave message
        if (fromState.name == 'dahlia.short-form-application.confirmation')
          leaveMessage = $translate.instant('T.ARE_YOU_SURE_YOU_WANT_TO_LEAVE_CONFIRMATION')
        else if (ShortFormApplicationService.isLeavingConfirmationToSignIn(toState, fromState))
          leaveMessage = $translate.instant('T.ARE_YOU_SURE_YOU_WANT_TO_LEAVE_SIGN_IN')
        else
          leaveMessage = $translate.instant('T.ARE_YOU_SURE_YOU_WANT_TO_LEAVE')
        # timeout from inactivity means that we don't need to ALSO ask for confirmation
        if (toParams.skipConfirm || loggedInConfirmation || $window.confirm(leaveMessage))
          # disable the onbeforeunload so that you are no longer bothered if you
          # try to reload the listings page, for example
          $window.removeEventListener 'beforeunload', ShortFormApplicationService.onExit
          ShortFormApplicationService.resetUserData() unless toState.name == 'dahlia.short-form-review'
          AnalyticsService.trackFormAbandon('Application')
          AccountService.rememberShortFormState(null)
        else
          # prevent page transition if user did not confirm
          bsLoadingOverlayService.stop()
          e.preventDefault()
          false
      else if fromState.name.match(/create\-account/) && !toState.name.match(/sign\-in/)
        # track if they are leaving create account to go somewhere else
        AnalyticsService.trackFormAbandon('Accounts')

    $rootScope.$on '$stateChangeSuccess', (e, toState, toParams, fromState, fromParams) ->
      # always stop the loading overlay
      bsLoadingOverlayService.stop()

      # track routes as we navigate EXCEPT for initial page load which is already tracked
      AnalyticsService.trackCurrentPage() unless fromState.name == ''

      #### Idle Trigger/Untrigger
      if ShortFormApplicationService.isShortFormPage($state.current) || AccountService.loggedIn()
        Idle.watch()
      else
        Idle.unwatch()

      # check if we're on short form and trying to access a later section than the first section
      toSection = ShortFormNavigationService.getShortFormSectionFromState(toState)
      if toSection
        # we're in shortForm
        fromSection = ShortFormNavigationService.getShortFormSectionFromState(fromState)
        ShortFormApplicationService.checkFormState(fromState.name, fromSection) if fromSection
        if !ShortFormApplicationService.authorizedToProceed(toState, fromState, toSection)
          e.preventDefault()
          return $state.go('dahlia.short-form-application.name', toParams)
      # remember which page of short form we're on when we go to create account
      if (fromState.name.indexOf('short-form-application') >= 0 &&
        fromState.name != 'dahlia.short-form-application.confirmation' &&
        toState.name == 'dahlia.short-form-application.create-account' &&
        fromState.name != 'dahlia.short-form-application.sign-in')
          AccountService.rememberShortFormState(fromState.name)

    $rootScope.$on '$viewContentLoaded', ->
      # Utility function to scroll to top of page when state changes
      $document.scrollTop(0)
      $timeout ->
        # After elements are rendered, make sure to re-focus keyboard input
        # on elements at the top of the page
        topfocus = _.last $document[0].getElementsByClassName('topfocus')
        focusContainer = _.last $document[0].getElementsByClassName('focus-container')
        if focusContainer
          el = focusContainer.querySelectorAll('input, a, button')[0]
          i = 1
          # skip over all ".close" buttons which are hidden within alert boxes
          while el.className == 'close' && el
            el = focusContainer.querySelectorAll('input, a, button')[i]
            i++
          # if we found an input within the .focus-container, put it into focus
          el.focus() if el
        else if topfocus
          # focus + blur the topfocus element so that it doesn't have the focus outline
          topfocus.focus()
          topfocus.blur()

    $rootScope.$on '$stateChangeError', (e, toState, toParams, fromState, fromParams, error) ->
      # always stop the loading overlay
      bsLoadingOverlayService.stop()

      if fromState.name == ''
        return $state.go('dahlia.welcome')

]
