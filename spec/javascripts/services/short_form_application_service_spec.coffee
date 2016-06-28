do ->
  'use strict'
  describe 'ShortFormApplicationService', ->
    ShortFormApplicationService = undefined
    $localStorage = undefined
    $translate = {}
    Upload = {}
    uuid = {v4: jasmine.createSpy()}
    fakeHouseholdMember = undefined
    fakeAddress =
      address1: '123 Main St.'
      city: 'San Francisco'
      state: 'CA'
      zip: '94109'
    fakeApplicant =
      firstName: 'Bob'
      lastName: 'Williams'
      dob_month: '07'
      dob_day: '05'
      dob_year: '2015'
      relationship: 'Cousin'
      workInSf: 'Yes'
      preferences: {liveInSf: null, workInSf: null}
      home_address: fakeAddress

    beforeEach module('dahlia.services', ($provide)->
      $provide.value '$translate', $translate
      $provide.value 'Upload', Upload
      $provide.value 'uuid', uuid
      return
    )

    beforeEach inject((_ShortFormApplicationService_, _$localStorage_) ->
      $localStorage = _$localStorage_
      ShortFormApplicationService = _ShortFormApplicationService_
      # have to clear out local storage beforeEach test
      $localStorage.application = ShortFormApplicationService.applicationDefaults
      return
    )

    describe 'Service setup', ->
      it 'initializes applicant defaults', ->
        expectedDefault = ShortFormApplicationService.applicationDefaults.applicant
        expect(ShortFormApplicationService.applicant).toEqual expectedDefault
        return

      it 'initializes application defaults', ->
        expectedDefault = ShortFormApplicationService.applicationDefaults
        expect(ShortFormApplicationService.application).toEqual expectedDefault
        return

      it 'initializes alternateContact defaults', ->
        expectedDefault = ShortFormApplicationService.applicationDefaults.alternateContact
        expect(ShortFormApplicationService.alternateContact).toEqual expectedDefault
        return
      return

    describe 'userCanAccessSection', ->
      it 'initializes completedSections defaults', ->
        expectedDefault = ShortFormApplicationService.applicationDefaults.completedSections
        ShortFormApplicationService.userCanAccessSection('')
        expect(ShortFormApplicationService.application.completedSections).toEqual expectedDefault
        return

      it 'does not initially allow access to later sections', ->
        expect(ShortFormApplicationService.userCanAccessSection('Income')).toEqual false
        return
      return


    describe 'copyHomeToMailingAddress', ->
      it 'copies applicant home address to mailing address', ->
        ShortFormApplicationService.applicant.home_address = fakeAddress
        ShortFormApplicationService.copyHomeToMailingAddress()
        expect(ShortFormApplicationService.applicant.mailing_address).toEqual ShortFormApplicationService.applicant.home_address
        return
      return

    describe 'validMailingAddress', ->
      it 'invalidates if all mailing address required values are not present', ->
        expect(ShortFormApplicationService.validMailingAddress()).toEqual false
        return
      it 'validates if all mailing address required values are present', ->
        ShortFormApplicationService.applicant.mailing_address = fakeAddress
        expect(ShortFormApplicationService.validMailingAddress()).toEqual true
        return
      return

    describe 'missingPrimaryContactInfo', ->
      it 'informs if phone and mailing_address are missing', ->
        expect(ShortFormApplicationService.missingPrimaryContactInfo()).toEqual ['Phone', 'Email', 'Address']
        return

      it 'informs if phone and mailing_address are not missing', ->
        ShortFormApplicationService.applicant.mailing_address = fakeAddress
        ShortFormApplicationService.applicant.phone = '123-123123'
        ShortFormApplicationService.applicant.email = 'email@email.com'
        expect(ShortFormApplicationService.missingPrimaryContactInfo()).toEqual []
        return
      return

    describe 'getHouseholdMember', ->
      beforeEach ->
        fakeHouseholdMember =
          firstName: 'Bob'
          lastName: 'Williams'
          dob_month: '07'
          dob_day: '05'
          dob_year: '2015'
          relationship: 'Cousin'
          id: 1
        return

      afterEach ->
        fakeHouseholdMember = undefined
        return

      it 'returns the householdMember object', ->
        ShortFormApplicationService.householdMembers = [fakeHouseholdMember]
        expect(ShortFormApplicationService.getHouseholdMember(1)).toEqual fakeHouseholdMember
        return
      return

    describe 'addHouseholdMember', ->
      beforeEach ->
        fakeHouseholdMember =
          firstName: 'Bob'
          lastName: 'Williams'
          dob_month: '07'
          dob_day: '05'
          dob_year: '2015'
          relationship: 'Cousin'
        ShortFormApplicationService.householdMembers = []
        ShortFormApplicationService.householdMember = fakeHouseholdMember
        ShortFormApplicationService.addHouseholdMember(fakeHouseholdMember)

      afterEach ->
        fakeHouseholdMember = undefined

      it 'clears the householdMember object', ->
        expect(ShortFormApplicationService.householdMember).toEqual {}
        return

      describe 'new household member', ->
        it 'adds an ID to the householdMember object', ->
          householdMember = ShortFormApplicationService.getHouseholdMember(fakeHouseholdMember.id)
          expect(householdMember.id).toEqual(1)
          return

        it 'adds household member to Service.householdMembers', ->
          expect(ShortFormApplicationService.householdMembers.length).toEqual 1
          expect(ShortFormApplicationService.householdMembers[0]).toEqual fakeHouseholdMember
          return
        return

      describe 'old household member', ->
        beforeEach ->
          householdMember = ShortFormApplicationService.getHouseholdMember(fakeHouseholdMember.id)
          householdMember = angular.copy(householdMember)
          ShortFormApplicationService.addHouseholdMember(householdMember)

        it 'does not add the member', ->
          expect(ShortFormApplicationService.householdMembers.length).toEqual(1)
          return
        return

    describe 'cancelHouseholdMember', ->
      beforeEach ->
        fakeHouseholdMember =
          firstName: 'Bob'
          lastName: 'Williams'
          dob_month: '07'
          dob_day: '05'
          dob_year: '2015'
          relationship: 'Cousin'
        ShortFormApplicationService.householdMembers = []
        ShortFormApplicationService.addHouseholdMember(fakeHouseholdMember)
        ShortFormApplicationService.householdMember = fakeHouseholdMember
        ShortFormApplicationService.cancelHouseholdMember()

      it 'removed household member from list', ->
        expect(ShortFormApplicationService.householdMembers).toEqual []
        return

      it 'should clear householdMember object', ->
        expect(ShortFormApplicationService.householdMember).toEqual {}
        return

    describe 'refreshLiveWorkPreferences', ->
      describe 'applicant does not work in SF', ->
        beforeEach ->
          ShortFormApplicationService.householdMembers = []
          ShortFormApplicationService.applicant = fakeApplicant
          ShortFormApplicationService.applicant.workInSf = 'No'

        it 'should not be assigned workInSf preference', ->
          ShortFormApplicationService.refreshLiveWorkPreferences()
          expect(ShortFormApplicationService.application.preferences.workInSf).toEqual(false)
          return
        return

      describe 'applicant does not live in SF', ->
        beforeEach ->
          home_address = {
            address1: "312 Delaware RD"
            address2: ""
            city: "Mount Shasta"
          }
          ShortFormApplicationService.householdMembers = []
          ShortFormApplicationService.applicant = fakeApplicant
          ShortFormApplicationService.applicant.home_address = home_address

        it 'should not be assigned liveInSf preference', ->
          ShortFormApplicationService.refreshLiveWorkPreferences()
          expect(ShortFormApplicationService.application.preferences.liveInSf).toEqual(false)
          return
        return

    describe 'liveInSfMembers', ->
      describe 'household member has separate sf address', ->
        beforeEach ->
          home_address = {
            address1: "312 Delaware RD"
            address2: ""
            city: "Mount Shasta"
          }
          ShortFormApplicationService.applicant = fakeApplicant
          ShortFormApplicationService.applicant.home_address = home_address
          fakeHouseholdMemberWithAltMailingAddress =
            firstName: 'Bob'
            lastName: 'Williams'
            dob_month: '07'
            dob_day: '05'
            dob_year: '2015'
            relationship: 'Cousin'
            workInSf: 'Yes'
            hasSameAddressAsApplicant: 'No'
            home_address: fakeAddress
          ShortFormApplicationService.addHouseholdMember(fakeHouseholdMemberWithAltMailingAddress)
        it 'should return array of household member who lives in SF', ->
          expect(ShortFormApplicationService.liveInSfMembers().length).toEqual(1)
          return
        return

      describe 'household member has the same sf address as the applicant', ->
        beforeEach ->
          home_address = {
            address1: "312 Delaware RD"
            address2: ""
            city: "San Francisco"
          }
          ShortFormApplicationService.applicant = fakeApplicant
          ShortFormApplicationService.applicant.home_address = home_address
          fakeHouseholdMember =
            firstName: 'Bob'
            lastName: 'Williams'
            dob_month: '07'
            dob_day: '05'
            dob_year: '2015'
            relationship: 'Cousin'
            workInSf: 'Yes'
            hasSameAddressAsApplicant: 'Yes'
          ShortFormApplicationService.addHouseholdMember(fakeHouseholdMember)
        it 'should return an array of both applicant and household member', ->
          expect(ShortFormApplicationService.liveInSfMembers().length).toEqual(2)
          return
        return
      return

    describe 'workInSfMembers', ->
      describe 'only applicant works in SF', ->
        beforeEach ->
          fakeHouseholdMember =
            firstName: 'Bob'
            lastName: 'Williams'
            dob_month: '07'
            dob_day: '05'
            dob_year: '2015'
            relationship: 'Cousin'
            workInSf: 'No'
          ShortFormApplicationService.applicant = fakeApplicant
          ShortFormApplicationService.addHouseholdMember(fakeHouseholdMember)
          ShortFormApplicationService.applicant.workInSf = 'Yes'
        it 'should return array with applicant', ->
          expect(ShortFormApplicationService.workInSfMembers()).toEqual([ShortFormApplicationService.applicant])
          return
        return

      describe 'only household member works in SF', ->
        beforeEach ->
          fakeHouseholdMember =
            firstName: 'Bob'
            lastName: 'Williams'
            dob_month: '07'
            dob_day: '05'
            dob_year: '2015'
            relationship: 'Cousin'
            workInSf: 'Yes'
          ShortFormApplicationService.applicant = fakeApplicant
          ShortFormApplicationService.addHouseholdMember(fakeHouseholdMember)
          ShortFormApplicationService.applicant.workInSf = 'No'
        it 'should return array with applicant', ->
          expect(ShortFormApplicationService.workInSfMembers()).toEqual([fakeHouseholdMember])
          return
        return

      describe 'both applicant and household member work in SF', ->
        beforeEach ->
          fakeHouseholdMember =
            firstName: 'Bob'
            lastName: 'Williams'
            dob_month: '07'
            dob_day: '05'
            dob_year: '2015'
            relationship: 'Cousin'
            workInSf: 'Yes'
          ShortFormApplicationService.applicant = fakeApplicant
          ShortFormApplicationService.addHouseholdMember(fakeHouseholdMember)
          ShortFormApplicationService.applicant.workInSf = 'Yes'
        it 'should return array with applicant', ->
          expect(ShortFormApplicationService.workInSfMembers().length).toEqual(2)
          return
        return
        # TODO: write test for household who lives in SF.

    describe 'authorizedToProceed', ->
      it 'always allows you to access first page of You section', ->
        toState = {name: 'dahlia.short-form-application.name'}
        fromState = {name: ''}
        toSection = {name: 'You'}
        authorized = ShortFormApplicationService.authorizedToProceed(toState, fromState, toSection)
        expect(authorized).toEqual true

      it 'does not allow you to jump ahead', ->
        toState = {name: 'dahlia.short-form-application.household-intro'}
        fromState = {name: ''}
        toSection = {name: 'Household'}
        authorized = ShortFormApplicationService.authorizedToProceed(toState, fromState, toSection)
        expect(authorized).toEqual false

    describe 'isLeavingShortForm', ->
      it 'should know if you\'re not leaving short form', ->
        toState = {name: 'dahlia.short-form-application.contact'}
        fromState = {name: 'dahlia.short-form-application.name'}
        expect(ShortFormApplicationService.isLeavingShortForm(toState, fromState)).toEqual(false)

      it 'should know if you\'re leaving short form', ->
        toState = {name: 'dahlia.listings'}
        fromState = {name: 'dahlia.short-form-application.name'}
        expect(ShortFormApplicationService.isLeavingShortForm(toState, fromState)).toEqual(true)

      it 'should not trigger if you\'re on the short form intro page', ->
        toState = {name: 'dahlia.listings'}
        fromState = {name: 'dahlia.short-form-welcome.intro'}
        expect(ShortFormApplicationService.isLeavingShortForm(toState, fromState)).toEqual(false)

      it 'should not trigger if you\'re going to save and finish later', ->
        toState = {name: 'dahlia.create-account'}
        fromState = {name: 'dahlia.short-form-welcome.intro'}
        expect(ShortFormApplicationService.isLeavingShortForm(toState, fromState)).toEqual(false)
      return