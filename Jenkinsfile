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
				relativeTargetDir: "moqui-framework/runtime/component/${item}"]],
			userRemoteConfigs: [[ url: "https://github.com/moqui/${item}.git"]]
		])
	}
}

pipeline {
	agent any
	stages {
		stage('Preparation') {
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
			steps {
				// Set gradle home so it doesn't get killed in the home directory
				sh """
					export GRADLE_USER_HOME="`pwd`/.gradle"
					cd moqui-framework
					./gradlew -g \$GRADLE_USER_HOME getDepends -PlocationType=current
					curl -o runtime/lib/mysql-connector-java-8.0.12.jar http://central.maven.org/maven2/mysql/mysql-connector-java/8.0.12/mysql-connector-java-8.0.12.jar
					curl -o runtime/lib/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar
					rm -r .git
					./gradlew -g \$GRADLE_USER_HOME addRuntime
					./gradlew -g \$GRADLE_USER_HOME loadProduction
					cd ..
					./docker-build.sh moqui-framework ${containerRepository}
				"""
				archiveArtifacts artifacts: 'moqui-framework/*.war', fingerprint: true
			}
		}
	}
}
