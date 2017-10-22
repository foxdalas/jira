def args = ''

if (env.CLEAN=="true")
    args = "${args} --clean"
if (env.PUSH=="true")
    args = "${args} --push"
if (env.IGNORELINKS=="true")
    args = "${args} --ignorelinks"
if (env.DRYRUN=="true")
    args = "${args} --dryrun"
if (env.SOURCE!='')
    args = "${args} --source=${env.SOURCE}"
if (env.RELEASE!='')
    release = env.RELEASE
if (env.RELEASE_OVERRIDE!='')
    release=env.RELEASE_OVERRIDE

env.JIRA_SITE="https://onetwotripdev.atlassian.net"    

podTemplate(
  label: 'jira',
  containers: [
    containerTemplate(
      name: 'ruby',
      image: "ruby:2.3-alpine",
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
            apk update
            apk add git libffi g++ make
            gem install bundler --quiet
            bundle install --quiet
          """
        }
        stage('release') {
          withCredentials([usernamePassword(credentialsId: '7f07b874-d745-4cd1-9d3c-3824a34c7ec6', usernameVariable: 'JIRA_USERNAME', passwordVariable: 'JIRA_PASSWORD')]) {
            sh("echo $JIRA_SITE")
            sh("bin/build_release --release ${release} ${args}")
          }
        }
      }
		}
  }
}


