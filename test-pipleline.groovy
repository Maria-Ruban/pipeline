pipeline {
    agent any
    stages {
        stage ("build") {
            steps {
                echo "build stage"

            }
        }
        stage ("complie") {
            steps {
                echo "complie stage"
            }
        }
        stage ("deploy") {
            steps {
                echo "deploy stage"
            }
        }
    }
}