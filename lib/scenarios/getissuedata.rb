module Scenarios
  ##
  # GetIssueData scenario
  class GetIssueData
    def run
      # repo to module dictionary
      modules_dict = {
        'avia' => 'back_avia',
        'seo_pages' => 'back_seopages',
        'bundle-back' => 'back_bundles',
        '12trip-railways.node' => 'back_blackbox',
        '12trip' => 'front_12trip',
        'twiket_backoffice' => 'front_bo',
        'twiket-live' => 'front_tlive',
        '12trip_hotels' => 'front_hotels',
        'm-hotels' => 'front_mhotels',
        'm-12trip' => 'front_mobile',
        'emails' => 'front_emails',
        'xjsx' => 'front_xjsx',
      }
      raise 'No ENVIRONMENT!' unless ENV['ENVIRONMENT']
      jira = JIRA::Client.new SimpleConfig.jira.to_h
      issue = jira.Issue.find SimpleConfig.jira.issue

      # Get unique labels from release issue and all linked issues
      labels = issue.labels
      issue.linked_issues('deployes').each do |linked_issue|
        labels.concat(linked_issue.labels)
      end
      labels = labels.uniq

      prs = issue.related['pullRequests']

      puts 'Checking for wrong PRs names:'

      prs.each do |pr|
        prname = pr['name'].dup
        if pr['name'].strip!.nil?
          puts "[#{prname}] - OK"
        else
          puts "[#{prname}] - WRONG! Stripped. Bad guy: #{pr['author']['name']}"
        end
      end

      git_style_release = SimpleConfig.jira.issue.tr('-', ' ').downcase.capitalize

      prs.select! { |pr| (/^((#{SimpleConfig.jira.issue})|(#{git_style_release}))/.match pr['name']) && pr['status'] != 'DECLINED' }

      if prs.empty?
        puts 'No pull requests for this task!'
        exit 1
      end

      puts 'Selected PRs:'
      puts prs.map { |pr| pr['name'] }

      issue_data = { 'ENVIRONMENT' => ENV['ENVIRONMENT'] }
      prop_values = {}

      prs.each do |pr|
        repo_name = pr['url'].split('/')[-3]
        unless pr['destination']['branch'].include? 'master'
          puts "WTF? Why is this Pull Request here? o_O (destination: #{pr['destination']['branch']}"
          next
        end
        # check for repo in modules_dict
        next unless modules_dict.key?(repo_name)
        prop_values["#{repo_name.upcase}_REVISION"] = pr['source']['branch']
        project_labels = labels.select { |label| label.start_with? "#{repo_name}_" }.map { |label| label.remove("#{repo_name}_") }
        prop_values["#{repo_name.upcase}_LABELS"] = project_labels.join(',') unless project_labels.empty?
      end

      issue_data['REV_DATA'] = prop_values.to_json

      JavaProperties.write issue_data, './.issue_data'

      exit 0
    end
  end
end
