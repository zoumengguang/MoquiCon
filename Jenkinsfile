def moquiComponents = [
	'moqui-elasticsearch',
	'HiveMind',
	'PopCommerce',
	'SimpleScreens',
	'mantle-usl',
	'mantle-udm',
	'PopRestStore',
]

def loop(list) {
	list.each { item -> 
		checkout(changelog: false, poll: false, scm:[$class: 'GitSCM',
			branches: [[name: '*/master']],
			extensions: [[
				$class: 'RelativeTargetDirectory',
				relativeTargetDir: "runtime/component/${item}"]],
			userRemoteConfigs: [[ url: "https://github.com/moqui/${item}.git"]]
		])
	}
}

pipeline {
	agent any
	stages {
		stage('Preparation') {
			tools {
                   jdk "Java 8"
            }

			steps {
				// Clone Moqui Framework
				checkout([$class: 'GitSCM',
					branches: [[name: '*/master']],
					doGenerateSubmoduleConfigurations: false,
					extensions: [[
						$class: 'SubmoduleOption',
						recursiveSubmodules: true,
					]],
					userRemoteConfigs: [[url: 'https://github.com/moqui/moqui-framework']]
				])
			
				// Clone Moqui Runtime
				checkout(
					changelog: false, 
					poll: false,
					scm: [$class: 'GitSCM',
						branches: [[name: '0b393b8bbc83fab50713ccb6c08c5bbaf540c41a']],
						doGenerateSubmoduleConfigurations: false,
						extensions: [[
							$class: 'RelativeTargetDirectory', 
							relativeTargetDir: "runtime"]],
						userRemoteConfigs: [[url: 'https://github.com/moqui/moqui-runtime.git']]
					]
				)
			
				// Clone Basic Moqui Components
				loop(moquiComponents)

				// Clone MoquiCon
				checkout([$class: 'GitSCM',
					branches: [[name: '*/master']],
					extensions: [[
						$class: 'RelativeTargetDirectory',
						relativeTargetDir: "runtime/component/MoquiCon"]], 
					userRemoteConfigs: [[url: 'https://github.com/mkdecisiondev/MoquiCon']]
				])
			}
		}

		stage('Build') {
			tools {
                   jdk "Java 8"
            }

			steps {
				// Set gradle home so it doesn't get killed in the home directory
				sh """
					java -version
					export GRADLE_USER_HOME=".gradle"
					./gradlew -g \$GRADLE_USER_HOME getDepends -PlocationType=current
					rm -r .git
					./gradlew -g \$GRADLE_USER_HOME addRuntime
					./gradlew -g \$GRADLE_USER_HOME loadProduction
				"""
				archiveArtifacts artifacts: '*.war', fingerprint: true
			}
		}
	}
}
