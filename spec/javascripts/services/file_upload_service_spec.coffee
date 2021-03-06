do ->
  'use strict'
  describe 'FileUploadService', ->
    FileUploadService = undefined
    fakeShortFormApplicationService =
      preferences: {}
    $translate = {}
    Upload =
      upload: ->
    uuid = {v4: jasmine.createSpy()}
    success = { success: true }
    httpBackend = undefined
    fakeFile = {name: 'img.jpg'}
    prefType = 'liveInSf'

    beforeEach module('dahlia.services', ($provide)->
      $provide.value '$translate', $translate
      $provide.value 'Upload', Upload
      $provide.value 'uuid', uuid
      $provide.value 'ShortFormApplicationService', fakeShortFormApplicationService

      return
    )

    beforeEach inject((_$httpBackend_, _FileUploadService_, _$q_) ->
      httpBackend = _$httpBackend_
      FileUploadService = _FileUploadService_
      $q = _$q_
      spyOn(Upload, 'upload').and.callFake ->
        deferred = $q.defer()
        deferred.resolve {data: fakeFile}
        deferred.promise
      return
    )

    describe 'Service setup', ->
      it 'initializes session_uid', ->
        expect(FileUploadService.session_uid).not.toEqual null
        return
      return

    describe 'Service.uploadProof', ->
      it 'calls Upload.upload function', ->
        FileUploadService.uploadProof(fakeFile, prefType)
        expect(Upload.upload).toHaveBeenCalled()
        return
      return

    describe 'Service.deletePreferenceFile', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
        return
      it 'unsets FileUploadService prefType_proof_file', ->
        stubAngularAjaxRequest httpBackend, '/api/v1/short-form/proof', success
        FileUploadService.preferences["#{prefType}_proof_file"] = fakeFile
        FileUploadService.deletePreferenceFile(prefType)
        httpBackend.flush()
        expect(FileUploadService.preferences["#{prefType}_proof_file"]).toEqual null
        return
      return
