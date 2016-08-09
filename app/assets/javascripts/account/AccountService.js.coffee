############################################################################################
####################################### SERVICE ############################################
############################################################################################

AccountService = ($state, $auth, $modal, $http, $translate, ShortFormApplicationService, ShortFormDataService) ->
  Service = {}
  # userAuth is used as model for inputs in create-account form
  Service.userAuthDefaults =
    user: {}
    contact: {}
  Service.userAuth = angular.copy(Service.userAuthDefaults)
  Service.loggedInUser = {}
  Service.myApplications = []
  Service.createdAccount = {}
  Service.rememberedShortFormState = null
  Service.accountError = {message: null}

  Service.rememberShortFormState = (name, params) ->
    Service.rememberedShortFormState = name

  Service.loggedIn = ->
    return false if !Service.loggedInUser
    !_.isEmpty(Service.loggedInUser) && Service.loggedInUser.signedIn

  Service.createAccount = (shortFormSession) ->
    if shortFormSession
      Service.userAuth.user.temp_session_id = shortFormSession.uid
    $auth.submitRegistration(Service._createAccountParams())
      .success((response) ->
        angular.copy(response.data, Service.createdAccount)
        angular.copy(Service.userAuthDefaults, Service.userAuth)
        Service.accountError.message = null
        return true
      ).error((response) ->
        msg = response.errors.full_messages[0]
        if msg == 'Email already in use'
          Service.accountError.message = $translate.instant("ERROR.EMAIL_ALREADY_IN_USE")
        else if msg == 'Salesforce contact can\'t be blank'
          Service.accountError.message = $translate.instant("ERROR.CREATE_ACCOUNT")
        else
          Service.accountError.message = msg
        return false
      )

  Service.signIn = ->
    $auth.submitLogin(Service.userAuth.user)
      .then((response) ->
        # reset userAuth object
        angular.copy(Service.userAuthDefaults, Service.userAuth)
        if response.signedIn
          angular.copy(response, Service.loggedInUser)
          Service._reformatDOB()
          ShortFormApplicationService.importUserData(Service.loggedInUser)
          return true
      ).catch((response) ->
        Service.accountError.message = response.errors[0]
        return false
      )

  Service.signOut = ->
    $auth.signOut()
      .then((response) ->
        angular.copy({}, Service.loggedInUser)
        ShortFormApplicationService.resetUserData()
      )

  # this gets run on init of the app in AngularConfig to check if we're logged in
  Service.validateUser = ->
    $auth.validateUser().then((response) ->
      # will only reach this state if user is logged in w/ a token
      angular.copy(response, Service.loggedInUser)
      Service._reformatDOB()
      ShortFormApplicationService.importUserData(Service.loggedInUser)
    )

  Service.resendConfirmationEmail = ->
    params =
      email: Service.createdAccount.email

    $http.post('/api/v1/auth/confirmation', params).then((data, status, headers, config) ->
      # $modal.close()
      data
    ).catch( (data, status, headers, config) ->
      return
    )

  Service.getMyApplications = ->
    $http.get('/api/v1/account/my-applications').success((data) ->
      if data.applications
        angular.copy(data.applications, Service.myApplications)
    )

  #################### modals
  Service.openConfirmEmailModal = (email) ->
    if email
      Service.createdAccount.email = email
    modalInstance = $modal.open({
      templateUrl: 'account/templates/partials/_confirm_email_modal.html',
      controller: 'ModalInstanceController',
      windowClass: 'modal-large'
    })

  Service.openConfirmationExpiredModal = (email, confirmed = false) ->
    Service.createdAccount.confirmed = confirmed
    if email
      Service.createdAccount.email = email
    modalInstance = $modal.open({
      templateUrl: 'account/templates/partials/_confirmation_expired_modal.html',
      controller: 'ModalInstanceController',
      windowClass: 'modal-large'
    })


  #################### helper functions
  Service.userDataForContact = ->
    _.merge({}, Service.userAuth.contact, {email: Service.userAuth.user.email})

  Service._createAccountParams = ->
    contact = Service.userDataForContact()
    contact.DOB = ShortFormDataService.formatUserDOB(contact)
    contact = ShortFormDataService.removeDOBFields(contact)
    return {
      user: _.omit(Service.userAuth.user, ['email_confirmation'])
      contact: contact
    }

  Service._reformatDOB = ->
    return false if !Service.loggedIn()
    _.merge(Service.loggedInUser, ShortFormDataService.reformatDOB(Service.loggedInUser.DOB))

  Service.copyApplicantFields = ->
    applicant = ShortFormApplicationService.applicant
    contactInfo = _.pick applicant,
      ['firstName', 'middleName', 'lastName', 'dob_day', 'dob_month', 'dob_year']
    userInfo = _.pick applicant, ['email']
    angular.copy(contactInfo, Service.userAuth.contact)
    angular.copy(userInfo, Service.userAuth.user)

  Service.lockCompletedFields = ->
    a = ShortFormApplicationService.applicant
    Service.lockedFields =
      name: !! (a.firstName && a.lastName)
      dob: !! (a.dob_day && a.dob_month && a.dob_year)
      email: !! a.email

  Service.unlockFields = ->
    Service.lockedFields =
      name: false
      dob: false
      email: false

  # run on page load
  Service.unlockFields()

  return Service


############################################################################################
######################################## CONFIG ############################################
############################################################################################

AccountService.$inject = [
  '$state', '$auth', '$modal', '$http', '$translate',
  'ShortFormApplicationService', 'ShortFormDataService'
]

angular
  .module('dahlia.services')
  .service('AccountService', AccountService)
