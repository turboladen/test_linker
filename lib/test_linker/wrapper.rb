require File.expand_path(File.dirname(__FILE__) + '/error')

class TestLinker

  # This module contains all methods that directly wrap TestLink's XMLRPC
  # functions.
  module Wrapper

    # Returns info about the server's TestLink API.
    #
    # @return [String] Info about TestLink API version
    def about
      make_call("tl.about", {}, "1.0b5")
    end

    # Adds a test case version to a test plan.
    #
    # @param [Fixnum,String] project_id
    # @param [Fixnum,String] plan_id
    # @param [Fixnum,String] test_case_external_id
    # @param [Fixnum,String] test_case_version
    # @param [Hash] options Optional parameters for the method.
    # @option options [String] urgency
    # @option options [Fixnum] executionorder
    # @option options [Fixnum] platformid Only if test plan has no platforms.
    #   (TestLink API >=1.0)
    # @return
    def add_test_case_to_test_plan(project_id, plan_id, test_case_external_id,
        test_case_version, options={})
      args = { :testprojectid => project_id, :testplanid => plan_id,
          :testcaseexternalid => test_case_external_id,
          :version => test_case_version }
      args.merge! options
      make_call("tl.addTestCaseToTestPlan", args, "1.0b5")
    end
    alias_method :addTestCaseToTestPlan, :add_test_case_to_test_plan

    # Assign Requirements to a test case.  Capable of assigning multiple
    # requirements. Requirements can belong to different Requirement Specs.
    #
    # @param [Fixnum,String] project_id
    # @param [Fixnum,String] test_case_external_id
    # @param [String] requirements
    # @return
    def assign_requirements(project_id, test_case_external_id, requirements)
      args = { :testcaseexternalid => test_case_external_id,
          :testprojectid => project_id, :requirements => requirements }
      make_call("tl.assignRequirements", args, "1.0b5")
    end
    alias_method :assignRequirements, :assign_requirements

    # Gets a list of builds within a test plan.
    #
    # @param [Fixnum,String] plan_id ID of the plan to get builds for.
    # @return [Array<Hash>] List of all builds for the plan and their associated
    #   info.
    def builds_for_test_plan plan_id
      args = { :testplanid => plan_id }
      make_call("tl.getBuildsForTestPlan", args, "1.0b5")
    end
    alias_method :getBuildsForTestPlan, :builds_for_test_plan

    # Checks if the given Developer Key exist.
    #
    # @api TestLink API version 1.0
    # @param [String] dev_key
    # @return [Hash] "true" if it exists, otherwise error structure.
    def check_dev_key dev_key
      args = { :devKey => dev_key }
      make_call("tl.checkDevKey", args, "1.0")
    end
    alias_method :checkDevKey, :check_dev_key

    # Creates a new build for a specific test plan.
    #
    # @param [Fixnum,String] plan_id
    # @param [String] build_name
    # @param [String] build_notes
    # @return
    def create_build(plan_id, build_name, build_notes)
      args = { :testplanid => plan_id, :buildname => build_name,
          :buildnotes => build_notes }
      make_call("tl.createBuild", args, "1.0b5")
    end
    alias_method :createBuild, :create_build

    # @param [String] project_name
    # @param [String] test_case_prefix
    # @param [Hash] options
    # @option options [String] notes
    # @option options [Hash] options ALL int treated as boolean:
    #   requirementsEnabled, testPriorityEnabled, automationEnabled,
    #   inventoryEnabled
    # @option options [Fixnum] active
    # @option options [Fixnum] public
    # @return
    def create_project(project_name, test_case_prefix, options={})
      args = { :testprojectname => project_name, :testcaseprefix => test_case_prefix }
      args.merge! options
      make_call("tl.createTestProject", args, "1.0b5")
    end
    alias_method :createTestProject, :create_project

    # @param [Fixnum,String] project_id
    # @param [Fixnum,String] suite_id
    # @param [String] test_case_name
    # @param [String] test_case_summary
    # @param [String] test_case_steps
    # @param [String] test_case_expected_results
    # @param [String] login
    # @param [Hash] options
    # @option options [String] preconditions
    # @option options [String] execution
    # @option options [Fixnum] order
    # @option options [Fixnum,String] internalid
    # @option options [Boolean] checkduplicatedname
    # @option options [String] actiononduplicatedname
    # @option options [String] executiontype
    # @return
    def create_test_case(project_id, suite_id, test_case_name, test_case_summary,
        test_case_steps, test_case_expected_results, login, options={})
      args = { :testcasename => test_case_name,
          :testsuiteid => suite_id,
          :testprojectid => project_id,
          :authorlogin => login,
          :summary => test_case_summary,
          :steps => test_case_steps,
          :expectedresults => test_case_expected_results }
      args.merge! options
      make_call("tl.createTestCase", args, "1.0b5")
    end
    alias_method :createTestCase, :create_test_case

    # @api TestLink API version 1.0
    # @param [String] project_name
    # @param [String] plan_name
    # @param [Hash] options
    # @option options [String] notes
    # @option options [String] active Defaults to 1.
    # @option options [String] public Defaults to 1.
    # @return
    def create_test_plan(project_name, plan_name, options={})
      args = { :testplanname => plan_name, :testprojectname => project_name }
      args.merge! options
      make_call('tl.createTestPlan', args, "1.0")
    end
    alias_method :createTestPlan, :create_test_plan

    # @param [Fixnum,String] project_id
    # @param [String] suite_name
    # @param [String] details
    # @param [Hash] options
    # @option options [Fixnum,String] parentid Defaults to top level.
    # @option options [Fixnum] order Order inside parent container.
    # @option options [Boolean] checkduplicatedname Check if there siblings with
    #   the same name. Defaults to true.
    # @option options [Boolean] actiononduplicatedname Applicable only if
    #   checkduplicatedname = true.
    # @return [Array<Hash>] Info about results of test suite creation.
    def create_test_suite(project_id, suite_name, details, options={})
      args = { :testprojectid => project_id, :testsuitename => suite_name,
          :details => details }
      args.merge! options
      make_call('tl.createTestSuite', args, "1.0b5")
    end
    alias_method :createTestSuite, :create_test_suite

    # @api TestLink API version 1.0
    # @param [Fixnum,String] execution_id
    # @return [Hash] "status", "id", "message"
    def delete_execution execution_id
      args = { :executionid => execution_id }
      make_call("tl.deleteExecution", args, "1.0")
    end
    alias_method :deleteExecution, :delete_execution

    # @api TestLink API version 1.0
    # @param [String] user_name
    # @return [Boolean,Hash] true if user exists, otherwise an error structure.
    def does_user_exist user_name
      args = { :user => user_name }
      make_call("tl.doesUserExist", args, "1.0")
    end
    alias_method :doesUserExist, :does_user_exist

    # Gets the set of test suites from the top level of the test project tree.
    #
    # @param [Fixnum,String] project_id ID of the project to get suites for.
    # @return [Array<Hash>] List of first level suites in project and their
    #   associated info.
    def first_level_test_suites_for_project project_id
      args = { :testprojectid => project_id }
      make_call("tl.getFirstLevelTestSuitesForTestProject", args, "1.0b5")
    end
    alias_method :getFirstLevelTestSuitesForTestProject,
        :first_level_test_suites_for_project

    # Gets full path from the given node till the top using nodes_hierarchy_table.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] node_id
    # @return
    def full_path node_id
      args = { :nodeID => node_id }
      make_call("tl.getFullPath", args, "1.0")
    end
    alias_method :getFullPath, :full_path

    # @param [Fixnum,String] plan_id
    # @param [Fixnum,String] build_id
    # @param [Fixnum,String] test_case_id
    # @return [Array<Hash>] Single element Array containing the result Hash.
    def last_execution_result(plan_id, build_id, test_case_id)
      args = { :testplanid => plan_id, :testcaseid => test_case_id, :buildid => build_id }
      make_call("tl.getLastExecutionResult", args, "1.0b5")
    end
    alias_method :getLastExecutionResult, :last_execution_result

    # @param [Fixnum,String] plan_id ID of the plan to get build for.
    # @return [Hash] Info for the latest build for the given test plan.
    def latest_build_for_test_plan plan_id
      args = { :testplanid => plan_id }
      make_call("tl.getLatestBuildForTestPlan", args, "1.0b5")
    end
    alias_method :getLatestBuildForTestPlan, :latest_build_for_test_plan

    # Info about a test project with a given name.
    #
    # @api TestLink API version 1.0
    # @param [String] project_name Name of the project to search for.
    # @return [Array<Hash>] Info on matching project.
    def project_by_name project_name
      args = { :testprojectname => project_name }
      make_call('tl.getTestProjectByName', args, "1.0")
    end
    alias_method :getTestProjectByName, :project_by_name

    # Gets a list of all projects.
    #
    # @return [Array<Hash>] List of all projects in TestLink and
    # their associated info.
    def projects
      make_call("tl.getProjects", {}, "1.0b5" )
    end
    alias_method :getProjects, :projects

    # Sends a message to the server to have it repeated back.
    #
    # @param [String] message The message to get the server to repeat back.
    # @return [String] The message sent to the server.
    def repeat message
      make_call("tl.repeat", { :str => message }, "1.0b5")
    end

    # Sets result in TestLink by test case ID and test plan ID.
    # NOTE: will guess at last build, needs to be set to guarantee accuracy.
    # NOTE: Renamed to setTestCaseExecutionResult in version 1.0.
    #
    # @see #test_case_execution_result=
    # @version TestLink API version 1.0 Beta 5
    # @param [Fixnum,String] plan_id ID of the test plan to post results to.
    # @param [Fixnum,String] test_case_id ID of the test case to post results to.
    # @param [String] status 'p', 'f', or 'b' for Pass/Fail/Block
    # @param [Hash] options
    # @option options [Fixnum,String] buildid ID of the build to post results to.
    # @option options [Fixnum,String] buildname Name of the build to post results to.
    # @option options [Fixnum,String] bugid ID of the bug to link results to.
    # @option options [Boolean] guess Defines whether to guess optional params
    #   or require them explicitly.  Defaults to true.
    # @option options [Fixnum,String] platformid ID of the platform to associate with the
    #   result. (TestLink API >=1.0)
    # @option options [String] customfields i.e. "NAME: Steve Loveless\n"
    #   (TestLink API >=1.0)
    # @option options [String] notes ?
    # @return [Hash] "status" of posting, "id" of the execution, "message"
    #   giving success or failure info.
    # @raise [TestLinker::Error] If result fails to be posted for any reason.
    def report_test_case_result(plan_id, test_case_id, status, options={})
      if @version >= "1.0"
        message = "Method not supported in version #{@version}. "
        message << "Use #test_case_execution_result="
        raise TestLinker::Error, message
      end

      args = { :testcaseid => test_case_id, :testplanid => plan_id,
          :status => status, :guess => true }
      args.merge! options
      result = @server.call("tl.reportTCResult", args).first

      unless result['message'] == 'Success!'
        raise TestLinker::Error, "#{result['code']}: #{result['message']}"
      end

      result
    end
    alias_method :reportTCResult, :report_test_case_result

    # Basic connectivity test.
    #
    # @return [String] "Hello!"
    def say_hello
      make_call("tl.sayHello", {}, "1.0b5")
    end
    alias_method :sayHello, :say_hello
    alias_method :ping, :say_hello

    # Gets a test case by it's internal or external ID.
    #
    # @api TestLink API version 1.0
    # @param [Hash] options
    # @option options [Fixnum,String] testcaseid
    # @option options [Fixnum,String] testcaseexternalid
    # @option options [Fixnum,String] version The test case version. Default is most recent.
    # @return
    def test_case(options)
      make_call("tl.getTestCase", options, "1.0")
    end
    alias_method :getTestCase, :test_case

    # Gets attachments for specified test case.
    #
    # @param [Hash] options
    # @param [Fixnum,String] testcaseid If not present, testcaseexternalid must be called.
    # @param [Fixnum,String] testcaseexternalid If not present, testcaseid must be called.
    # @return [String]
    def test_case_attachments options
      make_call("tl.getTestCaseAttachments", options, "1.0b5")
    end
    alias_method :getTestCaseAttachments, :test_case_attachments

    # @param [Fixnum,String] project_id
    # @param [Fixnum,String] test_case_external_id
    # @param [Fixnum] custom_field_name
    # @param [Hash] options
    # @option options [String] details Changes output information. If null or 'value',
    #   returns just a value; if 'full', returns a hash with all custom field definition,
    #   plus value and internal test case id; if 'simple', returns value plus custom
    #   field name, label, and type (as code).
    # @return [Array<Hash>]
    def test_case_custom_field_design_value(project_id, test_case_external_id,
        custom_field_name, options={})
      args = { :testprojectid => project_id,
          :testcaseexternalid => test_case_external_id,
          :customfieldname => custom_field_name }
      args.merge! options
      make_call("tl.getTestCaseCustomFieldDesignValue", args, "1.0b5")
    end
    alias_method :getTestCaseCustomFieldDesignValue, :test_case_custom_field_design_value

    # Sets result in TestLink by test case ID and test plan ID.
    # NOTE: will guess at last build, needs to be set to guarantee accuracy.
    #
    # @see #report_test_case_result
    # @api TestLink API version 1.0
    # @param [String] plan_id ID of the test plan to post results to.
    # @param [String] test_case_id ID of the test case to post results to.
    # @param [String] status 'p', 'f', or 'b' for Pass/Fail/Block
    # @param [Hash] options
    # @option options [Fixnum] buildid ID of the build to post results to.
    # @option options [String] buildname Name of the build to post results to.
    # @option options [Fixnum] bugid ID of the bug to link results to.
    # @option options [Boolean] guess Defines whether to guess optinal params or require them.
    # @option options [String] notes ?
    # @option options [String] platformid (version 1.0)
    # @option options [String] platformid (version 1.0)
    # @option options [String] customfields (version 1.0)
    # @option options [String] overwrite (version 1.0)
    # @return [Hash] "status" of posting, "id" of the execution, "message"
    #   giving success or failure info.
    # @raise [TestLinker::Error] If result fails to be posted for any reason.
    def test_case_execution_result=(plan_id, test_case_id, status, options={})
      if @version < "1.0"
        message = "Method not supported in version #{@version}. "
        message << "Use #report_test_case_result"
        raise TestLinker::Error, message
      end

      args = { :testcaseid => test_case_id, :testplanid => plan_id,
          :status => status, :guess => true }
      args.merge! options
      result = make_call("tl.setTestCaseExecutionResult", args, "1.0").first

      unless result[:message] == 'Success!'
        raise TestLinker::Error, "#{result['code']}: #{result['message']}"
      end

      result
    end
    alias_method :setTestCaseExecutionResult, :test_case_execution_result=

    # Info about test case by name.
    # CAUTION: returns multiple values if test case is used more than once.
    #
    # @param [String] test_case_name Name to search across TL DB.
    # @param [Hash] options
    # @option options [String] testprojectname
    # @option options [String] testsuitename
    # @option options [String] testcasepathname
    # @raise [TestLinker::Error] When test case name doesn't exist.
    # @return [Array<Hash>] List of all test cases in the DB matching
    #   test_case_name and their associated info.
    def test_case_id_by_name(test_case_name, options={})
      args   = { :testcasename => test_case_name }
      args.merge! options
      make_call("tl.getTestCaseIDByName", args, "1.0b5")
    end
    alias_method :getTestCaseIDByName, :test_case_id_by_name

    # Info about test cases within a test plan.
    #
    # @param [Fixnum,String] plan_id ID of the plan to get test cases for.
    # @param [Hash] options
    # @option options [Fixnum,String] testcaseid
    # @option options [Fixnum,String] buildid
    # @option options [Fixnum,String] keywordid (mutually exclusive with keywords)
    # @option options [Fixnum] keywords (mutually exclusive with keywordid)
    #   (TestLink API >=1.0)
    # @option options [String] executed
    # @option options [String] assignedto
    # @option options [String] executestatus
    # @option options [String] executiontype
    # @option options [String] getstepinfo Defaults to false
    # @return [Hash] List of all test cases in the plan and their
    #   associated info.
    def test_cases_for_test_plan(plan_id, options={})
      args = { :testplanid => plan_id }
      args.merge! options
      make_call("tl.getTestCasesForTestPlan", args, "1.0b5")
    end
    alias_method :getTestCasesForTestPlan, :test_cases_for_test_plan

    # @param [Fixnum,String] project_id
    # @param [Fixnum,String] suite_id ID of the suite to retrieve test cases for.
    # @param [Boolean] deep
    # @param [String] details Default is "simple"; use "full" to get
    #   summary, steps & expected results.
    # @return [Array<Hash>] List of test cases in the given suite and their
    #   associated info.
    def test_cases_for_test_suite(project_id, suite_id, deep=true, details="")
      args = { :testsuiteid => suite_id, :projectid => project_id,
          :deep => deep, :details => details }
      make_call("tl.getTestCasesForTestSuite", args, "1.0b5")
    end
    alias_method :getTestCasesForTestSuite, :test_cases_for_test_suite

    # Gets the test plan with the given name.
    #
    # @api TestLink API version 1.0
    # @param [String] project_name Name of the project the plan is in.
    # @param [String] plan_name Name of the plan to search for.
    # @return [Array<Hash>] Info on matching plan.
    def test_plan_by_name(project_name, plan_name)
      args = { :testplanname => plan_name, :testprojectname => project_name }
      make_call('tl.getTestPlanByName', args, "1.0")
    end
    alias_method :getTestPlanByName, :test_plan_by_name

    # List test suites within a test plan alphabetically.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] plan_id ID of the plan to get suites for.
    # @return [Array<Hash>] List of all suites in plan and their associated info.
    def test_plan_platforms plan_id
      args = { :testplanid => plan_id }
      make_call("tl.getTestPlanPlatforms", args, "1.0")
    end
    alias_method :getTestPlanPlatforms, :test_plan_platforms

    # Gets a list of test plans within a project.
    #
    # @param [Fixnum,String] project_id ID of the project to retrieve plans.
    # @return [Array<Hash>] Array of all plans in a project and their associated
    #   info.
    # @raise [TestLinker::Error] If a project by the given ID doesn't exist.
    def test_plans project_id
      args = { :testprojectid => project_id }
      response = make_call("tl.getProjectTestPlans", args, "1.0b5")
      response == "" ? [{}] : response
    end
    alias_method :getProjectTestPlans, :test_plans

    # Gets a test suite by the given ID.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] suite_id
    # @return
    def test_suite_by_id suite_id
      args = { :testsuiteid => suite_id }
      make_call("tl.getTestSuiteByID", args, "1.0")
    end
    alias_method :getTestSuiteByID, :test_suite_by_id

    # List test suites within a test plan alphabetically.
    #
    # @param [Fixnum,String] plan_id ID of the plan to get suites for.
    # @return [Array<Hash>] List of all suites in plan and their associated info.
    def test_suites_for_test_plan plan_id
      args = { :testplanid => plan_id }
      make_call("tl.getTestSuitesForTestPlan", args, "1.0b5")
    end
    alias_method :getTestSuitesForTestPlan, :test_suites_for_test_plan

    # Gets a list of test suites that are direct children of the given test suite.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] suite_id ID of the suite to get suites for.
    # @return [Array<Hash>] List of all suites in plan and their associated info.
    def test_suites_for_test_suite suite_id
      args = { :testsuiteid => suite_id }
      make_call("tl.getTestSuitesForTestSuite", args, "1.0")
    end
    alias_method :getTestSuitesForTestSuite, :test_suites_for_test_suite

    # Gets the summarized results grouped by platform.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] plan_id
    # @return [Hash] Contains "type" => platform, "total_tc" => X, "details =>
    #   Array of counts.
    def totals_for_test_plan plan_id
      args = { :testplanid => plan_id }
      make_call("tl.getTotalsForTestPlan", args, "1.0")
    end
    alias_method :getTotalsForTestPlan, :totals_for_test_plan

    # Uploads an attachment for specified table. You must specify the table that
    # the attachment is connected (nodes_hierarchy, builds, etc) and the foreign
    # key id in this table The attachment must be Base64 encoded by the client
    # before sending it.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] foreign_key_id
    # @param [String] foreign_key_table
    # @param [String] file_name
    # @param [String] mime_type
    # @param [String] content The Base64 encoded content of the attachment.
    # @param [Hash] options
    # @option options [String] title
    # @option options [String] description
    # @return
    def upload_attachment(foreign_key_id, foreign_key_table, file_name,
        mime_type, content, options={})
      args = { :fkid => foreign_key_id, :fktable => foreign_key_table,
          :filename => file_name, :filetype => mime_type, :content => content }
      args.merge! options
      make_call("tl.uploadAttachment", args, "1.0")
    end
    alias_method :uploadAttachment, :upload_attachment

    # Uploads an attachment for a test case execution.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] execution_id
    # @param [String] file_name
    # @param [String] mime_type
    # @param [String] content The Base64 encoded content of the attachment.
    # @param [Hash] options
    # @option options [String] title
    # @option options [String] description
    # @return
    def upload_execution_attachment(execution_id, file_name, mime_type, content,
      options={})
      args = { :executionid => execution_id, :filename => file_name,
          :filetype => mime_type, :content => content }
      args.merge! options
      make_call("tl.uploadExecutionAttachment", args, "1.0")
    end
    alias_method :uploadExecutionAttachment, :upload_execution_attachment

    # Uploads an attachment for a Test Project. The attachment must be Base64
    # encoded by the client before sending it.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] project_id
    # @param [String] file_name
    # @param [String] mime_type
    # @param [String] content The Base64 encoded content of the attachment.
    # @param [Hash] options
    # @option options [String] title
    # @option options [String] description
    # @return
    def upload_project_attachment(project_id, file_name, mime_type, content,
        options={})
      args = { :testprojectid => project_id, :filename => file_name,
          :filetype => mime_type, :content => content }
      args.merge! options
      make_call("tl.uploadTestProjectAttachment", args, "1.0")
    end
    alias_method :uploadTestProjectAttachment, :upload_project_attachment

    # Uploads an attachment for a Requirement. The attachment content must be
    # Base64 encoded by the client before sending it.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] requirement_id
    # @param [String] file_name
    # @param [String] mime_type
    # @param [String] content The Base64 encoded content of the attachment.
    # @param [Hash] options
    # @option options [String] title
    # @option options [String] description
    # @return
    def upload_requirement_attachment(requirement_id, file_name, mime_type,
        content, options={})
      args = { :requirementid => requirement_id, :filename => file_name,
          :filetype => mime_type, :content => content }
      args.merge! options
      make_call("tl.uploadRequirementAttachment", args, "1.0")
    end
    alias_method :uploadRequirementAttachment, :upload_requirement_attachment

    # Uploads an attachment for a Requirement Specification. The attachment
    # content must be Base64 encoded by the client before sending it.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] requirement_specification_id
    # @param [String] file_name
    # @param [String] mime_type
    # @param [String] content The Base64 encoded content of the attachment.
    # @param [Hash] options
    # @option options [String] title
    # @option options [String] description
    # @return
    def upload_requirement_specification_attachment(requirement_specification_id,
        file_name, mime_type, content, options={})
      args = { :reqspecid => requirement_specification_id, :filename => file_name,
          :filetype => mime_type, :content => content }
      args.merge! options
      make_call("tl.uploadRequirementSpecificationAttachment", args, "1.0")
    end
    alias_method :uploadRequirementSpecificationAttachment,
        :upload_requirement_specification_attachment

    # Uploads an attachment for a Test Case. The attachment must be Base64
    # encoded by the client before sending it.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] test_case_id
    # @param [String] file_name
    # @param [String] mime_type
    # @param [String] content The Base64 encoded content of the attachment.
    # @param [Hash] options
    # @option options [String] title
    # @option options [String] description
    # @return
    def upload_test_case_attachment(test_case_id, file_name, mime_type, content,
        options={})
      args = { :testcaseid => test_case_id, :filename => file_name,
          :filetype => mime_type, :content => content }
      args.merge! options
      make_call("tl.uploadTestCaseAttachment", args, "1.0")
    end
    alias_method :uploadTestCaseAttachment, :upload_test_case_attachment

    # Uploads an attachment for a Test Suite. The attachment must be Base64
    # encoded by the client before sending it.
    #
    # @api TestLink API version 1.0
    # @param [Fixnum,String] suite_id
    # @param [String] file_name
    # @param [String] mime_type
    # @param [String] content The Base64 encoded content of the attachment.
    # @param [Hash] options
    # @option options [String] title
    # @option options [String] description
    # @return
    def upload_test_suite_attachment(suite_id, file_name, mime_type, content,
        options={})
      args = { :testsuiteid => suite_id, :filename => file_name,
          :filetype => mime_type, :content => content }
      args.merge! options
      make_call("tl.uploadTestSuiteAttachment", args, "1.0")
    end
    alias_method :uploadTestSuiteAttachment, :upload_test_suite_attachment
  end
end
