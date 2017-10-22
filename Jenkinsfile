podTemplate(
  label: 'jira',
  containers: [
    containerTemplate(
      name: 'ruby',
      image: "ruby:2.3.3-alpine",
      ttyEnabled: true,
      command: 'cat'
    )
  ]) {
	
	node('jira') {
 		timestamps {
		  container('ruby') { 
			  checkout scm

        stage('Install production dependencies') {
        
        sh """
          cd jira
          gem install bundler --quiet
          bundle install --quiet
        """
        }
      }
		}
	}
}
