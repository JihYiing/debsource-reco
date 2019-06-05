pipeline{
    agent {
        node {
            label 'aws-amd64-gpu'
        }
    }
  
    options {
        timestamps()
        skipDefaultCheckout true
        timeout(time: 2, unit: 'HOURS')
        disableConcurrentBuilds()
	}
      
    stages {   
       
                stage('Pull Source Code'){
                   agent {
                        docker { 
                            label 'aws-amd64-gpu'
                            image 'aeolusbot/ros-base:master-xenial' 
                            args '-u root --privileged'
                        }
                
                    }
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'github usr+pw', 
                            usernameVariable: 'GITHUB_ACCOUNT',passwordVariable:'GITHUB_PASSWORD')]){
                            sh 'rm -rf debsource-reco'
                            sh 'git config --global credential.helper cache'
                            sh '''git clone  --branch master --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/debsource-reco.git'''
                            dir("debsource-reco"){ 
                                sh '''git clone --branch master --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/object_tracer.git ''' +
                                    '''&& cd object_tracer &&  sed -i \'s|git@github.com:aeolusbot|https://github.com/aeolusbot|\' .gitmodules && git submodule init && git submodule update --remote'''   
                            }
                        }
                    } 
                }
                stage('Build Debsource'){
                    agent {
                        docker { 
                            label 'aws-amd64-gpu'
                            image 'aeolusbot/ros-base:master-xenial' 
                            args '-u root --privileged'
                        }
                
                    }
                    steps {
                        dir('aptsource') {
                            git changelog: false, credentialsId: 'github usr+pw', poll: false, url: 'https://github.com/aeolusbot/docker-images.git'
                        }
                        sh 'sudo cp -r aptsource/src/xenial/apt/preferences.d /etc/apt/'
                        sh 'sudo cp -r aptsource/src/xenial/apt/sources.list.d /etc/apt/'
                        sh 'sudo cp -r aptsource/src/xenial/apt/trusted.gpg.d /etc/apt/'
                        sh 'apt-get update && apt-get install -y caffe-cuda python-lutorpy libcaffe-cuda-dev nuitka torch'
                        sh 'apt-get install -y devscripts build-essential fakeroot ros-kinetic-opencv3'
                        sh 'apt-get install -y libopencv-dev libopenblas-base debhelper cython'
                        sh 'apt install -y libopenblas-dev'
                        sh 'cp -r debsource-reco/object_tracer/reco_model/* debsource-reco/model/'
                        sh 'ln -sfn /usr/bin/ld.gold /usr/local/bin/ld'
                        dir("debsource-reco") {
                            sh 'cd object_tracer/libs/dlf &&. ./script/env.sh && python setup.py'
                            sh 'rosdep update'
                            sh './build.bash'
                        }
                    }
                }         
    }     
}
