properties([
  parameters([
    string(name: 'configuration', defaultValue: 'Release'),
  ])
])

pipeline {
    agent {label 'mac'}
    stages {
        stage("Build") {
            steps {
                sh "/usr/bin/xcodebuild -workspace Brewed.xcodeproj/project.xcworkspace -scheme Brewed -configuration '${params.configuration}' clean build DEVELOPMENT_TEAM=''"
            }
        }
    }
}
