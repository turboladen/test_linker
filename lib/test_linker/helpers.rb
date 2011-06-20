require File.expand_path(File.dirname(__FILE__) + '/error')

# This module contains methods that aren't a part of the TestLink API.  They
# intend to make accessing TestLink database info easier.
module TestLinker::Helpers

  # @return [String] The version of TestLink's API.
  def api_version
    if @api_version
      @api_version
    else
      about =~ /Testlink API Version: (.+) initially/
      @api_version = $1
    end
  end

  # Gets ID of project matching the given project_name.
  #
  # @param [String] project_name Name of the project to search for.
  # @return [Fixnum] ID of project matching project_name.
  def project_id project_name
    if @version < "1.0"
      project = projects.find { |project| project[:name] == project_name }
    else
      project = project_by_name(project_name).first
    end

    project.nil? ? nil : project[:id].to_i
  end

  # Gets info about test plans within a project
  #
  # @param [String] project_name Name of the project to search for.
  # @param [String] plan_name Name of the plan to search for.
  # @return [Fixnum] ID of plan matching project_name and plan_name. 0 if the
  #   test plan wasn't found.
  def test_plan_id(project_name, plan_name)
    if @version < "1.0"
      project_id = project_id project_name
      test_plans = test_plans(project_id)

      test_plan = test_plans.first.values.find do |project_test_plan|
        project_test_plan[:name] == plan_name
      end
    else
      test_plan = test_plan_by_name(project_name, plan_name).first
    end

    test_plan.nil? ? nil : test_plan[:id].to_i
  end

  # Gets the ID for the given build name.
  #
  # @param [String] project_name Name of the project to search for.
  # @param [String] plan_name Name of the plan to search for.
  # @param [String] build_name Name of the build to search for.
  # @return [Fixnum] ID of plan matching project_name and plan_name
  def build_id(project_name, plan_name, build_name)
    plan_id = test_plan_id(project_name, plan_name)
    builds = builds_for_test_plan plan_id

    build = builds.find do |build|
      build[:name] == build_name
    end

    build.nil? ? nil : build[:id].to_i
  end

  # Finds a list of projects whose attribute (given via the +match_attribute+
  # parameter) matches +regex+.
  #
  # @param [Regexp] regex The expression to match project names on.
  # @param [Symbol] match_attribute Attribute of the projects to match on.
  # @return [Array] An array of projects that match the Regexp.
  def find_projects(regex, match_attribute=:name)
    project_list = projects

    project_list.find_all do |project|
      project[match_attribute] =~ regex
    end
  end

  # Finds a list of test plans whose attribute (given via the +match_attribute+
  # parameter) matches +regex+.
  #
  # @param [Fixnum,String] project_id ID of the project that the test plans
  #   belong to.
  # @param [Regexp] regex The expression to match test plan names on.
  # @return [Array] An array of test plans that match the Regexp.
  def find_test_plans(project_id, regex, match_attribute=:name)
    test_plan_list = test_plans(project_id)
    matched_list = []
    
    if @version > "1.0"
      test_plan_list.first.values.find_all do |project_test_plan|
        project_test_plan[match_attribute] =~ regex
      end
    elsif @version <= "1.0"
      test_plan_list.first.each_value do |plan|
        matched_list << plan if plan[match_attribute] =~ regex
      end
    end
    
    matched_list
  end
  
  # @param [String] project_name
  # @param [String] suite_name
  # @return [Fixnum] ID of the requested test suite.  nil if not found.
  def first_level_test_suite_id(project_name, suite_name)
    test_suites = first_level_test_suites_for_project(project_id(project_name))

    test_suite = test_suites.find do |test_suite|
      test_suite[:name] == suite_name
    end

    test_suite.nil? ? nil : test_suite[:id].to_i
  end

  # Gets info about test case within a test plan within a project.
  #
  # @param [String] project_name Name of the project to search for.
  # @param [String] plan_name Name of the plan to search for.
  # @param [String] test_case_name Name of the test case to search for.
  # @return [Hash] Info on the first matching test case.
  # @todo Need to update for having more than one of same test name inside test plan.
  def test_info(project_name, plan_name, test_case_name)
    test_plan_id = test_plan_id(project_name, plan_name)
    test_cases = test_cases_for_test_plan(test_plan_id)

    test_cases.values.find do |test_case|
      test_case[:name] == test_case_name
    end
  end

  # Gets info about test suite within a test plan within a project.
  #
  # @param [String] project_name
  # @param [String] plan_name
  # @param [String] suite_name
  # @return [Hash] The name and ID of the test suite.
  # @todo Need to update for having more than one of same test name inside test plan.
  def suite_info(project_name, plan_name, suite_name)
    test_plan_id = test_plan_id(project_name, plan_name)
    test_suites = test_suites_for_test_plan(test_plan_id)

    if test_suites.empty?
      return nil
    end

    test_suites.find do |test_suite|
      test_suite[:name].include? suite_name
    end
  end

  # Get the ID of a first level suite, creating it if it does not exist.
  #
  # @param [String] project_name
  # @param [String] suite_name
  # @return [String] ID of the created or existing suite.
  # TODO: This should rescue TestLinker::Error
  def create_first_level_suite(project_name, suite_name)
    return first_level_test_suite_id(project_name, suite_name)
  rescue RuntimeError

    # Create suite if it doesn't exist.
    project_id = project_id(project_name)

    create_test_suite(project_id, suite_name).first[:id]
  end

  # Checks if the test case has been executed.
  #
  # Todo:
  # * versioning support (make_call = :exec_status vs 'exec_status')'
  # * Also accept TC_ID instead?
  # @param [Hash] test_case A testcase Hash (AKA 'testcase info')
  # @return [Boolean] true if the test hasn't yet been executed.
  def test_not_run?(test_case)
    true if test_case['exec_status'] == 'n'
  end

  # Returns all open (not-run) test cases for a given plan within project.
  # Extra options for now are +:build+, which will match a given build rather
  # than all open builds by default.
  #
  # @param [String] project_name
  # @param [Regexp] plan_regex Plan name as regex.
  # @param [Hash] options
  # @return [Array<Hash>] Array of matching testcase hashes.
  def find_open_cases_for_plan(project_name,plan_regex,options={})
    test_case_array = []
    project_id = project_id(project_name)
    test_plans = find_test_plans(project_id, plan_regex) # Get plans for project
    builds = builds_for_test_plan(test_plans[:id])       # Get builds for plan(s)
    
    builds.each do |build|
      if options[:build]
        if build[:name] =~ options[:build]
          test_cases = test_cases_for_test_plan(build[:testplan_id],
              { "buildid" => build[:id] }) 
        end
      elsif build[:is_open] == 1
        test_cases = test_cases_for_test_plan(build[:testplan_id],
            { "buildid" => build[:id] })
      end

      unless test_cases.nil?
        test_cases.each_value do |test_case|
          # There's only one element here, but it's in an array'
          test_case_array = test_case_array.concat(test_case) if test_not_run?(test_case.first)
        end
      end
    end
 
    test_case_array
  end

  # Get the ID of a suite with the given parent, creating it if it does not
  # exist.
  #
  # @param [String] suite_name
  # @param [String] project_name
  # @return [String] ID of the created or existing suite.
  # @raise [TestLinker::Error] When unable to find matching
  #   project/plan/test case names.
  def create_suite(suite_name, project_name, parent_id)
    project_id = project_id(project_name)
    response = test_suites_for_test_suite(parent_id)

    if response.class == Array
      raise TestLinker::Error, response.first[:message]
    elsif response.class == Hash
      return response[:id] if response[:name] == suite_name

      response.each_value do |suite|
        return suite[:id] if suite[:name] == suite_name
      end
    end

    create_test_suite(project_id, suite_name, parent_id).first[:id]
  end

  # Creates test in test suite within a test plan within a project.
  #
  # @param [String] project_name
  # @param [String] plan_name
  # @param [String] suite_name
  # @param [String] test_case_name
  # @param [String] login
  # @param [String] summary
  # @param [String] steps
  # @param [String] expected_results
  # @return [Array] array->  array[0]=test case id, array[1]=test case version
  # @todo Need to update for having more than one of same test name inside test plan.
  def create_test_case_by_name(project_name, plan_name, suite_name,
      test_case_name, login, summary, steps, expected_results)

    test_project_id = self.project_id(project_name)
    test_suite_id = self.suite_info(project_name, plan_name, suite_name)

    result = create_test_case(test_project_id, test_suite_id, test_case_name,
      summary, steps, expected_results, login)

    if result.any?
      result.each do |result_ptr|
        if result_ptr[:message].eql? "Success!"
          if result_ptr.has_key? "additionalInfo"
            result_info = result_ptr.fetch("additionalInfo")
            if result_info[:msg].eql? "ok"
              test_case_id = result_info[:id]
              test_case_version = result_info[:version_number]
              return [test_case_id, test_case_version]
            else
              return -1
            end
          end
        end
      end
    end
  end

  # Creates test in test suite within a test plan within a project.
  #
  # @param [String] project_name
  # @param [String] plan_name
  # @param [Fixnum,String] test_case_id
  # @param [String] test_case_version
  # @return [Boolean] true on success, false on fail
  # @todo NEED TO CLEAN THIS UP AND ADD ERROR CHECKING
  # @todo Need to update for having more than one of same test name inside testplan
  def add_test_case_to_test_plan_by_name(project_name, plan_name, test_case_id,
      test_case_version)
    test_project_id = project_id(project_name)
    test_plan_id =  test_plan_id(project_name, plan_name)

    result = add_test_case_to_test_plan(test_project_id, test_plan_id,
        test_case_id, test_case_version)

    if result.any?
      #Only way to tell if success if with the key "feature_id"
      return result.has_key?(:feature_id) ? true : false
    end
  end
end
